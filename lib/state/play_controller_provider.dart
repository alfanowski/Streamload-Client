// lib/state/play_controller_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/play_title.dart';
import '../plugins/plugin.dart';
import 'api_client_provider.dart';
import 'local_proxy_provider.dart';
import 'playback_session_registry_provider.dart';
import 'plugin_runtime_provider.dart';

/// Wires together the local proxy, session registry, and plugin runtime into
/// a [PlayController] ready to start playback. Also wires the title-metadata
/// resolver that turns a tmdb_id into the plugin-search query.
final playControllerProvider = FutureProvider<PlayController>((ref) async {
  final proxy = await ref.watch(localProxyProvider.future);
  final registry = ref.watch(playbackSessionRegistryProvider);
  final runtime = await ref.watch(pluginRuntimeProvider.future);
  final catalogApi = await ref.watch(catalogApiProvider.future);

  Plugin? pluginFor(({int tmdbId, String mediaType}) target) {
    for (final plugin in runtime.all) {
      if (plugin.meta.capabilities.contains(target.mediaType)) {
        return plugin;
      }
    }
    return null;
  }

  Future<TitleHint> resolveTitle(int tmdbId, String mediaType) async {
    final item = await catalogApi.get(tmdbId, mediaType: mediaType);
    return TitleHint(title: item.title, year: item.year);
  }

  return PlayController(
    registry: registry,
    proxyBaseUrl: proxy.baseUrl,
    pluginFor: pluginFor,
    resolveTitle: resolveTitle,
  );
});
