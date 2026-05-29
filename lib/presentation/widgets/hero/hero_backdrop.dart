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
    return Stack(
      fit: StackFit.expand,
      children: [
        _Backdrop(url: backdropUrl, fallbackUrl: posterUrl),
        // Left scrim (desktop billboard feel) — darkens the side the
        // bottom-left title sits on, without crushing the whole image.
        const _LeftScrim(),
        // Stronger cinematic bottom fade so the title + CTAs pop.
        const _BottomGradient(),
      ],
    );
  }
}

/// Backdrop image with a slow one-shot "Ken Burns" zoom-in for premium
/// life on mount. One-shot (not repeating) so widget tests that settle
/// don't hang. A rotating carousel re-mounts each slide → fresh zoom.
class _Backdrop extends StatefulWidget {
  const _Backdrop({this.url, this.fallbackUrl});
  final String? url;
  final String? fallbackUrl;

  @override
  State<_Backdrop> createState() => _BackdropState();
}

class _BackdropState extends State<_Backdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..forward();
    _scale = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary =
        (widget.url == null || widget.url!.isEmpty) ? null : widget.url;
    final fallback = (widget.fallbackUrl == null || widget.fallbackUrl!.isEmpty)
        ? null
        : widget.fallbackUrl;
    final chosen = primary ?? fallback;
    if (chosen == null) {
      return Container(color: StreamloadColors.v3BgBase);
    }
    final image = CachedNetworkImage(
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
    return ScaleTransition(scale: _scale, child: image);
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
              StreamloadColors.v3BgBase.withValues(alpha: 0.55),
              StreamloadColors.v3BgBase.withValues(alpha: 0.15),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    // CM-5: editorial scrim — transparent over the top 65% of the hero,
    // then a soft warm-bg fade over the bottom 35%. Stops below match
    // the brief: 0.0 transparent → 0.65 transparent → 1.0 #0F0E0D at
    // 70% alpha. Reads as a "page tinted underneath the title" rather
    // than a hard band of darkness, so the title pops without the
    // backdrop image looking crushed.
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 0.75, 1.0],
            colors: [
              Colors.transparent,
              StreamloadColors.v3BgBase.withValues(alpha: 0.15),
              StreamloadColors.v3BgBase.withValues(alpha: 0.75),
              StreamloadColors.v3BgBase.withValues(alpha: 0.98),
            ],
          ),
        ),
      ),
    );
  }
}
