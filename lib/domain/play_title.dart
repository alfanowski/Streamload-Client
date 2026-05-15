// lib/domain/play_title.dart
import '../player/session.dart';
import '../plugins/plugin.dart';

/// Orchestrator that turns a (tmdbId, mediaType) request into a URL that
/// media_kit can open.
///
/// Strategy:
/// - **Direct (fast, default for public sources)**: when the plugin's
///   getStreams() returns a manifest with no custom headers and no DRM,
///   return the manifest URL as-is. media_kit fetches it directly. No
///   session, no proxy. Maximally compatible across platforms (Windows,
///   Linux, mobile in the future) since it bypasses the loopback HTTP
///   indirection entirely.
/// - **Proxied (slow, only when needed)**: when the upstream requires
///   custom headers (Referer/Cookie for scraping plugins) or DRM
///   decryption, register a PlaybackSession and return the local proxy URL
///   `http://127.0.0.1:<port>/master/<sid>.m3u8`. The proxy injects the
///   headers, decrypts AES segments, and caches.
///
/// The proxy is an opt-in optimization for hard cases, NOT a mandatory
/// indirection — keeping it that way prevents the proxy's quirks from
/// turning into a single point of failure for ALL playback.
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
    final manifestUrl = getStreamsResult['manifest_url'] as String;
    final isDrm = getStreamsResult['is_drm'] == true;

    // Direct mode: no headers, no DRM → media_kit handles the upstream
    // natively. Skip the proxy entirely. This is the common case for public
    // CDN streams (Apple BipBop, etc.) and the most compatible path.
    if (headers.isEmpty && !isDrm) {
      return manifestUrl;
    }

    // Proxied mode: scraping plugins need Referer/Cookie injection or AES key
    // proxying. Register a session and return the loopback master URL.
    final session = PlaybackSession.create(
      tmdbId: tmdbId,
      mediaType: mediaType,
      pluginShortName: plugin.meta.shortName,
      upstreamMasterUrl: manifestUrl,
      upstreamHeaders: headers,
      isDrm: isDrm,
      drmKeys: getStreamsResult['drm_keys'] as Map<String, dynamic>?,
    );
    registry.put(session);
    return '$proxyBaseUrl/master/${session.id}.m3u8';
  }
}
