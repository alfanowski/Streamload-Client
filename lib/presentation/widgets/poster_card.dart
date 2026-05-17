// lib/presentation/widgets/poster_card.dart
//
// 2:3 portrait poster card. Used by every poster row + grid.
//
// Phase A5 (sub-plan 8): adds a hover-scale animation on desktop / tablet.
// Phones don't fire hover events through MouseRegion (they fire on touch
// hover which we don't want), so the effect auto-disables there. The cell
// stays 160w externally — only the visual layer scales — so layout shifts
// don't cascade in the surrounding row.
//
// 2026-05-17 (CM-2): the Pass 2F.2 hover-glow + 2° Y-axis tilt is gone.
// Editorial cards stay quiet — a subtle 1.0 → 1.04 scale + a hairline
// border that fades from 8% → 25% opacity on hover. No coloured shadows,
// no rotation. Title typography is updated in CM-7.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/models/media_summary.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'press_feedback.dart';

class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.summary,
    required this.onTap,
    this.width = StreamloadSpacing.posterCardWidthDesktop,
    this.progressFraction,
    this.subtitleOverride,
  });

  final MediaSummary summary;
  final VoidCallback onTap;
  final double width;

  /// 0..1 — when non-null, a white progress bar overlays the bottom 3px of
  /// the poster. Used for "Continua a guardare": same 2:3 layout as the
  /// other rows, just with a resume hint over the image.
  final double? progressFraction;

  /// When non-null, replaces the default year line beneath the title.
  /// Used by "Continua a guardare" to show `S1 · E3 · 28 min rimanenti`
  /// instead of the bare release year.
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) {
    final hoverable = !Responsive.isMobile(context);
    return PressFeedback(
      child: _HoverScale(
        enabled: hoverable,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              StreamloadSpacing.cardRadius),
                          child: summary.posterUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: summary.posterUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                      color: StreamloadColors.surface2),
                                  errorWidget: (_, __, ___) =>
                                      const _PlaceholderPoster(),
                                )
                              : const _PlaceholderPoster(),
                        ),
                      ),
                      if (progressFraction != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom:
                                  Radius.circular(StreamloadSpacing.cardRadius),
                            ),
                            child: Container(
                              height: 3,
                              color: Colors.black.withValues(alpha: 0.5),
                              child: FractionallySizedBox(
                                widthFactor:
                                    progressFraction!.clamp(0.0, 1.0),
                                alignment: Alignment.centerLeft,
                                child: Container(
                                    color: StreamloadColors.v3TextPrimary),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // CM-7: more breathing room between poster and title block.
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    summary.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    // CM-7: small serif italic — Letterboxd feel.
                    style: StreamloadTypography.display(
                      fontSize: 14,
                      italic: true,
                    ),
                  ),
                ),
                if (subtitleOverride != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitleOverride!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StreamloadTypography.v3MetaMono().copyWith(
                        fontSize: 10,
                      ),
                    ),
                  )
                else if (summary.year != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${summary.year}',
                      style: StreamloadTypography.v3MetaMono().copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
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

/// CM-2: editorial hover — a subtle 1.0 → 1.04 scale (was 1.08) plus a
/// hairline border that fades from 8% → 25% warm off-white opacity on
/// hover. No yellow glow, no Z-axis tilt, no rotation. Phones / small
/// tablets skip the effect because MouseRegion never fires hover events
/// for them.
class _HoverScale extends StatefulWidget {
  const _HoverScale({required this.child, required this.enabled});
  final Widget child;
  final bool enabled;

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: StreamloadMotion.hoverDuration,
        curve: StreamloadMotion.hoverCurve,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(StreamloadSpacing.cardRadius),
          border: Border.all(
            color: StreamloadColors.v3TextPrimary.withValues(
              alpha: _hovering ? 0.25 : 0.08,
            ),
            width: 1,
          ),
        ),
        child: AnimatedScale(
          scale: _hovering ? 1.04 : 1.0,
          duration: StreamloadMotion.hoverDuration,
          curve: StreamloadMotion.hoverCurve,
          child: widget.child,
        ),
      ),
    );
  }
}
