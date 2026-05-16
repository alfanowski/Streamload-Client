// lib/presentation/widgets/poster_card.dart
//
// 2:3 portrait poster card. Used by every poster row + grid.
//
// Phase A5 (sub-plan 8): adds a hover-scale animation on desktop / tablet.
// Phones don't fire hover events through MouseRegion (they fire on touch
// hover which we don't want), so the effect auto-disables there. The cell
// stays 160w externally — only the visual layer scales — so layout shifts
// don't cascade in the surrounding row.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/models/media_summary.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

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
    return _PressScale(
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
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  summary.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: StreamloadTypography.body(fontSize: 13),
                ),
              ),
              if (subtitleOverride != null)
                Text(
                  subtitleOverride!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StreamloadTypography.mono(
                    fontSize: 10,
                    color: StreamloadColors.textSecondary,
                  ),
                )
              else if (summary.year != null)
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

/// Tiny private widget: scale the child 1.0 → 1.08 on mouse hover. When
/// [enabled] is false (phones / tablets), passes the child through
/// untouched. Uses TransformAlignment.center so the card grows from its
/// own centroid and doesn't shift toward the row's leading edge.
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
      child: AnimatedScale(
        scale: _hovering ? 1.08 : 1.0,
        duration: StreamloadMotion.hoverDuration,
        curve: StreamloadMotion.hoverCurve,
        child: widget.child,
      ),
    );
  }
}

/// Press-down feedback: quickly squeezes the child to 0.96 while held,
/// snaps back on release / cancel. Works on touch (mobile) and pointer
/// down (desktop click). Sits OUTSIDE the InkWell so it visually feels
/// like the whole card "depresses" before the ink ripple fires.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child});
  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
