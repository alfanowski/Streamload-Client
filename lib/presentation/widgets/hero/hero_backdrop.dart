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
// Pass 2F (2026-05-17): the backdrop image now slowly zooms 1.00 → 1.05
// over [kenBurnsDuration] (25 s) via an AnimationController driven by
// TickerProvider — Ken Burns ambient motion. Subtle, constant; reads as
// cinematic without distracting the eye. The controller resets when the
// image URL changes so the new slide starts fresh at 1.00.
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
        const _BottomGradient(),
      ],
    );
  }
}

/// Ambient Ken Burns motion: the backdrop image slowly zooms from
/// scale 1.00 → 1.05 over this duration. Long enough to read as a
/// gentle drift, not a snap. When the backdrop URL changes (carousel
/// advance), the controller resets to 1.00 for the new slide.
const Duration kKenBurnsDuration = Duration(seconds: 25);

class _Backdrop extends StatefulWidget {
  const _Backdrop({this.url, this.fallbackUrl});
  final String? url;
  final String? fallbackUrl;

  @override
  State<_Backdrop> createState() => _BackdropState();
}

class _BackdropState extends State<_Backdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kenBurns;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _kenBurns = AnimationController(
      vsync: this,
      duration: kKenBurnsDuration,
    )..forward();
    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(
      parent: _kenBurns,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant _Backdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset the zoom on a fresh slide so each backdrop drifts from 1.0
    // instead of jumping into the middle of the previous animation.
    if (oldWidget.url != widget.url ||
        oldWidget.fallbackUrl != widget.fallbackUrl) {
      _kenBurns
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _kenBurns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = (widget.url == null || widget.url!.isEmpty) ? null : widget.url;
    final fallback =
        (widget.fallbackUrl == null || widget.fallbackUrl!.isEmpty)
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
      // If the primary backdrop URL fails, try the poster URL before
      // giving up to a solid color.
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
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: image,
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3, 1.0],
            colors: [
              Colors.transparent,
              Colors.transparent,
              const Color(0xFF000000).withValues(alpha: 0.8),
            ],
          ),
        ),
      ),
    );
  }
}
