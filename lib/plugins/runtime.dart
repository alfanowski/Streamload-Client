// lib/plugins/runtime.dart
import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';

import 'host_api.dart';
import 'meta.dart';
import 'plugin.dart';

/// Hosts the QuickJS / JSCore runtime + every mounted plugin. One instance per app.
///
/// Plugin source is vanilla ESM; we transform `export ` declarations into
/// assignments on a per-plugin exports object, then evaluate the result and
/// stash it under `globalThis.__sl_plugins[shortName]`.
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

  /// Install the per-runtime shim that makes `host.*` Promise-based and
  /// gives plugins a scoped `exports` object to write into.
  Future<void> _installShim() async {
    const shim = r'''
      (function() {
        if (globalThis.__sl_plugins) return;
        globalThis.__sl_plugins = {};
        globalThis.__sl_currentPlugin = null;
        function call(module, method, args) {
          const plugin = globalThis.__sl_currentPlugin;
          const payload = JSON.stringify({plugin, module, method, args});
          return sendMessage('host_call', payload).then(function(raw) {
            const out = JSON.parse(raw);
            if (out.error) throw new Error(out.error);
            return out.value;
          });
        }
        globalThis.host = {
          log: {
            debug: (m) => call('log', 'debug', [m]),
            info:  (m) => call('log', 'info',  [m]),
            warn:  (m) => call('log', 'warn',  [m]),
            error: (m) => call('log', 'error', [m]),
          },
          http: {
            fetch: (url, init) => call('http', 'fetch', [url, init || {}]),
          },
          storage: {
            get:    (k)    => call('storage', 'get',    [k]),
            set:    (k, v) => call('storage', 'set',    [k, v]),
            delete: (k)    => call('storage', 'delete', [k]),
          },
          json: {
            parse:     (s) => call('json', 'parse',     [s]),
            stringify: (o) => call('json', 'stringify', [o]),
          },
          url: {
            absolute: (rel, base) => call('url', 'absolute', [rel, base]),
          },
          crypto: {
            sha256Hex:    (s)         => call('crypto', 'sha256Hex',    [s]),
            md5Hex:       (s)         => call('crypto', 'md5Hex',       [s]),
            hmacHex:      (algo, k, d)=> call('crypto', 'hmacHex',      [algo, Array.from(k), Array.from(d)]),
            base64Encode: (s)         => call('crypto', 'base64Encode', [s]),
            aesDecryptCbc:(ct, k, iv) => call('crypto', 'aesDecryptCbc',[Array.from(ct), Array.from(k), Array.from(iv)]).then(arr => new Uint8Array(arr)),
          },
          html: {
            parse: function(text) {
              return call('html', 'parse', [text]).then(function(ref) {
                return wrapDoc(ref.__doc);
              });
            },
          },
        };
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
    // Phase 1: extract & validate meta by evaluating in isolation.
    final probeId = '__sl_probe_${DateTime.now().microsecondsSinceEpoch}';
    final probeBlock = '''
      (function() {
        var exports = {};
        ${_stripExports(source)}
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
      // Drop the probe and abort — leaves any previous version untouched.
      _js.evaluate('delete globalThis.$probeId');
      throw StateError(err);
    }
    final meta = PluginMeta.fromJson(metaJson);

    // Phase 2: commit — copy probe object to the canonical slot, drop probe.
    final commitBlock = '''
      (function() {
        globalThis.__sl_plugins[${jsonEncode(meta.shortName)}] = globalThis.$probeId;
        delete globalThis.$probeId;
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
    // Set current plugin context synchronously, call the function, reset.
    final stub = '''
      (function() {
        globalThis.__sl_currentPlugin = ${jsonEncode(shortName)};
        var fn = globalThis.__sl_plugins[${jsonEncode(shortName)}].$functionName;
        var result = fn.apply(null, ${jsonEncode(args)});
        globalThis.__sl_currentPlugin = null;
        return result;
      })();
    ''';

    final evalResult = _js.evaluate(stub);
    if (evalResult.isError) {
      throw StateError(
        'plugin $shortName.$functionName failed: ${evalResult.stringResult}',
      );
    }

    // If the function returned a Promise, resolve it through handlePromise.
    if (evalResult.isPromise || evalResult.stringResult == '[object Promise]') {
      final resolved = await _js.handlePromise(evalResult);
      if (resolved.isError) {
        throw StateError(
          'plugin $shortName.$functionName rejected: ${resolved.stringResult}',
        );
      }
      final jsonResult = resolved.stringResult;
      if (jsonResult == 'null' || jsonResult == 'undefined') return null;
      // The promise value should be already JSON stringified by the plugin
      // or we need to stringify it. Attempt to parse; if it fails, stringify
      // the raw string value first.
      try {
        return jsonDecode(jsonResult);
      } catch (_) {
        // The result is already the Dart representation (e.g. a Map/List).
        // This happens when JSCore auto-converts objects.
        return jsonResult;
      }
    }

    // Synchronous result — use the stringResult from evaluate.
    final raw = evalResult.stringResult;
    if (raw == 'null' || raw == 'undefined') return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }

  /// Strip the `export ` keyword from `export const`, `export async function`,
  /// and `export function` declarations, leaving plain assignments / function
  /// declarations whose names land in the surrounding IIFE's scope.
  ///
  /// Then copy the four contract names + meta into `exports` so the IIFE
  /// can return them.
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
