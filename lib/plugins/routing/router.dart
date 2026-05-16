// lib/plugins/routing/router.dart
import 'dart:async';

import '../../domain/play_title.dart' show TitleHint;
import '../../infra/logger.dart';
import '../plugin.dart';
import '../runtime.dart';
import 'quality.dart';

final _log = Logger('plugins.router');

/// Result of a router decision: which plugin won, the bundle it returned,
/// and the entry (with year) that produced it — used by the scorer.
class ResolvedStream {
  ResolvedStream({
    required this.plugin,
    required this.bundle,
    required this.matchEntry,
  });
  final Plugin plugin;
  final Map<String, dynamic> bundle;
  final Map<String, dynamic> matchEntry;
}

/// Resolves a plugin entry into a playable bundle. Receives the plugin and
/// the matched entry; returns null to signal "couldn't produce a bundle".
typedef _BundleResolver = Future<Map<String, dynamic>?> Function(
    Plugin plugin, Map<String, dynamic> entry);

/// Orchestrates fan-out across all plugins whose capabilities cover the
/// requested mediaType. Every plugin runs search → match → resolve in
/// parallel. After all plugins finish OR the deadline fires, bundles that
/// scored non-zero are ranked by `_scoreFor(bundle, hint)` and the best
/// one wins.
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
  /// search → match → getStreams in parallel; best-scoring bundle wins.
  Future<ResolvedStream> resolveMovieStream({
    required String mediaType,
    required TitleHint hint,
  }) {
    return _collectAndScore(
      mediaType: mediaType,
      hint: hint,
      resolve: (p, entry) => p.getStreams(entry),
    );
  }

  /// Fan-out for a TV episode request: every matching plugin runs
  /// search → match → getSeasons → getEpisodes → getStreams in parallel;
  /// best-scoring bundle wins.
  Future<ResolvedStream> resolveEpisodeStream({
    required String mediaType,
    required TitleHint hint,
    required int season,
    required int episode,
  }) {
    return _collectAndScore(
      mediaType: mediaType,
      hint: hint,
      resolve: (p, entry) async {
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

  /// Fan-out + collect + score. Runs every matching plugin in parallel, waits
  /// until they're all done OR the deadline expires, then picks the bundle
  /// with the highest score (year-distance dominated). Throws StateError
  /// aggregating per-plugin reasons if nothing succeeded.
  ///
  /// Why not first-success? Because one plugin can return faster with a wrong
  /// product (SC's "ONE PIECE (2023)" live action beats AU's slower "One Piece
  /// (1999)" anime). Collecting all and scoring by year-delta resolves these.
  Future<ResolvedStream> _collectAndScore({
    required String mediaType,
    required TitleHint hint,
    required _BundleResolver resolve,
  }) async {
    final plugins = pluginsForType(mediaType).toList();
    if (plugins.isEmpty) {
      throw StateError('Nessun plugin disponibile per $mediaType.');
    }

    final successes = <ResolvedStream>[];
    final errors = <String, String>{};

    Future<void> runOne(Plugin p) async {
      try {
        final entry = await _resolveEntry(p, hint, mediaType);
        if (entry == null) {
          errors[p.meta.shortName] = 'no match';
          return;
        }
        final bundle = await resolve(p, entry);
        if (bundle == null) {
          errors[p.meta.shortName] = 'no bundle';
          return;
        }
        if (scoreBundle(bundle) <= 0) {
          errors[p.meta.shortName] = 'scored 0 (drm or empty)';
          return;
        }
        successes.add(ResolvedStream(
          plugin: p,
          bundle: bundle,
          matchEntry: entry,
        ));
      } catch (e) {
        errors[p.meta.shortName] = '$e';
        _log.warn('plugin ${p.meta.shortName} failed: $e');
      }
    }

    try {
      await Future.wait(plugins.map(runOne)).timeout(_timeout);
    } on TimeoutException {
      _log.info(
          'router: deadline ${_timeout.inSeconds}s hit with ${successes.length}/${plugins.length} resolved');
    }

    if (successes.isEmpty) {
      final reasons =
          errors.entries.map((e) => '${e.key}: ${e.value}').join(' • ');
      throw StateError(
        'Tutti i plugin hanno fallito (${reasons.isEmpty ? "nessun risultato" : reasons}).',
      );
    }

    successes.sort(
      (a, b) => _scoreFor(b, hint).compareTo(_scoreFor(a, hint)),
    );
    final winner = successes.first;
    if (successes.length > 1) {
      final pretty = successes
          .map((s) =>
              '${s.plugin.meta.shortName}=${_scoreFor(s, hint)} '
              '(${s.matchEntry['title']}/${s.matchEntry['year']})')
          .join(', ');
      _log.info('router: $pretty → winner ${winner.plugin.meta.shortName}');
    } else {
      _log.info(
          'router: only ${winner.plugin.meta.shortName} resolved → winner');
    }
    return winner;
  }

  /// Score a resolved bundle. Higher is better. The dominant term is
  /// year-distance: a 1-year delta knocks the bundle below a clean match
  /// from another plugin. This is what kept "ONE PIECE (2023)" from beating
  /// "One Piece (1999)" when the user asked for the 1999 anime.
  int _scoreFor(ResolvedStream r, TitleHint hint) {
    var score = scoreBundle(r.bundle);
    if (hint.year != null) {
      final y = r.matchEntry['year'];
      if (y is num) {
        score -= (y.toInt() - hint.year!).abs();
      } else {
        // No year on the entry — small penalty so plugins that surface year
        // metadata get a tiebreak over those that don't.
        score -= 2;
      }
    }
    return score;
  }

  /// Run plugin.search(hint.title) and pick the best matching entry.
  ///
  /// Tier 1: normalized title equality + year within ±1 (strong)
  /// Tier 2: normalized title equality, any year (strong)
  /// Tier 3a: normalized prefix + year within ±5 (good — year proves identity
  ///          so we skip the length cap; picks year-closest then shortest)
  /// Tier 3b: normalized prefix + length cap 1.6× hint (fallback — no year
  ///          available or no year-close candidate; pick shortest title)
  ///
  /// Returns null if no tier matches. Never falls back to a random first
  /// result.
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

    final hintNorm = _normalizeTitle(hint.title);
    final typed = results.where((r) {
      final t = (r['type'] as String? ?? '');
      return t == mediaType || t.startsWith('$mediaType:');
    }).toList();
    final pool = typed.isNotEmpty ? typed : results;

    // Tier 1: normalized exact + close year.
    if (hint.year != null) {
      for (final r in pool) {
        final tNorm = _normalizeTitle(r['title'] as String? ?? '');
        final year = r['year'];
        if (tNorm == hintNorm &&
            year is num &&
            (year.toInt() - hint.year!).abs() <= 1) {
          _log.info(
              '  match tier-1 ${plugin.meta.shortName}: ${r['title']} (${r['year']})');
          return r;
        }
      }
    }
    // Tier 2: normalized exact, any year.
    for (final r in pool) {
      final tNorm = _normalizeTitle(r['title'] as String? ?? '');
      if (tNorm == hintNorm) {
        _log.info(
            '  match tier-2 ${plugin.meta.shortName}: ${r['title']} (${r['year']})');
        return r;
      }
    }
    // Tier 3a: prefix + close year (±5). The year identifies the product, so
    // we skip the length cap (Pokémon's per-season AU entries can be quite
    // long). Picks year-closest, then shortest title as tiebreaker.
    if (hint.year != null) {
      Map<String, dynamic>? bestYearMatch;
      int bestYearDelta = 999;
      int bestLen = 1 << 30;
      for (final r in pool) {
        final tNorm = _normalizeTitle(r['title'] as String? ?? '');
        if (!tNorm.startsWith('$hintNorm ')) continue;
        final year = r['year'];
        if (year is! num) continue;
        final delta = (year.toInt() - hint.year!).abs();
        if (delta > 5) continue;
        final len = (r['title'] as String? ?? '').length;
        if (delta < bestYearDelta ||
            (delta == bestYearDelta && len < bestLen)) {
          bestYearMatch = r;
          bestYearDelta = delta;
          bestLen = len;
        }
      }
      if (bestYearMatch != null) {
        _log.info(
            '  match tier-3a ${plugin.meta.shortName} (prefix+year=${bestYearMatch['year']}): ${bestYearMatch['title']}');
        return bestYearMatch;
      }
    }
    // Tier 3b: prefix + length cap. Same rule as before: covers
    // ":Special Edition" but rejects ": Detective Pikachu".
    final maxCandidateLen = (hintNorm.length * 1.6).ceil();
    final prefixed = <Map<String, dynamic>>[];
    for (final r in pool) {
      final tNorm = _normalizeTitle(r['title'] as String? ?? '');
      if (tNorm.startsWith('$hintNorm ') && tNorm.length <= maxCandidateLen) {
        prefixed.add(r);
      }
    }
    if (prefixed.isNotEmpty) {
      prefixed.sort((a, b) {
        final la = (a['title'] as String? ?? '').length;
        final lb = (b['title'] as String? ?? '').length;
        return la.compareTo(lb);
      });
      final chosen = prefixed.first;
      _log.info(
          '  match tier-3b ${plugin.meta.shortName} (prefix+cap): ${chosen['title']} (${chosen['year']})');
      return chosen;
    }
    _log.warn(
        '  no match in ${plugin.meta.shortName} for "${hint.title}" — rejected ${pool.length} weak candidate(s)');
    return null;
  }

  /// Normalize a title for fuzzy matching across plugins:
  /// - lowercase + trim
  /// - strip accents (é→e, à→a, …) so "Pokémon" matches "Pokemon"
  /// - strip a leading Italian/English article ("il/lo/la/l'/i/le/gli/the")
  /// - replace non-letter/digit with space, collapse runs of whitespace
  ///
  /// Bug we fixed: the previous regex used `[^\w\s]` which is ASCII-only in
  /// Dart's default RegExp mode, so any accented Italian letter (é, à, ù, …)
  /// counted as punctuation and got replaced with a space — turning "Pokémon"
  /// into "pok mon" and missing every match.
  static final _articleRe = RegExp(
    r"^(il |lo |la |l'|i |le |gli |the )",
    caseSensitive: false,
  );
  static final _nonLetterDigit =
      RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final _wsRe = RegExp(r'\s+');

  String _normalizeTitle(String s) {
    var n = s.toLowerCase().trim();
    n = _foldAccents(n);
    n = n.replaceFirst(_articleRe, '');
    n = n.replaceAll(_nonLetterDigit, ' ');
    n = n.replaceAll(_wsRe, ' ').trim();
    return n;
  }

  /// Italian + common Latin accent folding. We do this manually because
  /// Dart's stdlib has no NFD decomposition. Catches the cases that hit our
  /// catalogs: Pokémon, città, perché, già, più, etc.
  static const _accentMap = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y',
    'ñ': 'n',
    'ç': 'c',
  };

  String _foldAccents(String s) {
    final buf = StringBuffer();
    for (final ch in s.split('')) {
      buf.write(_accentMap[ch] ?? ch);
    }
    return buf.toString();
  }
}
