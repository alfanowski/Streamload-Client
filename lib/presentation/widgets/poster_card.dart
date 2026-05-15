// lib/presentation/widgets/poster_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/models/media_summary.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class PosterCard extends StatelessWidget {
  const PosterCard({super.key, required this.summary, required this.onTap});

  final MediaSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: summary.posterUrl != null
                    ? CachedNetworkImage(
                        imageUrl: summary.posterUrl!,
                        fit: BoxFit.cover,
                        // surface2 used as placeholder background —
                        // StreamloadColors.surfaceMuted does not exist.
                        placeholder: (_, __) =>
                            Container(color: StreamloadColors.surface2),
                        errorWidget: (_, __, ___) => const _PlaceholderPoster(),
                      )
                    : const _PlaceholderPoster(),
              ),
            ),
            const SizedBox(height: 8),
            // Flexible lets the title shrink (loose constraints) when the
            // grid cell is too short — ellipsis handles the visual truncation
            // instead of yellow-and-black overflow stripes.
            Flexible(
              child: Text(
                summary.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: StreamloadTypography.body(fontSize: 13),
              ),
            ),
            if (summary.year != null)
              Text(
                '${summary.year}',
                style: StreamloadTypography.mono(
                  fontSize: 10,
                  color: StreamloadColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPoster extends StatelessWidget {
  const _PlaceholderPoster();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StreamloadColors.surface2,
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined, size: 28),
    );
  }
}
