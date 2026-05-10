// test/player/proxy_test.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:streamload_client/player/proxy.dart';
import 'package:streamload_client/player/session.dart';

void main() {
  late LocalProxyServer proxy;
  late PlaybackSessionRegistry registry;

  setUp(() async {
    registry = PlaybackSessionRegistry(ttl: const Duration(hours: 1));
    proxy = await LocalProxyServer.start(registry: registry);
  });

  tearDown(() async {
    await proxy.stop();
  });

  test('binds on 127.0.0.1 with system-assigned port', () {
    expect(proxy.port, greaterThan(0));
    expect(proxy.baseUrl, startsWith('http://127.0.0.1:'));
  });

  test('GET /health returns 200 ok', () async {
    final resp = await http.get(Uri.parse('${proxy.baseUrl}/health'));
    expect(resp.statusCode, 200);
    expect(resp.body, 'ok');
  });

  test('unknown route returns 404', () async {
    final resp = await http.get(Uri.parse('${proxy.baseUrl}/nope'));
    expect(resp.statusCode, 404);
  });

  group('GET /master/{sid}.m3u8', () {
    test('404 if session unknown', () async {
      final resp =
          await http.get(Uri.parse('${proxy.baseUrl}/master/unknown.m3u8'));
      expect(resp.statusCode, 404);
    });

    test('200 + rewritten body when session exists', () async {
      final fixtureServer =
          await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      fixtureServer.listen((req) {
        req.response
          ..statusCode = 200
          ..write('''
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=1200000,RESOLUTION=854x480
http://127.0.0.1:${fixtureServer.port}/v?rendition=480p
''')
          ..close();
      });
      addTearDown(() => fixtureServer.close(force: true));

      final s = PlaybackSession.create(
        tmdbId: 1,
        mediaType: 'movie',
        pluginShortName: 'p',
        upstreamMasterUrl:
            'http://127.0.0.1:${fixtureServer.port}/master',
        upstreamHeaders: const {},
      );
      registry.put(s);

      final resp = await http
          .get(Uri.parse('${proxy.baseUrl}/master/${s.id}.m3u8'));
      expect(resp.statusCode, 200);
      expect(resp.body, contains('/variant/${s.id}/video/480p.m3u8'));
      expect(resp.headers['content-type'], contains('mpegurl'));
    });
  });

  test('GET /variant/{sid}/video/{label}.m3u8 fetches + rewrites', () async {
    late HttpServer fixture;
    fixture = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    fixture.listen((req) {
      if (req.uri.path == '/master') {
        req.response
          ..statusCode = 200
          ..write('''
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=1200000,RESOLUTION=854x480
http://127.0.0.1:${fixture.port}/v?rendition=480p
''')
          ..close();
      } else {
        req.response
          ..statusCode = 200
          ..write('''
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:6
#EXTINF:5.5,
http://127.0.0.1:${fixture.port}/seg-0.ts
#EXT-X-ENDLIST
''')
          ..close();
      }
    });
    addTearDown(() => fixture.close(force: true));

    final s = PlaybackSession.create(
      tmdbId: 1,
      mediaType: 'movie',
      pluginShortName: 'p',
      upstreamMasterUrl: 'http://127.0.0.1:${fixture.port}/master',
      upstreamHeaders: const {},
    );
    registry.put(s);

    // Hit master first to populate renditionUpstream.
    await http.get(Uri.parse('${proxy.baseUrl}/master/${s.id}.m3u8'));

    final resp = await http.get(
      Uri.parse('${proxy.baseUrl}/variant/${s.id}/video/480p.m3u8'),
    );
    expect(resp.statusCode, 200);
    expect(resp.body, contains('/variant/${s.id}/seg/480p/0.ts'));
  });

  test('GET /key/{sid}/{rendition} proxies AES-128 key bytes', () async {
    // 16-byte fake key.
    final fakeKey = Uint8List(16)..fillRange(0, 16, 0xAB);

    late HttpServer fixture;
    fixture = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    fixture.listen((req) {
      if (req.uri.path == '/master') {
        req.response
          ..statusCode = 200
          ..write('''
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=1200000,RESOLUTION=854x480
http://127.0.0.1:${fixture.port}/v?rendition=480p
''')
          ..close();
      } else if (req.uri.path == '/v') {
        req.response
          ..statusCode = 200
          ..write('''
#EXTM3U
#EXT-X-KEY:METHOD=AES-128,URI="http://127.0.0.1:${fixture.port}/key.bin",IV=0x00000000000000000000000000000001
#EXTINF:5.5,
http://127.0.0.1:${fixture.port}/seg-0.ts
#EXT-X-ENDLIST
''')
          ..close();
      } else if (req.uri.path == '/key.bin') {
        req.response
          ..statusCode = 200
          ..headers.contentType = ContentType.binary
          ..add(fakeKey)
          ..close();
      } else {
        req.response
          ..statusCode = 404
          ..close();
      }
    });
    addTearDown(() => fixture.close(force: true));

    final s = PlaybackSession.create(
      tmdbId: 1,
      mediaType: 'movie',
      pluginShortName: 'p',
      upstreamMasterUrl: 'http://127.0.0.1:${fixture.port}/master',
      upstreamHeaders: const {},
    );
    registry.put(s);

    // Trigger master → variant to populate keyUrlByRendition.
    await http.get(Uri.parse('${proxy.baseUrl}/master/${s.id}.m3u8'));
    await http
        .get(Uri.parse('${proxy.baseUrl}/variant/${s.id}/video/480p.m3u8'));

    final keyResp =
        await http.get(Uri.parse('${proxy.baseUrl}/key/${s.id}/480p'));
    expect(keyResp.statusCode, 200);
    expect(keyResp.bodyBytes.length, 16);
    expect(keyResp.bodyBytes, equals(fakeKey));
  });

  test('GET /seg/{sid}/{rendition}/{n}.ts returns segment bytes', () async {
    // 1 KB fake segment.
    final fakeSegment = Uint8List(1024)..fillRange(0, 1024, 0x47);

    late HttpServer fixture;
    fixture = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    fixture.listen((req) {
      if (req.uri.path == '/master') {
        req.response
          ..statusCode = 200
          ..write('''
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=1200000,RESOLUTION=854x480
http://127.0.0.1:${fixture.port}/v?rendition=480p
''')
          ..close();
      } else if (req.uri.path == '/v') {
        req.response
          ..statusCode = 200
          ..write('''
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:6
#EXTINF:5.5,
http://127.0.0.1:${fixture.port}/seg-0.ts
#EXT-X-ENDLIST
''')
          ..close();
      } else if (req.uri.path == '/seg-0.ts') {
        req.response
          ..statusCode = 200
          ..headers.contentType =
              ContentType('video', 'mp2t')
          ..add(fakeSegment)
          ..close();
      } else {
        req.response
          ..statusCode = 404
          ..close();
      }
    });
    addTearDown(() => fixture.close(force: true));

    final s = PlaybackSession.create(
      tmdbId: 1,
      mediaType: 'movie',
      pluginShortName: 'p',
      upstreamMasterUrl: 'http://127.0.0.1:${fixture.port}/master',
      upstreamHeaders: const {},
    );
    registry.put(s);

    // Prime master + variant to populate segmentUrlsByRendition.
    await http.get(Uri.parse('${proxy.baseUrl}/master/${s.id}.m3u8'));
    await http
        .get(Uri.parse('${proxy.baseUrl}/variant/${s.id}/video/480p.m3u8'));

    final segResp = await http
        .get(Uri.parse('${proxy.baseUrl}/seg/${s.id}/480p/0.ts'));
    expect(segResp.statusCode, 200);
    expect(segResp.bodyBytes.length, 1024);
    expect(segResp.bodyBytes, equals(fakeSegment));
  });
}
