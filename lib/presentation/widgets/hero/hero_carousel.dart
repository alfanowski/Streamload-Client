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
import 'hero_backdrop.dart';
import 'hero_slide.dart';

/// Plain data carrier for a single slide. Mirrors HeroSlide's constructor
/// args 1:1 — the carousel only forwards them.
class HeroSlideData {
  const HeroSlideData({
    required this.title,
    required this.mediaType,
    this.tmdbId,
    this.year,
    this.runtimeMinutes,
    this.episodeCount,
    this.rating,
    this.synopsis,
    this.backdropUrl,
    this.posterUrl,
    this.videoId,
    this.languageCode = 'IT',
    this.onPlay,
    this.onAdd,
    this.onOpen,
  });

  final String title;
  final String mediaType;

  /// Optional — the carousel itself never reads it, but pages that wire
  /// onPlay / onAdd may want it to navigate to /title/:id or toggle
  /// favorites without having to look it up by title.
  final int? tmdbId;
  final int? year;
  final int? runtimeMinutes;
  final int? episodeCount;
  final double? rating;
  final String? synopsis;
  final String? backdropUrl;

  /// Fallback shown when [backdropUrl] is null — TMDB poster gets cropped
  /// to the hero's 16:9-ish frame so we never render a black slab.
  final String? posterUrl;

  /// Kept for source compatibility — heroes no longer autoplay trailers
  /// (operator dropped that feature on May 16). HeroSlide ignores it.
  final String? videoId;
  final String languageCode;
  final VoidCallback? onPlay;
  final VoidCallback? onAdd;

  /// Tap on the hero (outside the CTAs) → open the title page (Netflix-style).
  final VoidCallback? onOpen;
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

class _HeroCarouselState extends State<HeroCarousel>
    with SingleTickerProviderStateMixin {
  Timer? _autoTimer;
  int _current = 0;
  bool _paused = false;

  // Interactive crossfade. _v ∈ [-1, 1]: < 0 reveals the NEXT slide, > 0 the
  // PREVIOUS; |_v| is the crossfade progress toward that neighbour. While
  // dragging, _v tracks the finger; on release it snaps to ±1 (commit) or 0
  // (cancel) via [_snap].
  double _v = 0;
  double _snapFrom = 0;
  double _snapTo = 0;
  late final AnimationController _snap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  int get _len => widget.slides.length;
  int get _nextIndex => (_current + 1) % _len;
  int get _prevIndex => (_current - 1 + _len) % _len;

  @override
  void initState() {
    super.initState();
    _snap
      ..addListener(_onSnapTick)
      ..addStatusListener(_onSnapStatus);
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant HeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length) {
      _restartTimer();
    }
  }

  void _onSnapTick() {
    final t = Curves.easeInOut.transform(_snap.value);
    setState(() => _v = _snapFrom + (_snapTo - _snapFrom) * t);
  }

  void _onSnapStatus(AnimationStatus st) {
    if (st != AnimationStatus.completed) return;
    if (_snapTo != 0) {
      _current = _snapTo < 0 ? _nextIndex : _prevIndex;
    }
    _v = 0;
    _snap.reset();
    _paused = false;
    if (mounted) setState(() {});
  }

  void _settle(double to) {
    if (_len < 2) return;
    _snapFrom = _v;
    _snapTo = to;
    _snap.forward(from: 0);
  }

  void _startTimer() {
    if (widget.slides.length < 2) return;
    _autoTimer = Timer.periodic(StreamloadMotion.heroRotateInterval, (_) {
      if (_paused || !mounted || _snap.isAnimating) return;
      _settle(-1); // crossfade to the next slide
    });
  }

  void _restartTimer() {
    _autoTimer?.cancel();
    _startTimer();
  }

  void _onDragStart(DragStartDetails _) {
    _snap.stop();
    _paused = true;
    // Any interaction restarts the auto-rotate countdown.
    _restartTimer();
  }

  /// Wrap a slide callback so tapping a CTA also restarts the auto-rotate
  /// countdown (no auto-advance right after the user touches the hero).
  VoidCallback? _withReset(VoidCallback? cb) {
    if (cb == null) return null;
    return () {
      _restartTimer();
      cb();
    };
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_len < 2) return;
    final w = context.size?.width ?? 1;
    setState(() => _v = (_v + d.delta.dx / w).clamp(-1.0, 1.0));
  }

  void _onDragEnd(DragEndDetails d) {
    final vel = d.primaryVelocity ?? 0;
    if (_v <= -0.25 || vel < -400) {
      _settle(-1);
    } else if (_v >= 0.25 || vel > 400) {
      _settle(1);
    } else {
      _settle(0);
    }
  }

  void _pause() {
    if (!_paused) setState(() => _paused = true);
  }

  void _resume() {
    if (_paused) setState(() => _paused = false);
  }

  Widget _backdrop(int i) {
    final s = widget.slides[i];
    return HeroBackdrop(backdropUrl: s.backdropUrl, posterUrl: s.posterUrl);
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _snap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return SizedBox(height: widget.height);
    }
    final isMobile = Responsive.isMobile(context);
    final count = widget.slides.length;
    final mag = _v.abs().clamp(0.0, 1.0);
    final neighbour = _v == 0 ? null : (_v < 0 ? _nextIndex : _prevIndex);
    final cur = widget.slides[_current];

    final Widget content = Stack(
      fit: StackFit.expand,
      children: [
        // Backdrops crossfade interactively (images only → no flicker).
        Opacity(opacity: 1 - mag, child: _backdrop(_current)),
        if (neighbour != null)
          Opacity(opacity: mag, child: _backdrop(neighbour)),
        // A SINGLE metadata/CTA set for the CURRENT slide, ALWAYS mounted
        // and never opacity-animated — native platform-view buttons glitch
        // and freeze if faded/transformed. Only the backdrop crossfades;
        // the text + button targets update on commit.
        Positioned.fill(
          child: HeroMetadata(
            title: cur.title,
            mediaType: cur.mediaType,
            year: cur.year,
            runtimeMinutes: cur.runtimeMinutes,
            episodeCount: cur.episodeCount,
            rating: cur.rating,
            label: 'IN EVIDENZA',
            languageCode: cur.languageCode,
            onPlay: _withReset(cur.onPlay),
            onAdd: _withReset(cur.onAdd),
          ),
        ),
      ],
    );

    Widget body;
    if (isMobile) {
      body = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _withReset(cur.onOpen),
        onHorizontalDragStart: count < 2 ? null : _onDragStart,
        onHorizontalDragUpdate: count < 2 ? null : _onDragUpdate,
        onHorizontalDragEnd: count < 2 ? null : _onDragEnd,
        child: content,
      );
    } else {
      body = MouseRegion(
        onEnter: (_) => _pause(),
        onExit: (_) => _resume(),
        child: GestureDetector(onTap: cur.onOpen, child: content),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(child: body),
          if (count > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: isMobile ? 16 : 22,
              child: Align(
                alignment:
                    isMobile ? Alignment.bottomCenter : Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(right: isMobile ? 0 : 48),
                  child: _Indicator(count: count, active: _current),
                ),
              ),
            ),
          if (!isMobile && count > 1)
            Positioned.fill(
              child: _HoverArrows(
                onPrev: () {
                  _restartTimer();
                  _settle(1);
                },
                onNext: () {
                  _restartTimer();
                  _settle(-1);
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Clean, minimal page indicator: a light-grey pill for the active slide,
/// quiet darker-grey dots for the rest. No accent colour.
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
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF)
                  .withValues(alpha: i == active ? 0.85 : 0.3),
              borderRadius: BorderRadius.circular(3),
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
