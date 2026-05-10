// lib/plugins/host_api.dart
import 'dart:convert';
import 'dart:typed_data';

import 'host/crypto_host.dart';
import 'host/html_host.dart';
import 'host/http_host.dart';
import 'host/json_host.dart';
import 'host/log_host.dart';
import 'host/storage_host.dart';
import 'host/url_host.dart';

/// Bundles the host modules into one namespace. `PluginRuntime` hands the
/// `dispatch` method to flutter_js as the `host_call` channel handler.
class HostApi {
  HostApi({
    required this.http,
    required this.storage,
    required this.log,
    HtmlHost? html,
    JsonHost? json,
    UrlHost? url,
    CryptoHost? crypto,
  });

  final HttpHost http;
  final StorageHost storage;
  final LogHost log;

  /// Cache of recently-parsed HTML docs, keyed by an opaque handle.
  /// Plugins call host.html.parse(text) → returns handle. Subsequent
  /// host.html.find(handle, selector) etc. dereference here.
  final Map<int, HtmlDocument> _htmlDocs = {};
  final Map<int, HtmlElement> _htmlElements = {};
  int _htmlCounter = 0;

  /// Channel handler. Receives a JSON-stringified `{plugin, module, method, args}`
  /// and returns a JSON-stringified response. Errors are returned as
  /// `{error: 'message'}`.
  Future<String> dispatch(String payloadJson) async {
    try {
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
      final plugin = payload['plugin'] as String;
      final module = payload['module'] as String;
      final method = payload['method'] as String;
      final args = (payload['args'] as List?) ?? const [];

      final result = await _route(plugin, module, method, args);
      return jsonEncode({'value': result});
    } catch (e) {
      return jsonEncode({'error': e.toString()});
    }
  }

  Future<Object?> _route(
    String plugin,
    String module,
    String method,
    List<dynamic> args,
  ) async {
    switch (module) {
      case 'log':
        log.handle(plugin, method, args.first as String);
        return null;
      case 'http':
        if (method != 'fetch') {
          throw StateError('http: unknown method $method');
        }
        return http.fetch(args[0] as String, args[1] as Map<String, dynamic>);
      case 'storage':
        switch (method) {
          case 'get':
            return storage.get(plugin, args[0] as String);
          case 'set':
            await storage.set(plugin, args[0] as String, args[1] as String);
            return null;
          case 'delete':
            await storage.delete(plugin, args[0] as String);
            return null;
          default:
            throw StateError('storage: unknown method $method');
        }
      case 'json':
        switch (method) {
          case 'parse':
            return JsonHost.parse(args[0] as String);
          case 'stringify':
            return JsonHost.stringify(args[0]);
          default:
            throw StateError('json: unknown method $method');
        }
      case 'url':
        if (method != 'absolute') throw StateError('url: unknown method $method');
        return UrlHost.absolute(args[0] as String, args[1] as String);
      case 'crypto':
        switch (method) {
          case 'sha256Hex':
            return CryptoHost.sha256Hex(args[0] as String);
          case 'md5Hex':
            return CryptoHost.md5Hex(args[0] as String);
          case 'hmacHex':
            return CryptoHost.hmacHex(
              args[0] as String,
              (args[1] as List).cast<int>(),
              (args[2] as List).cast<int>(),
            );
          case 'base64Encode':
            return CryptoHost.base64Encode(args[0] as String);
          case 'aesDecryptCbc':
            final out = CryptoHost.aesDecryptCbc(
              Uint8List.fromList((args[0] as List).cast<int>()),
              Uint8List.fromList((args[1] as List).cast<int>()),
              Uint8List.fromList((args[2] as List).cast<int>()),
            );
            return out.toList(); // JSON-friendly
          default:
            throw StateError('crypto: unknown method $method');
        }
      case 'html':
        return _routeHtml(method, args);
      default:
        throw StateError('unknown host module: $module');
    }
  }

  Object? _routeHtml(String method, List<dynamic> args) {
    switch (method) {
      case 'parse':
        final doc = HtmlHost.parse(args[0] as String);
        final h = ++_htmlCounter;
        _htmlDocs[h] = doc;
        return {'__doc': h};
      case 'doc.find':
        final doc = _htmlDocs[args[0] as int]!;
        final results = doc.find(args[1] as String);
        return _registerElements(results);
      case 'doc.querySelector':
        final doc = _htmlDocs[args[0] as int]!;
        final el = doc.querySelector(args[1] as String);
        if (el == null) return null;
        final h = ++_htmlCounter;
        _htmlElements[h] = el;
        return {'__el': h};
      case 'el.find':
        final el = _htmlElements[args[0] as int]!;
        final results = el.find(args[1] as String);
        return _registerElements(results);
      case 'el.text':
        return _htmlElements[args[0] as int]!.text();
      case 'el.html':
        return _htmlElements[args[0] as int]!.html();
      case 'el.attr':
        return _htmlElements[args[0] as int]!.attr(args[1] as String);
      case 'release':
        // Plugin tells us it's done with a doc/element handle. Best-effort GC.
        _htmlDocs.remove(args[0]);
        _htmlElements.remove(args[0]);
        return null;
      default:
        throw StateError('html: unknown method $method');
    }
  }

  List<Map<String, int>> _registerElements(List<HtmlElement> els) {
    return els.map((e) {
      final h = ++_htmlCounter;
      _htmlElements[h] = e;
      return {'__el': h};
    }).toList();
  }
}
