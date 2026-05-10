// lib/player/proxy.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'rewriter.dart';
import 'session.dart';

/// HTTP proxy bound to 127.0.0.1 on a system-assigned port. Exposes the
/// four HLS routes consumed by media_kit + downstream subroutines.
/// Lifecycle: `start()` returns a running instance; `stop()` closes the
/// HttpServer and waits for in-flight requests to complete.
class LocalProxyServer {
  LocalProxyServer._(this._server, this.registry, this.dio)
      : port = _server.port,
        baseUrl = 'http://127.0.0.1:${_server.port}';

  static Future<LocalProxyServer> start({
    required PlaybackSessionRegistry registry,
    Dio? dio,
  }) async {
    final dioInstance = dio ?? Dio();
    final router = Router()
      ..get('/health', (shelf.Request _) => shelf.Response.ok('ok'))
      ..get('/master/<sid>.m3u8', (shelf.Request req, String sid) async {
        final session = registry.get(sid, touch: true);
        if (session == null) return shelf.Response.notFound('unknown session');
        try {
          final resp = await dioInstance.get<String>(
            session.upstreamMasterUrl,
            options: Options(
              responseType: ResponseType.plain,
              headers: session.upstreamHeaders,
            ),
          );
          final result = Rewriter.rewriteMaster(
            resp.data ?? '',
            basePath: '/variant/$sid',
          );
          session.renditionUpstream.addAll(result.renditionUrls);
          return shelf.Response.ok(result.body, headers: {
            'content-type': 'application/vnd.apple.mpegurl',
          });
        } on DioException catch (e) {
          return shelf.Response.internalServerError(
              body: 'upstream: ${e.message}');
        }
      })
      ..get('/variant/<sid>/video/<label>.m3u8',
          (shelf.Request req, String sid, String label) async {
        final session = registry.get(sid, touch: true);
        if (session == null) return shelf.Response.notFound('unknown session');
        final upstream = session.renditionUpstream[label];
        if (upstream == null) {
          return shelf.Response.notFound('unknown rendition $label');
        }
        try {
          final resp = await dioInstance.get<String>(
            upstream,
            options: Options(
              responseType: ResponseType.plain,
              headers: session.upstreamHeaders,
            ),
          );
          final result = Rewriter.rewriteMedia(
            resp.data ?? '',
            rendition: label,
            basePath: '/variant/$sid',
          );
          if (result.keyUrl != null) {
            session.keyUrlByRendition[label] = result.keyUrl!;
          }
          session.segmentUrlsByRendition[label] = result.segmentUrls;
          return shelf.Response.ok(result.body, headers: {
            'content-type': 'application/vnd.apple.mpegurl',
          });
        } on DioException catch (e) {
          return shelf.Response.internalServerError(
              body: 'upstream: ${e.message}');
        }
      })
      ..get('/key/<sid>/<label>',
          (shelf.Request req, String sid, String label) async {
        final session = registry.get(sid, touch: true);
        if (session == null) return shelf.Response.notFound('unknown session');
        final keyUrl = session.keyUrlByRendition[label];
        if (keyUrl == null) {
          return shelf.Response.notFound('no key for rendition $label');
        }
        try {
          final resp = await dioInstance.get<List<int>>(
            keyUrl,
            options: Options(
              responseType: ResponseType.bytes,
              headers: session.upstreamHeaders,
            ),
          );
          final keyBytes = Uint8List.fromList(resp.data ?? const []);
          // Store for segment decryption.
          session.keyBytesByRendition[label] = keyBytes;
          return shelf.Response.ok(
            keyBytes,
            headers: {'content-type': 'application/octet-stream'},
          );
        } on DioException catch (e) {
          return shelf.Response.internalServerError(
              body: 'upstream: ${e.message}');
        }
      });
    final server = await shelf_io.serve(
      router.call,
      InternetAddress.loopbackIPv4,
      0,
    );
    return LocalProxyServer._(server, registry, dioInstance);
  }

  final HttpServer _server;
  final PlaybackSessionRegistry registry;
  final Dio dio;
  final int port;
  final String baseUrl;

  Future<void> stop() async {
    await _server.close(force: true);
  }
}
