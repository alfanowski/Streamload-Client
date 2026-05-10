// test/state/local_proxy_provider_test.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:streamload_client/player/cache/disk_cache.dart';
import 'package:streamload_client/player/cache/ram_buffer.dart';
import 'package:streamload_client/player/proxy.dart';
import 'package:streamload_client/player/segment_fetcher.dart';
import 'package:streamload_client/state/local_proxy_provider.dart';
import 'package:streamload_client/state/playback_session_registry_provider.dart';

// Helper: creates a localProxyProvider override that uses a temp dir for the
// disk cache instead of path_provider's getApplicationCacheDirectory() which
// requires a Flutter binding unavailable in plain unit tests.
ProviderContainer _containerWithTempCache(Directory tmpDir) {
  return ProviderContainer(overrides: [
    localProxyProvider.overrideWith((ref) async {
      final registry = ref.watch(playbackSessionRegistryProvider);
      final fetcher = SegmentFetcher(
        ram: RamRingBuffer(capacity: 30),
        disk: DiskSegmentCache(
          directory: tmpDir.path,
          sizeLimitBytes: 30 * 1024 * 1024 * 1024, // 30 GB
        ),
        dio: Dio(),
      );
      final server = await LocalProxyServer.start(
        registry: registry,
        fetcher: fetcher,
      );
      ref.onDispose(server.stop);
      return server;
    }),
  ]);
}

void main() {
  test('localProxyProvider starts a real server and /health returns ok', () async {
    final tmpDir = Directory.systemTemp.createTempSync('streamload_test_cache_');
    addTearDown(() => tmpDir.deleteSync(recursive: true));

    final container = _containerWithTempCache(tmpDir);
    addTearDown(container.dispose);

    final server = await container.read(localProxyProvider.future);
    expect(server, isA<LocalProxyServer>());
    expect(server.port, greaterThan(0));

    final resp = await http.get(Uri.parse('${server.baseUrl}/health'));
    expect(resp.statusCode, equals(200));
    expect(resp.body, equals('ok'));
  });

  test('localProxyProvider dispose stops the server', () async {
    final tmpDir = Directory.systemTemp.createTempSync('streamload_test_cache2_');
    addTearDown(() => tmpDir.deleteSync(recursive: true));

    final container = _containerWithTempCache(tmpDir);

    final server = await container.read(localProxyProvider.future);
    final port = server.port;

    // Dispose triggers ref.onDispose => server.stop
    container.dispose();

    // Allow the event loop to settle.
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // After the server is stopped, connecting to its port should fail.
    bool connectionRefused = false;
    try {
      await Socket.connect('127.0.0.1', port,
          timeout: const Duration(milliseconds: 200));
    } on SocketException {
      connectionRefused = true;
    }
    expect(connectionRefused, isTrue);
  });
}
