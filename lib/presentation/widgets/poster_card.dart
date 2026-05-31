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
import 'title_actions_sheet.dart';

class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.summary,
    required this.onTap,
    this.width = StreamloadSpacing.posterCardWidthDesktop,
    this.progressFraction,
    this.subtitleOverride,
    this.showLabel = true,
    this.heroTag,
  });

  final MediaSummary summary;
  final VoidCallback onTap;
  final double width;

  /// Shared-element tag — when set, the poster image becomes a Hero so the
  /// title page can open FROM this poster. Must be unique on the screen.
  final Object? heroTag;

  /// 0..1 — when non-null the card shows a "Continua a guardare" overlay on
  /// the poster: a bottom scrim, the season/episode label and a clear
  /// progress bar. No text is added below the poster.
  final double? progressFraction;

  /// Season/episode (or remaining-time) line shown INSIDE the resume overlay,
  /// e.g. `S2 · E5`. Only used when [progressFraction] is set.
  final String? subtitleOverride;

  /// Whether to show the title (+ year) beneath the poster. Rows on Home set
  /// this false for a clean covers-only look; grids / search keep it true.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final hoverable = !Responsive.isMobile(context);

    final poster = AspectRatio(
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            summary.posterUrl != null
                ? CachedNetworkImage(
                    imageUrl: summary.posterUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: StreamloadColors.surface2),
                    errorWidget: (_, __, ___) => const _PlaceholderPoster(),
                  )
                : const _PlaceholderPoster(),
            if (progressFraction != null)
              _ResumeOverlay(
                progress: progressFraction!,
                label: subtitleOverride,
              ),
          ],
        ),
      ),
    );

    final Widget heroPoster = heroTag != null
        ? Hero(
            tag: heroTag!,
            // No custom shuttle: Flutter's default cross-fades this poster
            // into the title hero as the rect expands — smooth, no hard
            // swap/flash at the end of the flight.
            child: poster,
          )
        : poster;

    final Widget content = showLabel
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heroPoster,
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  summary.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: StreamloadTypography.display(fontSize: 14, italic: true),
                ),
              ),
              if (summary.year != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${summary.year}',
                    style: StreamloadTypography.v3MetaMono()
                        .copyWith(fontSize: 10),
                  ),
                ),
            ],
          )
        : heroPoster;

    return PressFeedback(
      child: _HoverScale(
        enabled: hoverable,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => showTitleActions(context, summary),
          borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
          child: SizedBox(width: width, child: content),
        ),
      ),
    );
  }
}

/// "Continua a guardare" overlay: a bottom scrim + the season/episode line +
/// a clear amber progress bar. Sits on the poster so cards stay image-first.
class _ResumeOverlay extends StatelessWidget {
  const _ResumeOverlay({required this.progress, this.label});

  final double progress;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 28, 8, 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5, 1.0],
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.55),
              Colors.black.withValues(alpha: 0.92),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (label != null && label!.isNotEmpty) ...[
              Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 4),
                    Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                        offset: Offset(0, 1)),
                  ],
                ),
              ),
              const SizedBox(height: 7),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 5,
                width: double.infinity,
                // StackFit.expand → tight constraints, so the track actually
                // fills (a bare ColoredBox under loose constraints collapses
                // to 0px and stays invisible).
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: Colors.white.withValues(alpha: 0.30)),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      alignment: Alignment.centerLeft,
                      child: const ColoredBox(color: Colors.white),
                    ),
                  ],
                ),
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
