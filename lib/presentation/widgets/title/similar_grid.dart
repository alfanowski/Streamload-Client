// lib/presentation/widgets/title/similar_grid.dart
//
// "Contenuti simili" as a 3-column covers grid (recommendations → similar
// fallback). Used both inside the TV title page's "Simili" tab (no header)
// and at the bottom of a movie page (with a header).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/media_summary.dart';
import '../../../state/home_rows_provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../poster_card.dart';

class SimilarGrid extends ConsumerWidget {
  const SimilarGrid({
    super.key,
    required this.tmdbId,
    required this.mediaType,
    this.showHeader = false,
  });

  final int tmdbId;
  final String mediaType;
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = TmdbKey(tmdbId: tmdbId, mediaType: mediaType);
    final recos = ref.watch(recommendationsProvider(key));
    return recos.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      ),
      error: (_, __) => _Fallback(tmdbKey: key, showHeader: showHeader),
      data: (items) => items.isEmpty
          ? _Fallback(tmdbKey: key, showHeader: showHeader)
          : _Grid(items: items, showHeader: showHeader),
    );
  }
}

class _Fallback extends ConsumerWidget {
  const _Fallback({required this.tmdbKey, required this.showHeader});
  final TmdbKey tmdbKey;
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similar = ref.watch(similarProvider(tmdbKey));
    return similar.maybeWhen(
      data: (items) => items.isEmpty
          ? const SizedBox.shrink()
          : _Grid(items: items, showHeader: showHeader),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.items, required this.showHeader});
  final List<MediaSummary> items;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final shown = items.take(18).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Text(
            'Titoli simili',
            style: StreamloadTypography.display(fontSize: 22, italic: false)
                .copyWith(color: StreamloadColors.v3TextPrimary),
          ),
          const SizedBox(height: 16),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 14,
            crossAxisSpacing: 12,
            childAspectRatio: 2 / 3,
          ),
          itemCount: shown.length,
          itemBuilder: (context, i) {
            final m = shown[i];
            return PosterCard(
              summary: m,
              width: 120,
              showLabel: false,
              onTap: () => context.push(
                '/title/${m.tmdbId}?media_type=${m.mediaType}',
              ),
            );
          },
        ),
      ],
    );
  }
}
