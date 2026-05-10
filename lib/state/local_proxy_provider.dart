// lib/state/local_proxy_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../player/cache/disk_cache.dart';
import '../player/cache/ram_buffer.dart';
import '../player/proxy.dart';
import '../player/segment_fetcher.dart';
import 'playback_session_registry_provider.dart';

/// App-wide [LocalProxyServer] singleton. Started lazily on first read and
/// automatically stopped when the provider container is disposed.
///
/// Production: the disk cache is rooted at the OS application cache directory
/// (e.g. `~/Library/Caches/com.streamload.client/` on macOS), capped at 30 GB.
/// Tests: override this provider with a temp-dir variant to avoid calling
/// `getApplicationCacheDirectory()` which requires a Flutter binding.
final localProxyProvider = FutureProvider<LocalProxyServer>((ref) async {
  final registry = ref.watch(playbackSessionRegistryProvider);

  final cacheDir = await getApplicationCacheDirectory();
  final segmentCacheDir = '${cacheDir.path}/streamload_segments';

  final fetcher = SegmentFetcher(
    ram: RamRingBuffer(capacity: 30),
    disk: DiskSegmentCache(
      directory: segmentCacheDir,
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
});
