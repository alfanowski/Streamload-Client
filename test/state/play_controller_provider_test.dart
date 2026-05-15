// test/state/play_controller_provider_test.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/domain/play_title.dart';
import 'package:streamload_client/player/cache/disk_cache.dart';
import 'package:streamload_client/player/cache/ram_buffer.dart';
import 'package:streamload_client/player/proxy.dart';
import 'package:streamload_client/player/segment_fetcher.dart';
import 'package:streamload_client/plugins/meta.dart';
import 'package:streamload_client/plugins/plugin.dart';
import 'package:streamload_client/plugins/routing/router.dart';
import 'package:streamload_client/plugins/runtime.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_api.dart';
import 'package:streamload_client/domain/models/catalog_item.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/local_proxy_provider.dart';
import 'package:streamload_client/state/play_controller_provider.dart';
import 'package:streamload_client/state/playback_session_registry_provider.dart';
import 'package:streamload_client/state/plugin_runtime_provider.dart';

class _PluginRuntimeMock extends Mock implements PluginRuntime {}
class _PluginMock extends Mock implements Plugin {}
class _CatalogApiMock extends Mock implements CatalogApi {}

void main() {
  late Directory tmpDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('streamload_test_pc_');
    registerFallbackValue(<String, dynamic>{});
  });

  tearDown(() => tmpDir.deleteSync(recursive: true));

  /// Builds a ProviderContainer with:
  /// - a real LocalProxyServer using a temp disk cache
  /// - a mock PluginRuntime
  Future<({ProviderContainer container, LocalProxyServer proxy})>
      buildContainer(_PluginRuntimeMock mockRuntime) async {
    // Start a real proxy to get a real port / baseUrl.
    final fetcher = SegmentFetcher(
      ram: RamRingBuffer(capacity: 30),
      disk: DiskSegmentCache(
        directory: tmpDir.path,
        sizeLimitBytes: 30 * 1024 * 1024 * 1024,
      ),
      dio: Dio(),
    );
    final catalogApi = _CatalogApiMock();
    when(() => catalogApi.get(any(), mediaType: any(named: 'mediaType')))
        .thenAnswer((_) async => const CatalogItemResponse(
              tmdbId: 1,
              mediaType: 'movie',
              title: 'Test',
              year: 2020,
            ));
    final container = ProviderContainer(overrides: [
      pluginRuntimeProvider.overrideWith((_) async => mockRuntime),
      catalogApiProvider.overrideWith((_) async => catalogApi),
      localProxyProvider.overrideWith((ref) async {
        final reg = ref.watch(playbackSessionRegistryProvider);
        final server = await LocalProxyServer.start(
          registry: reg,
          fetcher: fetcher,
        );
        ref.onDispose(server.stop);
        return server;
      }),
    ]);

    final proxy = await container.read(localProxyProvider.future);
    return (container: container, proxy: proxy);
  }

  test('playControllerProvider resolves to a PlayController', () async {
    final mockRuntime = _PluginRuntimeMock();
    when(() => mockRuntime.all).thenReturn([]);

    final (:container, proxy: _) = await buildContainer(mockRuntime);
    addTearDown(container.dispose);

    final controller = await container.read(playControllerProvider.future);
    expect(controller, isA<PlayController>());
    expect(controller.router, isA<ProviderRouter>());
  });

  test('ProviderRouter.pluginsForType selects by exact capability', () async {
    final moviePlugin = _PluginMock();
    when(() => moviePlugin.meta).thenReturn(const PluginMeta(
      shortName: 'movie_plugin',
      displayName: 'Movie Plugin',
      version: '1.0.0',
      apiVersion: 1,
      capabilities: ['movie'],
    ));

    final tvPlugin = _PluginMock();
    when(() => tvPlugin.meta).thenReturn(const PluginMeta(
      shortName: 'tv_plugin',
      displayName: 'TV Plugin',
      version: '1.0.0',
      apiVersion: 1,
      capabilities: ['tv'],
    ));

    final mockRuntime = _PluginRuntimeMock();
    when(() => mockRuntime.all).thenReturn([moviePlugin, tvPlugin]);

    final router = ProviderRouter(runtime: mockRuntime);

    expect(router.pluginsForType('movie'), [moviePlugin]);
    expect(router.pluginsForType('tv'), [tvPlugin]);
    expect(router.pluginsForType('anime'), isEmpty);
  });

  test('ProviderRouter.pluginsForType matches by capability prefix', () async {
    // A plugin that only declares "movie:anime" should still be selected
    // for the generic mediaType "movie" (and likewise tv:anime → tv).
    final animePlugin = _PluginMock();
    when(() => animePlugin.meta).thenReturn(const PluginMeta(
      shortName: 'au',
      displayName: 'AnimeUnity',
      version: '1.0.0',
      apiVersion: 1,
      capabilities: ['movie:anime', 'tv:anime'],
    ));

    final multiPlugin = _PluginMock();
    when(() => multiPlugin.meta).thenReturn(const PluginMeta(
      shortName: 'sc',
      displayName: 'StreamingCommunity',
      version: '1.0.2',
      apiVersion: 1,
      capabilities: ['movie', 'tv', 'movie:anime', 'tv:anime'],
    ));

    final mockRuntime = _PluginRuntimeMock();
    when(() => mockRuntime.all).thenReturn([animePlugin, multiPlugin]);

    final router = ProviderRouter(runtime: mockRuntime);

    // For "movie" we get both: au via "movie:anime" prefix, sc via exact.
    expect(
      router.pluginsForType('movie').map((p) => p.meta.shortName),
      ['au', 'sc'],
    );
    expect(
      router.pluginsForType('tv').map((p) => p.meta.shortName),
      ['au', 'sc'],
    );
  });

  test('proxyBaseUrl in controller matches the running proxy', () async {
    final mockRuntime = _PluginRuntimeMock();
    when(() => mockRuntime.all).thenReturn([]);

    final (:container, proxy: proxy) = await buildContainer(mockRuntime);
    addTearDown(container.dispose);

    final controller = await container.read(playControllerProvider.future);
    expect(controller.proxyBaseUrl, equals(proxy.baseUrl));
  });
}
