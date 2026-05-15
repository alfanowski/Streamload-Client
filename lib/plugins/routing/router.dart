// lib/plugins/routing/router.dart
import 'dart:async';

import '../../domain/play_title.dart' show TitleHint;
import '../../infra/logger.dart';
import '../plugin.dart';
import '../runtime.dart';
import 'quality.dart';

final _log = Logger('plugins.router');

/// Result of a router decision: which plugin won, and the bundle it returned.
class ResolvedStream {
  ResolvedStream({required this.plugin, required this.bundle});
  final Plugin plugin;
  final Map<String, dynamic> bundle;
}

/// Orchestrates fan-out across all plugins whose capabilities cover the
/// requested mediaType. The first plugin to return a non-zero-score bundle
/// wins. If all plugins fail or return no match, the router throws with the
/// aggregated per-plugin error reasons.
///
/// Capability match rule: a plugin matches mediaType `X` if it declares
/// either `X` (exact) or any capability starting with `X:` (e.g. `movie`
/// matches `movie:anime`).
class ProviderRouter {
  ProviderRouter({
    required this.runtime,
    Duration? timeout,
  }) : _timeout = timeout ?? const Duration(seconds: 12);

  final PluginRuntime runtime;
  final Duration _timeout;

  /// Plugins whose capabilities cover [mediaType], in registration order.
  Iterable<Plugin> pluginsForType(String mediaType) {
    return runtime.all.where((p) {
      for (final cap in p.meta.capabilities) {
        if (cap == mediaType || cap.startsWith('$mediaType:')) return true;
      }
      return false;
    });
  }

  /// Fan-out for a movie request: every matching plugin runs
  /// search → match → getStreams in parallel. The first non-zero-score
  /// bundle within [_timeout] wins.
  Future<ResolvedStream> resolveMovieStream({
    required String mediaType,
    required TitleHint hint,
  }) {
    return _race(
      mediaType: mediaType,
      fetch: (p) async {
        final entry = await _resolveEntry(p, hint, mediaType);
        if (entry == null) return null;
        return p.getStreams(entry);
      },
    );
  }

  /// Fan-out for a TV episode request: every matching plugin runs
  /// search → match → getSeasons → getEpisodes → getStreams in parallel.
  Future<ResolvedStream> resolveEpisodeStream({
    required String mediaType,
    required TitleHint hint,
    required int season,
    required int episode,
  }) {
    return _race(
      mediaType: mediaType,
      fetch: (p) async {
        final entry = await _resolveEntry(p, hint, mediaType);
        if (entry == null) return null;

        final seasons = await p.getSeasons(entry);
        final seasonMatch = seasons.firstWhere(
          (s) => (s['number'] as num?)?.toInt() == season,
          orElse: () => const <String, dynamic>{},
        );
        if (seasonMatch.isEmpty) {
          _log.info(
              '${p.meta.shortName}: season $season not found '
              '(have: ${seasons.map((s) => s['number']).toList()})');
          return null;
        }

        final episodes = await p.getEpisodes(seasonMatch);
        final epMatch = episodes.firstWhere(
          (e) => (e['number'] as num?)?.toInt() == episode,
          orElse: () => const <String, dynamic>{},
        );
        if (epMatch.isEmpty) {
          _log.info(
              '${p.meta.shortName}: episode s${season}e$episode not found '
              '(have: ${episodes.map((e) => e['number']).toList()})');
          return null;
        }

        return p.getStreams(epMatch);
      },
    );
  }

  /// Race [plugins] in parallel: first to return a non-zero-score bundle wins.
  /// Plugins that throw or return null are tracked but don't fail the race.
  /// Throws StateError aggregating all failures if every plugin came back
  /// empty / errored / scored 0.
  Future<ResolvedStream> _race({
    required String mediaType,
    required Future<Map<String, dynamic>?> Function(Plugin) fetch,
  }) async {
    final plugins = pluginsForType(mediaType).toList();
    if (plugins.isEmpty) {
      throw StateError('Nessun plugin disponibile per $mediaType.');
    }

    final completer = Completer<ResolvedStream>();
    final errors = <String, String>{};
    var pending = plugins.length;

    void finishIfDone() {
      if (pending == 0 && !completer.isCompleted) {
        final reasons = errors.isEmpty
            ? 'nessun risultato'
            : errors.entries.map((e) => '${e.key}: ${e.value}').join(' • ');
        completer.completeError(
          StateError('Tutti i plugin hanno fallito ($reasons).'),
        );
      }
    }

    for (final p in plugins) {
      // Each plugin runs in its own microtask so they truly race.
      Future(() async {
        try {
          final bundle = await fetch(p).timeout(_timeout);
          if (bundle == null) {
            errors[p.meta.shortName] = 'no match';
          } else if (scoreBundle(bundle) <= 0) {
            errors[p.meta.shortName] = 'scored 0 (drm or empty)';
          } else if (!completer.isCompleted) {
            _log.info('plugin ${p.meta.shortName} → winner');
            completer.complete(ResolvedStream(plugin: p, bundle: bundle));
            return;
          }
        } on TimeoutException {
          errors[p.meta.shortName] = 'timeout (${_timeout.inSeconds}s)';
        } catch (e) {
          errors[p.meta.shortName] = '$e';
          _log.warn('plugin ${p.meta.shortName} failed: $e');
        } finally {
          pending--;
          finishIfDone();
        }
      });
    }

    return completer.future;
  }

  /// Run plugin.search(hint.title) and pick the best matching entry by
  /// (mediaType-aware pool) → (title+year) → (title only) → (first).
  ///
  /// Returns null if the plugin returned no results or threw on search.
  Future<Map<String, dynamic>?> _resolveEntry(
    Plugin plugin,
    TitleHint hint,
    String mediaType,
  ) async {
    final List<Map<String, dynamic>> results;
    try {
      results = await plugin.search(hint.title);
    } catch (e) {
      _log.warn('plugin ${plugin.meta.shortName} search failed: $e');
      return null;
    }
    _log.info(
        'plugin ${plugin.meta.shortName} search "${hint.title}" → ${results.length} result(s)');
    if (results.isEmpty) return null;

    final norm = hint.title.toLowerCase().trim();
    final typed = results.where((r) {
      final t = (r['type'] as String? ?? '');
      return t == mediaType || t.startsWith('$mediaType:');
    }).toList();
    final pool = typed.isNotEmpty ? typed : results;

    if (hint.year != null) {
      for (final r in pool) {
        final title = (r['title'] as String? ?? '').toLowerCase().trim();
        final year = r['year'];
        if (title == norm &&
            year is num &&
            (year.toInt() - hint.year!).abs() <= 1) {
          _log.info(
              '  match tier-1 ${plugin.meta.shortName}: ${r['title']} (${r['year']})');
          return r;
        }
      }
    }
    for (final r in pool) {
      final title = (r['title'] as String? ?? '').toLowerCase().trim();
      if (title == norm) {
        _log.info(
            '  match tier-2 ${plugin.meta.shortName}: ${r['title']} (${r['year']})');
        return r;
      }
    }
    final fallback = pool.first;
    _log.warn(
        '  match tier-3 ${plugin.meta.shortName} (weak): ${fallback['title']}');
    return fallback;
  }
}
