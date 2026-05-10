// lib/state/play_controller_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/play_title.dart';
import '../plugins/plugin.dart';
import 'local_proxy_provider.dart';
import 'playback_session_registry_provider.dart';
import 'plugin_runtime_provider.dart';

/// Wires together the local proxy, session registry, and plugin runtime into
/// a [PlayController] ready to start playback.
///
/// Plugin selection strategy: return the FIRST plugin whose
/// `capabilities` list contains the requested `mediaType`. Returns `null`
/// if no plugin satisfies the request.
final playControllerProvider = FutureProvider<PlayController>((ref) async {
  final proxy = await ref.watch(localProxyProvider.future);
  final registry = ref.watch(playbackSessionRegistryProvider);
  final runtime = await ref.watch(pluginRuntimeProvider.future);

  Plugin? pluginFor(({int tmdbId, String mediaType}) target) {
    for (final plugin in runtime.all) {
      if (plugin.meta.capabilities.contains(target.mediaType)) {
        return plugin;
      }
    }
    return null;
  }

  return PlayController(
    registry: registry,
    proxyBaseUrl: proxy.baseUrl,
    pluginFor: pluginFor,
  );
});
