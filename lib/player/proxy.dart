// lib/player/proxy.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'drm.dart';
import 'rewriter.dart';
import 'segment_fetcher.dart';
import 'session.dart';

/// HTTP proxy bound to 127.0.0.1 on a system-assigned port. Exposes the
/// four HLS routes consumed by media_kit + downstream subroutines.
/// Lifecycle: `start()` returns a running instance; `stop()` closes the
/// HttpServer and waits for in-flight requests to complete.
class LocalProxyServer {
  LocalProxyServer._(this._server, this.registry, this.dio, this.fetcher)
      : port = _server.port,
        baseUrl = 'http://127.0.0.1:${_server.port}';

  static Future<LocalProxyServer> start({
    required PlaybackSessionRegistry registry,
    Dio? dio,
    SegmentFetcher? fetcher,
  }) async {
    final dioInstance = dio ?? Dio();
    final fetcherInstance = fetcher;
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
      })
      ..get('/seg/<sid>/<label>/<n|[0-9]+>.ts',
          (shelf.Request req, String sid, String label, String n) async {
        final session = registry.get(sid, touch: true);
        if (session == null) return shelf.Response.notFound('unknown session');
        final urls = session.segmentUrlsByRendition[label];
        final idx = int.tryParse(n);
        if (urls == null || idx == null || idx < 0 || idx >= urls.length) {
          return shelf.Response.notFound('unknown segment $label/$n');
        }
        try {
          if (fetcherInstance == null) {
            // No fetcher injected — fetch directly via dio (useful in tests
            // that don't wire up a full SegmentFetcher).
            final resp = await dioInstance.get<List<int>>(
              urls[idx],
              options: Options(
                responseType: ResponseType.bytes,
                headers: session.upstreamHeaders,
              ),
            );
            final raw = Uint8List.fromList(resp.data ?? const []);
            return shelf.Response.ok(raw,
                headers: {'content-type': 'video/mp2t'});
          }
          final raw = await fetcherInstance.fetch(
            urls[idx],
            headers: session.upstreamHeaders,
            decryptor: _decryptorFor(session, label),
          );
          return shelf.Response.ok(raw,
              headers: {'content-type': 'video/mp2t'});
        } on Exception catch (e) {
          return shelf.Response.internalServerError(body: 'fetch: $e');
        }
      });
    final server = await shelf_io.serve(
      router.call,
      InternetAddress.loopbackIPv4,
      0,
    );
    return LocalProxyServer._(server, registry, dioInstance, fetcherInstance);
  }

  final HttpServer _server;
  final PlaybackSessionRegistry registry;
  final Dio dio;
  final SegmentFetcher? fetcher;
  final int port;
  final String baseUrl;

  Future<void> stop() async {
    await _server.close(force: true);
  }
}

/// Returns a decryptor for this session+rendition or null for non-DRM streams.
///
/// For HLS AES-128 streams (is_drm = false), the player fetches the key via
/// the /key route, which stores bytes in `keyBytesByRendition`. Segments are
/// served raw — the player itself does AES-128 decryption using the key it
/// fetched.
///
/// For DRM streams (is_drm = true), `keyBytesByRendition` should be
/// pre-populated from `session.drmKeys` by the caller (PlayController) rather
/// than via the /key route — this proxy does not implement the CDM key
/// exchange.
SegmentDecryptor? _decryptorFor(PlaybackSession session, String label) {
  if (!session.isDrm) return null;
  final keyBytes = session.keyBytesByRendition[label];
  if (keyBytes == null) return null; // first segment may arrive before key
  // For HLS AES-128, IV defaults to segment number BE-encoded — for MVP
  // we use a zero IV when the playlist's EXT-X-KEY didn't specify one.
  final iv = session.ivByRendition[label] ?? Uint8List(16);
  return SegmentDrm(keyBytes: keyBytes, ivBytes: iv).decrypt;
}
