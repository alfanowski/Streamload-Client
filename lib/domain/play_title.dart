// lib/domain/play_title.dart
import '../infra/logger.dart';
import '../player/session.dart';
import '../plugins/plugin.dart';

final _log = Logger('play.controller');

/// Bridges the TMDB-anchored client catalog and a plugin's own catalog.
///
/// The flow for every playback request:
///   1. Resolve TMDB metadata for `tmdbId` → `TitleHint(title, year)`.
///   2. Ask the plugin to `search(title)` → list of plugin-internal entries.
///   3. Pick the best match (exact-title prefer + year if available).
///   4. For movies: `plugin.getStreams(entry)`.
///      For TV episodes: `plugin.getSeasons(entry)` → match season →
///      `plugin.getEpisodes(season)` → match episode → `plugin.getStreams(ep)`.
///   5. If the result needs custom headers or DRM, register a session and
///      route through the local proxy. Otherwise hand the URL straight to
///      media_kit (direct mode).
///
/// The plugin contract requires `target` to be a MediaEntry / Episode the
/// plugin itself returned — NOT a raw tmdb_id. This controller is what
/// enforces that contract from the TMDB-shaped UI side.

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
    required this.pluginFor,
    required this.resolveTitle,
  });

  final PlaybackSessionRegistry registry;
  final String proxyBaseUrl;
  final Plugin? Function(({int tmdbId, String mediaType})) pluginFor;
  final TitleResolver resolveTitle;

  Future<String> startMovie({required int tmdbId}) async {
    final plugin = pluginFor((tmdbId: tmdbId, mediaType: 'movie'));
    if (plugin == null) {
      throw StateError('Nessun plugin disponibile per questo titolo.');
    }
    final hint = await resolveTitle(tmdbId, 'movie');
    _log.info('startMovie tmdb=$tmdbId title="${hint.title}" year=${hint.year}'
        ' plugin=${plugin.meta.shortName}');
    final entry = await _resolvePluginEntry(plugin, hint, 'movie');
    if (entry == null) {
      throw StateError(
          'Il plugin ${plugin.meta.shortName} non trova "${hint.title}".');
    }
    final result = await plugin.getStreams(entry);
    return _registerAndUrl(plugin, tmdbId, 'movie', result);
  }

  Future<String> startEpisode({
    required int tmdbId,
    required int season,
    required int episode,
  }) async {
    final plugin = pluginFor((tmdbId: tmdbId, mediaType: 'tv'));
    if (plugin == null) {
      throw StateError('Nessun plugin disponibile per questa serie.');
    }
    final hint = await resolveTitle(tmdbId, 'tv');
    _log.info('startEpisode tmdb=$tmdbId title="${hint.title}" year=${hint.year}'
        ' s${season}e$episode plugin=${plugin.meta.shortName}');
    final entry = await _resolvePluginEntry(plugin, hint, 'tv');
    if (entry == null) {
      throw StateError(
          'Il plugin ${plugin.meta.shortName} non trova "${hint.title}".');
    }
    // Walk seasons → episodes → pick the one matching (season, episode).
    final seasons = await plugin.getSeasons(entry);
    final seasonMatch = seasons.firstWhere(
      (s) => (s['number'] as num?)?.toInt() == season,
      orElse: () => <String, dynamic>{},
    );
    if (seasonMatch.isEmpty) {
      throw StateError('Stagione $season non trovata su ${plugin.meta.shortName}.');
    }
    final episodes = await plugin.getEpisodes(seasonMatch);
    final epMatch = episodes.firstWhere(
      (e) => (e['number'] as num?)?.toInt() == episode,
      orElse: () => <String, dynamic>{},
    );
    if (epMatch.isEmpty) {
      throw StateError('Episodio $episode (S$season) non trovato.');
    }
    final result = await plugin.getStreams(epMatch);
    return _registerAndUrl(plugin, tmdbId, 'tv', result);
  }

  /// Run plugin.search(title) and pick the best match for [hint].
  /// Preference order:
  ///   1. exact case-insensitive title match + year ±1
  ///   2. exact case-insensitive title match (any year)
  ///   3. first result of the matching type
  Future<Map<String, dynamic>?> _resolvePluginEntry(
    Plugin plugin,
    TitleHint hint,
    String mediaType,
  ) async {
    final List<Map<String, dynamic>> results;
    try {
      results = await plugin.search(hint.title);
    } catch (e) {
      _log.error('plugin ${plugin.meta.shortName} search failed: $e');
      rethrow;
    }
    _log.info('plugin search "${hint.title}" → ${results.length} result(s)');
    if (results.isEmpty) return null;

    final norm = hint.title.toLowerCase().trim();
    final typed =
        results.where((r) => (r['type'] as String?) == mediaType).toList();
    final pool = typed.isNotEmpty ? typed : results;

    // Tier 1: exact title + close year.
    if (hint.year != null) {
      for (final r in pool) {
        final title = (r['title'] as String? ?? '').toLowerCase().trim();
        final year = r['year'];
        if (title == norm && year is num && (year.toInt() - hint.year!).abs() <= 1) {
          _log.info('match tier-1 (title+year): ${r['title']} (${r['year']})');
          return r;
        }
      }
    }
    // Tier 2: exact title.
    for (final r in pool) {
      final title = (r['title'] as String? ?? '').toLowerCase().trim();
      if (title == norm) {
        _log.info('match tier-2 (title only): ${r['title']} (${r['year']})');
        return r;
      }
    }
    // Tier 3: first of correct type.
    final fallback = pool.first;
    _log.warn('match tier-3 (first result, weak): ${fallback['title']}');
    return fallback;
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
