// lib/domain/play_title.dart
import '../player/session.dart';
import '../plugins/plugin.dart';

/// Orchestrator that turns a (tmdbId, mediaType) request into a proxy master
/// URL by calling the appropriate plugin, registering a session, and returning
/// the rewritten `http://127.0.0.1:<port>/master/<sid>.m3u8` URL.
class PlayController {
  PlayController({
    required this.registry,
    required this.proxyBaseUrl,
    required this.pluginFor,
  });

  final PlaybackSessionRegistry registry;
  final String proxyBaseUrl;

  /// Strategy for picking a plugin: tested by injecting a synthetic chooser.
  /// Real implementation will iterate plugins by capability + ranker.
  final Plugin? Function(({int tmdbId, String mediaType})) pluginFor;

  Future<String> startMovie({required int tmdbId}) async {
    final plugin = pluginFor((tmdbId: tmdbId, mediaType: 'movie'));
    if (plugin == null) {
      throw StateError('no plugin can satisfy tmdbId=$tmdbId');
    }
    final result = await plugin.getStreams({
      'tmdb_id': tmdbId,
      'media_type': 'movie',
    });
    return _registerAndUrl(plugin, tmdbId, 'movie', result);
  }

  Future<String> startEpisode({
    required int tmdbId,
    required int season,
    required int episode,
  }) async {
    final plugin = pluginFor((tmdbId: tmdbId, mediaType: 'tv'));
    if (plugin == null) {
      throw StateError('no plugin can satisfy tmdbId=$tmdbId s${season}e$episode');
    }
    final result = await plugin.getStreams({
      'tmdb_id': tmdbId,
      'media_type': 'tv',
      'season': season,
      'episode': episode,
    });
    return _registerAndUrl(plugin, tmdbId, 'tv', result);
  }

  String _registerAndUrl(
    Plugin plugin,
    int tmdbId,
    String mediaType,
    Map<String, dynamic> getStreamsResult,
  ) {
    final headers = (getStreamsResult['headers'] as Map?)
            ?.cast<String, dynamic>()
            .map((k, v) => MapEntry(k, v.toString())) ??
        const <String, String>{};
    final session = PlaybackSession.create(
      tmdbId: tmdbId,
      mediaType: mediaType,
      pluginShortName: plugin.meta.shortName,
      upstreamMasterUrl: getStreamsResult['manifest_url'] as String,
      upstreamHeaders: headers,
      isDrm: getStreamsResult['is_drm'] == true,
      drmKeys: getStreamsResult['drm_keys'] as Map<String, dynamic>?,
    );
    registry.put(session);
    return '$proxyBaseUrl/master/${session.id}.m3u8';
  }
}
