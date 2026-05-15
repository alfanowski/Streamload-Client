// lib/plugins/runtime.dart
import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';

import 'host_api.dart';
import 'meta.dart';
import 'plugin.dart';

/// Hosts the QuickJS / JSCore runtime + every mounted plugin. One instance per app.
///
/// Plugin source is vanilla ESM; we strip `export ` declarations and re-eval the
/// stripped body inside an IIFE that injects a per-plugin `host` bound by
/// closure. The resulting exports object lives at `globalThis.__sl_plugins[name]`.
class PluginRuntime {
  PluginRuntime._(this._js, this._hostApi);

  static Future<PluginRuntime> create({required HostApi hostApi}) async {
    final js = getJavascriptRuntime(xhr: false);
    js.onMessage('host_call', (dynamic args) async {
      // flutter_js passes the raw payload; our JS shim sends a JSON string.
      final payload = args is String ? args : jsonEncode(args);
      return hostApi.dispatch(payload);
    });
    final runtime = PluginRuntime._(js, hostApi);
    await runtime._installShim();
    return runtime;
  }

  final JavascriptRuntime _js;
  // ignore: unused_field
  final HostApi _hostApi;

  final Map<String, Plugin> _plugins = {};

  /// Install the per-runtime shim. Defines `__sl_makeHost(plugin)` which
  /// returns a host object with `plugin` captured in closure — every host.*
  /// call from that object carries the correct plugin name regardless of
  /// async re-entry.
  Future<void> _installShim() async {
    const shim = r'''
      (function() {
        if (globalThis.__sl_plugins) return;
        globalThis.__sl_plugins = {};
        globalThis.__sl_makeHost = function(plugin) {
          function call(module, method, args) {
            var payload = JSON.stringify({plugin: plugin, module: module, method: method, args: args});
            return sendMessage('host_call', payload).then(function(raw) {
              var out = JSON.parse(raw);
              if (out.error) throw new Error(out.error);
              return out.value;
            });
          }
          function wrapDoc(h) {
            return {
              find: function(sel) {
                return call('html', 'doc.find', [h, sel]).then(function(rs) {
                  return rs.map(function(r) { return wrapEl(r.__el); });
                });
              },
              querySelector: function(sel) {
                return call('html', 'doc.querySelector', [h, sel]).then(function(ref) {
                  return ref == null ? null : wrapEl(ref.__el);
                });
              },
            };
          }
          function wrapEl(h) {
            return {
              find: function(sel) {
                return call('html', 'el.find', [h, sel]).then(function(rs) {
                  return rs.map(function(r) { return wrapEl(r.__el); });
                });
              },
              text: function() { return call('html', 'el.text', [h]); },
              html: function() { return call('html', 'el.html', [h]); },
              attr: function(n) { return call('html', 'el.attr', [h, n]); },
            };
          }
          return {
            log: {
              debug: function(m) { return call('log', 'debug', [m]); },
              info:  function(m) { return call('log', 'info',  [m]); },
              warn:  function(m) { return call('log', 'warn',  [m]); },
              error: function(m) { return call('log', 'error', [m]); },
            },
            http: {
              fetch: function(url, init) { return call('http', 'fetch', [url, init || {}]); },
            },
            storage: {
              get:    function(k)    { return call('storage', 'get',    [k]); },
              set:    function(k, v) { return call('storage', 'set',    [k, v]); },
              delete: function(k)    { return call('storage', 'delete', [k]); },
            },
            json: {
              parse:     function(s) { return call('json', 'parse',     [s]); },
              stringify: function(o) { return call('json', 'stringify', [o]); },
            },
            url: {
              absolute: function(rel, base) { return call('url', 'absolute', [rel, base]); },
            },
            crypto: {
              sha256Hex:    function(s)         { return call('crypto', 'sha256Hex',    [s]); },
              md5Hex:       function(s)         { return call('crypto', 'md5Hex',       [s]); },
              hmacHex:      function(algo, k, d){ return call('crypto', 'hmacHex',      [algo, Array.from(k), Array.from(d)]); },
              base64Encode: function(s)         { return call('crypto', 'base64Encode', [s]); },
              aesDecryptCbc:function(ct, k, iv) { return call('crypto', 'aesDecryptCbc',[Array.from(ct), Array.from(k), Array.from(iv)]).then(function(arr){ return new Uint8Array(arr); }); },
            },
            html: {
              parse: function(text) {
                return call('html', 'parse', [text]).then(function(ref) {
                  return wrapDoc(ref.__doc);
                });
              },
            },
          };
        };
      })();
    ''';
    final result = _js.evaluate(shim);
    if (result.isError) {
      throw StateError('plugin runtime shim failed: ${result.stringResult}');
    }
  }

  /// Mount a plugin from raw ESM source. Atomic: if anything fails (parse,
  /// meta validation, evaluation), the previous version (if any) stays active.
  Future<Plugin> mount(String source) async {
    // Phase 1: probe — eval in an isolated IIFE just to extract meta.
    // Plugin functions reference `host` lexically but aren't invoked here,
    // so a missing `host` binding is fine; meta is a top-level constant.
    final stripped = _stripExports(source);
    final probeId = '__sl_probe_${DateTime.now().microsecondsSinceEpoch}';
    final probeBlock = '''
      (function() {
        var exports = {};
        $stripped
        globalThis.$probeId = exports;
        return JSON.stringify(exports.meta);
      })();
    ''';
    final probe = _js.evaluate(probeBlock);
    if (probe.isError) {
      throw StateError('plugin parse failed: ${probe.stringResult}');
    }

    final metaRaw = probe.stringResult;
    if (metaRaw == 'null' || metaRaw == 'undefined') {
      _js.evaluate('delete globalThis.$probeId');
      throw StateError('plugin source does not export a meta object');
    }

    final Map<String, dynamic> metaJson;
    try {
      metaJson = jsonDecode(metaRaw) as Map<String, dynamic>;
    } catch (_) {
      _js.evaluate('delete globalThis.$probeId');
      throw StateError('plugin meta is not valid JSON: $metaRaw');
    }

    final err = PluginMeta.validate(metaJson);
    if (err != null) {
      _js.evaluate('delete globalThis.$probeId');
      throw StateError(err);
    }
    final meta = PluginMeta.fromJson(metaJson);

    // Phase 2: commit — re-eval inside an IIFE that injects the per-plugin
    // host as a parameter. Inner functions close over `host` lexically, so
    // every host.* call carries this plugin's name regardless of async re-entry.
    final nameLit = jsonEncode(meta.shortName);
    final commitBlock = '''
      (function() {
        delete globalThis.$probeId;
        globalThis.__sl_plugins[$nameLit] = (function(host) {
          var exports = {};
          $stripped
          return exports;
        })(globalThis.__sl_makeHost($nameLit));
        return true;
      })();
    ''';
    final commit = _js.evaluate(commitBlock);
    if (commit.isError) {
      throw StateError('plugin commit failed: ${commit.stringResult}');
    }

    final plugin = Plugin(meta: meta, call: _callJsFunction);
    _plugins[meta.shortName] = plugin;
    return plugin;
  }

  Future<void> unmount(String shortName) async {
    _plugins.remove(shortName);
    _js.evaluate(
      '(function(){ delete globalThis.__sl_plugins[${jsonEncode(shortName)}]; return true; })();',
    );
  }

  Plugin? callable(String shortName) => _plugins[shortName];

  Iterable<Plugin> get all => _plugins.values;

  Future<void> dispose() async {
    _js.dispose();
  }

  /// Execute `globalThis.__sl_plugins[shortName].functionName(...args)` and
  /// return the JSON-parsed result. Handles both sync return values and
  /// JS Promises (the latter via flutter_js handlePromise).
  Future<Object?> _callJsFunction(
    String shortName,
    String functionName,
    List<Object?> args,
  ) async {
    final stub = '''
      (function() {
        var fn = globalThis.__sl_plugins[${jsonEncode(shortName)}].$functionName;
        return fn.apply(null, ${jsonEncode(args)});
      })();
    ''';

    final evalResult = _js.evaluate(stub);
    if (evalResult.isError) {
      throw StateError(
        'plugin $shortName.$functionName eval-error: '
        '"${evalResult.stringResult}" rawResult=${evalResult.rawResult}',
      );
    }

    if (evalResult.isPromise || evalResult.stringResult == '[object Promise]') {
      final resolved = await _js.handlePromise(evalResult);
      if (resolved.isError) {
        throw StateError(
          'plugin $shortName.$functionName rejected: '
          '"${resolved.stringResult}" rawResult=${resolved.rawResult}',
        );
      }
      final jsonResult = resolved.stringResult;
      if (jsonResult == 'null' || jsonResult == 'undefined') return null;
      try {
        return jsonDecode(jsonResult);
      } catch (_) {
        return jsonResult;
      }
    }

    final raw = evalResult.stringResult;
    if (raw == 'null' || raw == 'undefined') return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }

  /// Strip `export ` keyword from declarations and append re-exports of the
  /// four contract functions + meta into the local `exports` object.
  static String _stripExports(String source) {
    final stripped = source
        .replaceAll(RegExp(r'^\s*export\s+const\s+', multiLine: true), 'const ')
        .replaceAll(RegExp(r'^\s*export\s+let\s+', multiLine: true), 'let ')
        .replaceAll(
            RegExp(r'^\s*export\s+async\s+function\s+', multiLine: true),
            'async function ')
        .replaceAll(
            RegExp(r'^\s*export\s+function\s+', multiLine: true), 'function ')
        .replaceAll(RegExp(r'^\s*export\s+default\s+', multiLine: true), 'var __default = ');

    return '''
$stripped

if (typeof meta !== "undefined") exports.meta = meta;
if (typeof search !== "undefined") exports.search = search;
if (typeof getSeasons !== "undefined") exports.getSeasons = getSeasons;
if (typeof getEpisodes !== "undefined") exports.getEpisodes = getEpisodes;
if (typeof getStreams !== "undefined") exports.getStreams = getStreams;
''';
  }
}
