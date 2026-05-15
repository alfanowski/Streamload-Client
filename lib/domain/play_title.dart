// lib/domain/play_title.dart
import '../infra/logger.dart';
import '../player/session.dart';
import '../plugins/plugin.dart';
import '../plugins/routing/router.dart';

final _log = Logger('play.controller');

/// Bridges the TMDB-anchored client catalog and the multi-provider plugin
/// router.
///
/// The flow for every playback request:
///   1. Resolve TMDB metadata for `tmdbId` → `TitleHint(title, year)`.
///   2. Hand the hint to the router, which fans out across every plugin
///      whose capabilities cover the requested mediaType. The first plugin
///      to return a non-zero-score bundle wins.
///   3. If the bundle needs custom headers or DRM, register a playback
///      session and route through the local proxy. Otherwise hand the URL
///      straight to media_kit (direct mode).

/// Metadata the controller needs to find the right plugin entry.
class TitleHint {
  const TitleHint({required this.title, this.year});
  final String title;
  final int? year;
}

/// Strategy for resolving TMDB metadata given a tmdb_id + media_type.
typedef TitleResolver = Future<TitleHint> Function(int tmdbId, String mediaType);

class PlayController {
  PlayController({
    required this.registry,
    required this.proxyBaseUrl,
    required this.router,
    required this.resolveTitle,
  });

  final PlaybackSessionRegistry registry;
  final String proxyBaseUrl;
  final ProviderRouter router;
  final TitleResolver resolveTitle;

  Future<String> startMovie({required int tmdbId}) async {
    final hint = await resolveTitle(tmdbId, 'movie');
    _log.info(
        'startMovie tmdb=$tmdbId title="${hint.title}" year=${hint.year}');
    final resolved = await router.resolveMovieStream(
      mediaType: 'movie',
      hint: hint,
    );
    return _registerAndUrl(resolved.plugin, tmdbId, 'movie', resolved.bundle);
  }

  Future<String> startEpisode({
    required int tmdbId,
    required int season,
    required int episode,
  }) async {
    final hint = await resolveTitle(tmdbId, 'tv');
    _log.info('startEpisode tmdb=$tmdbId title="${hint.title}" '
        'year=${hint.year} s${season}e$episode');
    final resolved = await router.resolveEpisodeStream(
      mediaType: 'tv',
      hint: hint,
      season: season,
      episode: episode,
    );
    return _registerAndUrl(resolved.plugin, tmdbId, 'tv', resolved.bundle);
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

    _log.info('plugin ${plugin.meta.shortName} returned:'
        ' manifest_url=$manifestUrl'
        ' headers=${headers.keys.join(",")}'
        ' is_drm=$isDrm');

    if (headers.isEmpty && !isDrm) {
      _log.info('direct mode (no proxy hop)');
      return manifestUrl;
    }
    _log.info('proxied mode (headers/DRM present)');

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
