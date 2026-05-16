// lib/presentation/widgets/title/similar_titles_row.dart
//
// "Titoli simili" — the row at the bottom of the v3 Title page that
// pulls TMDB recommendations (or similar as fallback) for the current
// title (Phase E4 of sub-plan 8). Wraps PosterRow so the visual
// language matches Home.
//
// Behaviour:
//   - Watches recommendationsProvider(TmdbKey)
//   - If empty AND not loading, fall back to similarProvider — TMDB
//     recommendations are sometimes sparse for niche titles, but
//     "similar" tends to have something thanks to genre / keyword
//     matching.
//   - If both empty, the widget renders nothing — no "Nessun risultato"
//     placeholder; better to let the page end at the previous section.
//
// Card taps reuse PosterRow's default handler: navigates to the tapped
// title's page (/title/<id>?media_type=<mt>).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/media_summary.dart';
import '../../../state/home_rows_provider.dart';
import '../rows/poster_row.dart';

class SimilarTitlesRow extends ConsumerWidget {
  const SimilarTitlesRow({
    super.key,
    required this.tmdbId,
    required this.mediaType,
  });

  final int tmdbId;
  final String mediaType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = TmdbKey(tmdbId: tmdbId, mediaType: mediaType);
    final recos = ref.watch(recommendationsProvider(key));
    return recos.when(
      loading: () => const PosterRow(
        title: 'Titoli simili',
        items: <MediaSummary>[],
        isLoading: true,
      ),
      // Recommendations errored → fall back to similar before giving up.
      error: (_, __) => _Fallback(tmdbKey: key),
      data: (items) {
        if (items.isEmpty) return _Fallback(tmdbKey: key);
        return PosterRow(title: 'Titoli simili', items: items);
      },
    );
  }
}

/// Watches similarProvider and renders the row only when it returns
/// items. Hidden when both recos and similar are empty — keeps the
/// page from ending in dead space.
class _Fallback extends ConsumerWidget {
  const _Fallback({required this.tmdbKey});
  final TmdbKey tmdbKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similar = ref.watch(similarProvider(tmdbKey));
    return similar.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return PosterRow(title: 'Titoli simili', items: items);
      },
    );
  }
}
