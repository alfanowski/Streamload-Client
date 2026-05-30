// lib/presentation/widgets/hero/hero_backdrop.dart
//
// HeroBackdrop — the shared visual chrome of a hero panel: backdrop image
// at the bottom + a dark bottom gradient for text legibility.
//
// 2026-05-16 (P1 hotfix): the YouTube trailer reveal was removed per
// operator feedback ("Netflix-style: just show the backdrop, no autoplay
// video"). The [videoId] / [showMuteToggle] / [muteToggleAlignment] /
// [muteToggleMargin] params are kept for source compatibility but are no
// longer rendered. HeroTrailer the widget file stays around so a future
// "preview on hover" feature can resurrect it without re-deriving the
// YouTube IFrame wrapper. See sub-plan 8 §Hero for the original design.
//
// What it does NOT own:
//   - the metadata + CTA block — that's pure layout, very page-specific,
//     and varies between Home hero (eyebrow + carousel index + play/add)
//     and Title hero (Guarda S1 E1 / Riprendi / La mia lista / share)
//
// Use it in a Stack and place your own metadata / CTAs on top via
// Positioned.
//
// [posterUrl] is used as a fallback for titles that don't have a backdrop
// (some TMDB entries — especially recent / niche — only have the poster).
// Without it the operator was seeing a solid black hero with no image.
//
// 2026-05-17 (CM-2): the Pass 2F Ken Burns ambient zoom was dropped.
// Magazine editorial heroes are still — they let the image breathe and
// give the typography centre stage. The previous AnimationController +
// Tween + AnimatedBuilder are gone; the backdrop is now a plain
// CachedNetworkImage inside the Stack.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../responsive.dart';
import '../../theme/colors.dart';

class HeroBackdrop extends StatelessWidget {
  const HeroBackdrop({
    super.key,
    this.backdropUrl,
    this.posterUrl,
    this.videoId,
    this.showMuteToggle = true,
    this.muteToggleAlignment = Alignment.bottomRight,
    this.muteToggleMargin = const EdgeInsets.fromLTRB(0, 0, 24, 24),
  });

  /// TMDB backdrop image URL. When null/empty, [posterUrl] is used as a
  /// fallback so the hero is never a blank black slab.
  final String? backdropUrl;

  /// Fallback image when [backdropUrl] is null/empty. TMDB returns a
  /// portrait 2:3 poster which gets cropped to the hero's 16:9-ish frame
  /// via BoxFit.cover — not ideal but better than no image at all.
  final String? posterUrl;

  /// Kept for source compatibility — no longer rendered after the P1
  /// hotfix dropped the YouTube trailer reveal. See file-level docstring.
  final String? videoId;

  /// Kept for source compatibility — no longer rendered after the P1
  /// hotfix dropped the YouTube trailer reveal.
  final bool showMuteToggle;

  /// Kept for source compatibility — no longer rendered.
  final Alignment muteToggleAlignment;

  /// Kept for source compatibility — no longer rendered.
  final EdgeInsets muteToggleMargin;

  @override
  Widget build(BuildContext context) {
    // Phone fades to PURE BLACK so it matches the (now solid-black) phone
    // page background with zero seam; desktop keeps the warm page colour.
    final fadeColor =
        Responsive.isMobile(context) ? Colors.black : StreamloadColors.v3BgBase;
    return Stack(
      fit: StackFit.expand,
      children: [
        _Backdrop(url: backdropUrl, fallbackUrl: posterUrl),
        // Left scrim (desktop billboard feel) — darkens the side the
        // bottom-left title sits on, without crushing the whole image.
        const _LeftScrim(),
        // Stronger cinematic bottom fade so the title + CTAs pop.
        _BottomGradient(fadeColor: fadeColor),
        // Slight top scrim behind the status bar / Dynamic Island so the
        // clock, battery and wordmark stay legible over bright artwork
        // (Apple TV+ does the same).
        const _TopGradient(),
      ],
    );
  }
}

/// Static backdrop image (no Ken Burns / motion — operator wants the hero
/// to stay still). Falls back to the poster, then a solid warm bg.
class _Backdrop extends StatelessWidget {
  const _Backdrop({this.url, this.fallbackUrl});
  final String? url;
  final String? fallbackUrl;

  @override
  Widget build(BuildContext context) {
    final primary = (url == null || url!.isEmpty) ? null : url;
    final fallback =
        (fallbackUrl == null || fallbackUrl!.isEmpty) ? null : fallbackUrl;
    final chosen = primary ?? fallback;
    if (chosen == null) {
      return Container(color: StreamloadColors.v3BgBase);
    }
    return CachedNetworkImage(
      imageUrl: chosen,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: StreamloadColors.v3BgBase),
      errorWidget: (_, __, ___) {
        if (fallback != null && chosen != fallback) {
          return CachedNetworkImage(
            imageUrl: fallback,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(color: StreamloadColors.v3BgBase),
            errorWidget: (_, __, ___) =>
                Container(color: StreamloadColors.v3BgBase),
          );
        }
        return Container(color: StreamloadColors.v3BgBase);
      },
    );
  }
}

/// Subtle left→right scrim: a warm-black wash over the leftmost ~45% that
/// fades to transparent, so the bottom-left title reads cleanly on bright
/// backdrops (Netflix / Apple TV+ billboard convention).
class _LeftScrim extends StatelessWidget {
  const _LeftScrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.0, 0.45, 1.0],
            colors: [
              StreamloadColors.v3BgBase.withValues(alpha: 0.4),
              StreamloadColors.v3BgBase.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

/// Slight top-down scrim so the OS status bar (clock / wifi / battery) and the
/// "Streamload" wordmark read cleanly over bright artwork. Subtle on purpose —
/// just enough contrast behind the notch, fully transparent by ~18% down.
class _TopGradient extends StatelessWidget {
  const _TopGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.09, 0.18],
            colors: [
              Colors.black.withValues(alpha: 0.45),
              Colors.black.withValues(alpha: 0.18),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient({required this.fadeColor});

  /// The opaque colour the hero dissolves into at its bottom edge — must match
  /// whatever sits below it so there's no visible seam.
  final Color fadeColor;

  @override
  Widget build(BuildContext context) {
    // A long, GRADUAL fade to the page background. The old scrim only
    // darkened in the last 20% — that abrupt ramp read as a visible
    // "horizon line" (the stacco). This spreads the darkening smoothly from
    // ~30% down, reaches the page colour fully by 90%, then holds a solid
    // band to the very bottom so the image edge is completely buried and the
    // hero merges seamlessly into the content below.
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.32, 0.56, 0.76, 0.90, 1.0],
            colors: [
              Colors.transparent,
              fadeColor.withValues(alpha: 0.05),
              fadeColor.withValues(alpha: 0.26),
              fadeColor.withValues(alpha: 0.70),
              // Fully the page background by 90%…
              fadeColor,
              // …and held solid to the bottom edge — no visible seam.
              fadeColor,
            ],
          ),
        ),
      ),
    );
  }
}
