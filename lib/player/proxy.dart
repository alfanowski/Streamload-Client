// lib/player/proxy.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../infra/logger.dart';
import 'drm.dart';
import 'rewriter.dart';
import 'segment_fetcher.dart';
import 'session.dart';

final _log = Logger('player.proxy');

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
        _log.info('master fetch ← ${session.upstreamMasterUrl}'
            ' (headers: ${session.upstreamHeaders.keys.join(",")})');
        try {
          final resp = await dioInstance.get<String>(
            session.upstreamMasterUrl,
            options: Options(
              responseType: ResponseType.plain,
              headers: session.upstreamHeaders,
            ),
          );
          if (resp.statusCode != 200) {
            _log.error('master upstream status ${resp.statusCode} '
                'for ${session.upstreamMasterUrl} body: '
                '${(resp.data ?? '').toString().substring(0, 200)}');
            return shelf.Response.internalServerError(
                body: 'upstream status ${resp.statusCode}');
          }
          final result = Rewriter.rewriteMaster(
            resp.data ?? '',
            basePath: '/variant/$sid',
          );
          // Master playlists from real HLS sources (Apple BipBop, etc.) use
          // RELATIVE rendition URLs. Resolve them against the master URL so
          // the variant route can dio.get them directly.
          final masterUri = Uri.parse(session.upstreamMasterUrl);
          session.renditionUpstream.addAll({
            for (final entry in result.renditionUrls.entries)
              entry.key: masterUri.resolve(entry.value).toString(),
          });
          return shelf.Response.ok(result.body, headers: {
            'content-type': 'application/vnd.apple.mpegurl',
          });
        } on DioException catch (e, st) {
          _log.error(
              'master fetch failed: type=${e.type} status=${e.response?.statusCode}'
              ' message="${e.message}" url=${session.upstreamMasterUrl}',
              e,
              st);
          return shelf.Response.internalServerError(
              body: 'upstream: type=${e.type} status=${e.response?.statusCode} msg=${e.message}');
        } catch (e, st) {
          _log.error('master fetch unexpected error: $e', e, st);
          return shelf.Response.internalServerError(body: 'unexpected: $e');
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
          // Segments and EXT-X-KEY are usually relative to the VARIANT
          // playlist URL (not the master). Resolve them now so the seg+key
          // routes can dio.get them.
          final variantUri = Uri.parse(upstream);
          if (result.keyUrl != null) {
            session.keyUrlByRendition[label] =
                variantUri.resolve(result.keyUrl!).toString();
          }
          session.segmentUrlsByRendition[label] = [
            for (final s in result.segmentUrls)
              variantUri.resolve(s).toString(),
          ];
          return shelf.Response.ok(result.body, headers: {
            'content-type': 'application/vnd.apple.mpegurl',
          });
        } on DioException catch (e) {
          return shelf.Response.internalServerError(
              body: 'upstream: ${e.message}');
        }
      })
      // Audio variant playlists. Rewriter emits these under /variant/<sid>/audio/<lang>.m3u8
      // when the master has EXT-X-MEDIA TYPE=AUDIO entries (Apple BipBop does).
      // Handler mirrors the video variant handler, keyed by lang instead of label.
      ..get('/variant/<sid>/audio/<lang>.m3u8',
          (shelf.Request req, String sid, String lang) async {
        final session = registry.get(sid, touch: true);
        if (session == null) return shelf.Response.notFound('unknown session');
        final upstream = session.renditionUpstream['audio:$lang'];
        if (upstream == null) {
          return shelf.Response.notFound('unknown audio lang $lang');
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
            rendition: 'audio_$lang',
            basePath: '/variant/$sid',
          );
          final audioUri = Uri.parse(upstream);
          session.segmentUrlsByRendition['audio_$lang'] = [
            for (final s in result.segmentUrls)
              audioUri.resolve(s).toString(),
          ];
          return shelf.Response.ok(result.body, headers: {
            'content-type': 'application/vnd.apple.mpegurl',
          });
        } on DioException catch (e) {
          return shelf.Response.internalServerError(
              body: 'upstream: ${e.message}');
        }
      })
      // Segment + key paths live UNDER /variant/<sid>/ to match what the
      // rewriter emits inside variant playlists (basePath = '/variant/<sid>').
      ..get('/variant/<sid>/key/<label>',
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
      ..get('/variant/<sid>/seg/<label>/<n|[0-9]+>.ts',
          (shelf.Request req, String sid, String label, String n) async {
        final session = registry.get(sid, touch: true);
        if (session == null) return shelf.Response.notFound('unknown session');
        final urls = session.segmentUrlsByRendition[label];
        final idx = int.tryParse(n);
        if (urls == null || idx == null || idx < 0 || idx >= urls.length) {
          return shelf.Response.notFound('unknown segment $label/$n');
        }
        try {
          final Uint8List raw;
          if (fetcherInstance == null) {
            // No fetcher injected — direct dio fallback (test paths).
            final resp = await dioInstance.get<List<int>>(
              urls[idx],
              options: Options(
                responseType: ResponseType.bytes,
                headers: session.upstreamHeaders,
              ),
            );
            raw = Uint8List.fromList(resp.data ?? const []);
          } else {
            raw = await fetcherInstance.fetch(
              urls[idx],
              headers: session.upstreamHeaders,
              decryptor: _decryptorFor(session, label),
            );
          }
          // Sniff the real container from the bytes themselves — much more
          // reliable than relying on URL extension or upstream Content-Type.
          // HLS audio segments are often AAC/M4A while video segments are TS;
          // we serve the same path shape so the type has to come from data.
          return shelf.Response.ok(raw, headers: {
            'content-type': _sniffContentType(raw),
          });
        } on Exception catch (e) {
          return shelf.Response.internalServerError(body: 'fetch: $e');
        }
      });
    // Log every request + status so we can trace media_kit's actual access
    // pattern in dev. Strip in production via a build-time flag if noisy.
    final handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests(
          logger: (msg, isError) =>
              isError ? _log.error(msg) : _log.info(msg),
        ))
        .addHandler(router.call);
    final server = await shelf_io.serve(
      handler,
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

/// Detect the container format from the first few bytes of a segment.
/// HLS variants serve a mix of MPEG-TS, raw AAC ADTS, and fMP4. Serving every
/// segment as 'video/mp2t' makes ffmpeg's demuxer reject the AAC ones with
/// 'avformat_open_input() failed' even when the bytes are valid.
String _sniffContentType(Uint8List bytes) {
  // MPEG-TS: 188-byte packets, each starts with sync byte 0x47.
  if (bytes.isNotEmpty && bytes[0] == 0x47) return 'video/mp2t';
  // AAC ADTS: starts with sync word 0xFFFx (first 12 bits are 1).
  if (bytes.length >= 2 &&
      bytes[0] == 0xFF &&
      (bytes[1] & 0xF0) == 0xF0) {
    return 'audio/aac';
  }
  // ISO BMFF / MP4 (fMP4 HLS variant): byte offset 4-7 contains 'ftyp'.
  if (bytes.length >= 8 &&
      bytes[4] == 0x66 &&
      bytes[5] == 0x74 &&
      bytes[6] == 0x79 &&
      bytes[7] == 0x70) {
    return 'video/mp4';
  }
  return 'application/octet-stream';
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
