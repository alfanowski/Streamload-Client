// lib/presentation/widgets/hero/hero_carousel.dart
//
// HeroCarousel — rotates a list of HeroSlide entries every
// StreamloadMotion.heroRotateInterval (30s) using a PageView.
//
// Interactions:
//   - desktop : hover anywhere on the carousel pauses auto-advance;
//               hover also reveals ◀ ▶ glass arrows on the edges
//   - mobile  : a single tap toggles pause; swipe to advance manually
//               (PageView already handles drag gestures); no arrows
//   - indicator dots bottom-right reflect current page; active dot is
//     wider (24×3) and brighter, others (18×3) at 30% white
//
// Data is supplied as a list of HeroSlideData records so the carousel
// stays a pure visual primitive — Phase D wires real providers to it.
import 'dart:async';

import 'package:flutter/material.dart';

import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/motion.dart';
import '../../theme/spacing.dart';
import 'hero_slide.dart';

/// Plain data carrier for a single slide. Mirrors HeroSlide's constructor
/// args 1:1 — the carousel only forwards them.
class HeroSlideData {
  const HeroSlideData({
    required this.title,
    required this.mediaType,
    this.year,
    this.runtimeMinutes,
    this.episodeCount,
    this.rating,
    this.synopsis,
    this.backdropUrl,
    this.videoId,
    this.languageCode = 'IT',
    this.onPlay,
    this.onAdd,
  });

  final String title;
  final String mediaType;
  final int? year;
  final int? runtimeMinutes;
  final int? episodeCount;
  final double? rating;
  final String? synopsis;
  final String? backdropUrl;
  final String? videoId;
  final String languageCode;
  final VoidCallback? onPlay;
  final VoidCallback? onAdd;
}

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    super.key,
    required this.slides,
    this.height = 480,
  });

  final List<HeroSlideData> slides;

  /// Hero strip height in logical pixels. Caller picks per-breakpoint.
  final double height;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _controller = PageController();
  Timer? _autoTimer;
  int _current = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant HeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length) {
      _restartTimer();
    }
  }

  void _startTimer() {
    if (widget.slides.length < 2) return;
    _autoTimer = Timer.periodic(StreamloadMotion.heroRotateInterval, (_) {
      if (_paused || !mounted) return;
      _advance(1);
    });
  }

  void _restartTimer() {
    _autoTimer?.cancel();
    _startTimer();
  }

  void _advance(int delta) {
    if (widget.slides.isEmpty) return;
    final next = (_current + delta) % widget.slides.length;
    final wrapped = next < 0 ? widget.slides.length - 1 : next;
    _controller.animateToPage(
      wrapped,
      duration: StreamloadMotion.heroCrossfade,
      curve: StreamloadMotion.heroCrossfadeCurve,
    );
  }

  void _pause() {
    if (!_paused) setState(() => _paused = true);
  }

  void _resume() {
    if (_paused) setState(() => _paused = false);
  }

  void _toggleMobilePause() {
    setState(() => _paused = !_paused);
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return SizedBox(height: widget.height);
    }
    final isMobile = Responsive.isMobile(context);

    final pageView = PageView.builder(
      controller: _controller,
      itemCount: widget.slides.length,
      onPageChanged: (i) => setState(() => _current = i),
      itemBuilder: (context, i) {
        final s = widget.slides[i];
        return HeroSlide(
          title: s.title,
          mediaType: s.mediaType,
          year: s.year,
          runtimeMinutes: s.runtimeMinutes,
          episodeCount: s.episodeCount,
          rating: s.rating,
          synopsis: s.synopsis,
          backdropUrl: s.backdropUrl,
          videoId: s.videoId,
          languageCode: s.languageCode,
          // Eyebrow label shows position in the carousel ("IN EVIDENZA · 2 DI 5").
          label: 'IN EVIDENZA · ${i + 1} DI ${widget.slides.length}',
          onPlay: s.onPlay,
          onAdd: s.onAdd,
        );
      },
    );

    Widget body = pageView;

    if (isMobile) {
      body = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _toggleMobilePause,
        child: body,
      );
    } else {
      body = MouseRegion(
        onEnter: (_) => _pause(),
        onExit: (_) => _resume(),
        child: body,
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(child: body),
          // Indicator dots (always visible).
          Positioned(
            right: isMobile ? 16 : 48,
            bottom: 18,
            child: _Indicator(
              count: widget.slides.length,
              active: _current,
            ),
          ),
          // Arrow buttons — desktop / tablet only. We use IgnorePointer
          // on the wrapper when there's a single slide so they don't
          // intercept taps on the hero CTAs.
          if (!isMobile && widget.slides.length > 1)
            Positioned.fill(
              child: _HoverArrows(
                onPrev: () => _advance(-1),
                onNext: () => _advance(1),
              ),
            ),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.count, required this.active});
  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: StreamloadMotion.hoverDuration,
            curve: StreamloadMotion.hoverCurve,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 24 : 18,
            height: 3,
            decoration: BoxDecoration(
              color: i == active
                  ? StreamloadColors.v3TextPrimary
                  : const Color(0xFFFFFFFF).withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

/// Hover-only ◀ ▶ glass circles on the edges of the carousel. The whole
/// overlay is a MouseRegion so the arrows only render when the cursor is
/// inside the hero — on touch devices they're suppressed by the parent's
/// isMobile branch.
class _HoverArrows extends StatefulWidget {
  const _HoverArrows({required this.onPrev, required this.onNext});
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  State<_HoverArrows> createState() => _HoverArrowsState();
}

class _HoverArrowsState extends State<_HoverArrows> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      // IgnorePointer on the *outer* pass-through layer so taps that miss
      // the arrows still reach the slide CTAs underneath.
      child: IgnorePointer(
        ignoring: !_hovering,
        child: AnimatedOpacity(
          duration: StreamloadMotion.hoverDuration,
          opacity: _hovering ? 1.0 : 0.0,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _Arrow(icon: Icons.chevron_left, onTap: widget.onPrev),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _Arrow(icon: Icons.chevron_right, onTap: widget.onNext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
            color: StreamloadColors.v3TextPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }
}
