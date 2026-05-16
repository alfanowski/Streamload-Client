// lib/presentation/widgets/cards/backdrop_card.dart
//
// 16:9 landscape card used by the "Continua a guardare" row on Home and by
// the episode list on the title page. Optional progress bar overlay at the
// bottom (0..1 fraction) for in-progress titles.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';

class BackdropCard extends StatelessWidget {
  const BackdropCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.progressFraction,
    this.onTap,
    this.width = StreamloadSpacing.backdropCardWidthDesktop,
  });

  final String title;
  final String? subtitle;
  final String? imageUrl;

  /// 0..1 — when non-null, a white progress bar overlays the bottom 3px
  /// of the image. Used for "Continua a guardare" cards.
  final double? progressFraction;

  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 9 / 16;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(StreamloadSpacing.cardRadius),
                  child: _image(width, height),
                ),
                if (progressFraction != null) _progressBar(),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StreamloadTypography.v3Body(fontSize: 12),
            ),
            if (subtitle != null && subtitle!.isNotEmpty)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StreamloadTypography.v3MetaMono(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _image(double w, double h) {
    if (imageUrl == null || imageUrl!.isEmpty) return _placeholder(w, h);
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: w,
      height: h,
      fit: BoxFit.cover,
      placeholder: (_, __) =>
          Container(width: w, height: h, color: StreamloadColors.v3SurfaceGlass),
      errorWidget: (_, __, ___) => _placeholder(w, h),
    );
  }

  Widget _placeholder(double w, double h) => Container(
        width: w,
        height: h,
        color: StreamloadColors.v3SurfaceGlass,
        alignment: Alignment.center,
        child: Icon(
          Icons.movie_outlined,
          color: StreamloadColors.v3TextMuted,
          size: 28,
        ),
      );

  Widget _progressBar() => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(StreamloadSpacing.cardRadius),
          ),
          child: Container(
            height: 3,
            color: Colors.black.withValues(alpha: 0.5),
            child: FractionallySizedBox(
              widthFactor: progressFraction!.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(color: Colors.white),
            ),
          ),
        ),
      );
}
