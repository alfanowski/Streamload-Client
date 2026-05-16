// lib/presentation/widgets/hero/hero_backdrop.dart
//
// HeroBackdrop — the shared visual chrome of a hero panel: backdrop image
// at the bottom, a YouTube trailer that fades in over the top after a
// short delay, a dark bottom gradient for text legibility, and an
// optional 🔊 mute toggle anchored bottom-right (over the gradient).
//
// What it does NOT own:
//   - the metadata + CTA block — that's pure layout, very page-specific,
//     and varies between Home hero (eyebrow + carousel index + play/add)
//     and Title hero (Guarda S1 E1 / Riprendi / La mia lista / share)
//
// Use it in a Stack and place your own metadata / CTAs on top via
// Positioned. The mute toggle stays the responsibility of HeroBackdrop
// because it has to talk to HeroTrailerState via a private GlobalKey.
//
// Extracted in Phase E1 of sub-plan 8 so the title page can reuse the
// trailer-after-2s + backdrop-with-gradient pattern without inheriting
// HeroSlide's home-flavoured CTA strip.
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/motion.dart';
import '../../theme/spacing.dart';
import 'hero_trailer.dart';

class HeroBackdrop extends StatefulWidget {
  const HeroBackdrop({
    super.key,
    this.backdropUrl,
    this.videoId,
    this.showMuteToggle = true,
    this.muteToggleAlignment = Alignment.bottomRight,
    this.muteToggleMargin = const EdgeInsets.fromLTRB(0, 0, 24, 24),
  });

  /// TMDB backdrop image URL. Always rendered immediately as the static
  /// fallback. If [videoId] is also set, the trailer fades in over the
  /// top after [StreamloadMotion.trailerRevealDelay].
  final String? backdropUrl;

  /// YouTube video id of the trailer. ``null`` → no trailer reveal, the
  /// backdrop image stays put.
  final String? videoId;

  /// Whether to render the 🔊 toggle when a trailer is present. Pages
  /// that want to hide it (e.g. the carousel renders its own) can opt
  /// out by passing ``false``.
  final bool showMuteToggle;

  /// Where to anchor the 🔊 toggle inside the hero. Defaults to
  /// bottom-right which matches both Home and Title hero specs.
  final Alignment muteToggleAlignment;

  /// Padding around the 🔊 toggle, measured from [muteToggleAlignment].
  /// Pages with very dense CTA strips can push the toggle further away
  /// to avoid visual collision.
  final EdgeInsets muteToggleMargin;

  @override
  State<HeroBackdrop> createState() => _HeroBackdropState();
}

class _HeroBackdropState extends State<HeroBackdrop> {
  final GlobalKey<HeroTrailerState> _trailerKey = GlobalKey<HeroTrailerState>();
  Timer? _revealTimer;
  bool _trailerVisible = false;
  bool _muted = true;

  @override
  void initState() {
    super.initState();
    _scheduleTrailerReveal();
  }

  @override
  void didUpdateWidget(covariant HeroBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      // Owner swapped the underlying title — reset reveal so the fresh
      // backdrop sits visible for the full 2s before the new trailer
      // fades in. Without this the second slide pops straight to a
      // 100%-opacity (and probably still loading) iframe.
      _revealTimer?.cancel();
      _trailerVisible = false;
      _scheduleTrailerReveal();
    }
  }

  void _scheduleTrailerReveal() {
    if (widget.videoId == null) return;
    _revealTimer = Timer(StreamloadMotion.trailerRevealDelay, () {
      if (!mounted) return;
      setState(() => _trailerVisible = true);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _trailerKey.currentState?.setMuted(_muted);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _Backdrop(url: widget.backdropUrl),
        if (widget.videoId != null)
          AnimatedOpacity(
            duration: StreamloadMotion.heroCrossfade,
            curve: StreamloadMotion.heroCrossfadeCurve,
            opacity: _trailerVisible ? 1.0 : 0.0,
            child: HeroTrailer(
              key: _trailerKey,
              videoId: widget.videoId!,
              muted: _muted,
            ),
          ),
        const _BottomGradient(),
        if (widget.showMuteToggle && widget.videoId != null)
          Align(
            alignment: widget.muteToggleAlignment,
            child: Padding(
              padding: widget.muteToggleMargin,
              child: _GlassCircle(
                icon: _muted ? Icons.volume_off : Icons.volume_up,
                tooltip: _muted ? 'Riattiva audio' : 'Disattiva audio',
                onTap: _toggleMute,
              ),
            ),
          ),
      ],
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(color: StreamloadColors.v3BgBase);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: StreamloadColors.v3BgBase),
      errorWidget: (_, __, ___) => Container(color: StreamloadColors.v3BgBase),
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

/// Glass-circle icon button — used by the 🔊 mute toggle. Kept private to
/// this file because HeroSlide / TitlePage share the same look and only
/// HeroBackdrop renders it; no need to expose a public widget.
class _GlassCircle extends StatelessWidget {
  const _GlassCircle({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: StreamloadColors.v3CtaSecondaryBg,
        shape: CircleBorder(
          side: BorderSide(color: StreamloadColors.v3BorderGlass),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(StreamloadSpacing.cardGap),
            child: Icon(
              icon,
              size: 18,
              color: StreamloadColors.v3TextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
