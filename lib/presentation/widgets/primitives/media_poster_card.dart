// lib/presentation/widgets/primitives/media_poster_card.dart
//
// The single poster tile used by rows and grids. Composes AspectRatioMedia
// (overflow-safe, fallback) with a title + meta line from MediaCardVm. The
// optional amber progress bar marks "continue watching". Text uses plain
// TextStyle so it inherits the ambient theme font (and stays test-safe).
import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../view_models/media_card_vm.dart';
import 'aspect_ratio_media.dart';

class MediaPosterCard extends StatelessWidget {
  const MediaPosterCard({
    super.key,
    required this.item,
    required this.width,
    this.progress,
    this.onTap,
  });

  final MediaCardVm item;
  final double width;

  /// 0..1 resume progress. Null or <= 0 hides the bar.
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showProgress = progress != null && progress! > 0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatioMedia(
                  aspectRatio: 2 / 3,
                  imageUrl: item.posterUrl,
                  fallbackLabel: item.title,
                ),
                if (showProgress)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _ProgressBar(
                      key: const Key('poster-progress'),
                      value: progress!.clamp(0.0, 1.0),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: StreamloadTokens.space2),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: StreamloadTokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (item.metaLine.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  item.metaLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: StreamloadTokens.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(StreamloadTokens.radiusCard),
      ),
      child: Container(
        height: 4,
        color: StreamloadTokens.surfaceHi,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: Container(color: StreamloadTokens.accent),
        ),
      ),
    );
  }
}
