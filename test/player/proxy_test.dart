// test/player/proxy_test.dart
import 'dart:io';

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
}
