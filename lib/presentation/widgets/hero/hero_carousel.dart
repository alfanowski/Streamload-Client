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
  // PREVIOUS; |_v| is the crossfade progress toward that neighbour. It's a
  // ValueNotifier so dragging rebuilds ONLY the backdrop layer (cheap) —
  // never the native platform-view buttons, which would stutter/freeze if
  // rebuilt every frame.
  final ValueNotifier<double> _v = ValueNotifier<double>(0);
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
    // Updates the notifier only → rebuilds the backdrop layer, not the
    // native buttons.
    final t = Curves.easeInOut.transform(_snap.value);
    _v.value = _snapFrom + (_snapTo - _snapFrom) * t;
  }

  void _onSnapStatus(AnimationStatus st) {
    if (st != AnimationStatus.completed) return;
    if (_snapTo != 0) {
      // Commit: rebuild the metadata for the new current slide (one setState
      // per transition, not per frame).
      setState(() {
        _current = _snapTo < 0 ? _nextIndex : _prevIndex;
      });
    }
    _v.value = 0;
    _snap.reset();
    _paused = false;
  }

  void _settle(double to) {
    if (_len < 2) return;
    _snapFrom = _v.value;
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

  // The neighbour the current drag is locked onto: -1 = next, +1 = prev,
  // 0 = not yet locked. Locks to ONE shift per drag so you can never drag
  // past the adjacent slide (and can't flip mid-drag) — the source of bugs.
  int _dragLockedSign = 0;

  void _onDragStart(DragStartDetails _) {
    _snap.stop();
    _paused = true;
    _dragLockedSign = 0;
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
    var nv = _v.value + d.delta.dx / w;
    // Lock the direction on first real movement.
    if (_dragLockedSign == 0 && nv.abs() > 0.02) {
      _dragLockedSign = nv < 0 ? -1 : 1;
    }
    // Constrain to the locked neighbour only: never cross 0 to the other
    // side, never go past ±1 (one shift per drag).
    if (_dragLockedSign < 0) {
      nv = nv.clamp(-1.0, 0.0);
    } else if (_dragLockedSign > 0) {
      nv = nv.clamp(0.0, 1.0);
    } else {
      nv = nv.clamp(-1.0, 1.0);
    }
    // No setState — only the notifier changes → backdrop-only rebuild.
    _v.value = nv;
  }

  void _onDragEnd(DragEndDetails d) {
    final vel = d.primaryVelocity ?? 0;
    final v = _v.value;
    if (v <= -0.25 || vel < -400) {
      _settle(-1);
    } else if (v >= 0.25 || vel > 400) {
      _settle(1);
    } else {
      _settle(0);
    }
  }

  // If the drag is cancelled mid-way, always snap back — never leave the
  // hero stuck showing half of one slide and half of another.
  void _onDragCancel() => _settle(0);

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

  Widget _heroText(int i) {
    final s = widget.slides[i];
    return HeroText(
      title: s.title,
      mediaType: s.mediaType,
      year: s.year,
      runtimeMinutes: s.runtimeMinutes,
      episodeCount: s.episodeCount,
      rating: s.rating,
      label: 'IN EVIDENZA',
      languageCode: s.languageCode,
    );
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _snap.dispose();
    _v.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return SizedBox(height: widget.height);
    }
    final isMobile = Responsive.isMobile(context);
    final count = widget.slides.length;
    final cur = widget.slides[_current];

    // Backdrop crossfade — the ONLY thing that rebuilds during a drag (driven
    // by the _v notifier). Native buttons live on a separate stable layer.
    final Widget backdrops = ValueListenableBuilder<double>(
      valueListenable: _v,
      builder: (context, v, _) {
        final mag = v.abs().clamp(0.0, 1.0);
        final neighbour = v == 0 ? null : (v < 0 ? _nextIndex : _prevIndex);
        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(opacity: 1 - mag, child: _backdrop(_current)),
            if (neighbour != null)
              Opacity(opacity: mag, child: _backdrop(neighbour)),
          ],
        );
      },
    );

    // The drag / tap gesture sits ONLY on the backdrop layer. The CTA buttons
    // are a sibling ON TOP — so touching / stretching a button never starts a
    // slide-change drag.
    Widget interactive;
    if (isMobile) {
      interactive = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _withReset(cur.onOpen),
        onHorizontalDragStart: count < 2 ? null : _onDragStart,
        onHorizontalDragUpdate: count < 2 ? null : _onDragUpdate,
        onHorizontalDragEnd: count < 2 ? null : _onDragEnd,
        onHorizontalDragCancel: count < 2 ? null : _onDragCancel,
        child: backdrops,
      );
    } else {
      interactive = MouseRegion(
        onEnter: (_) => _pause(),
        onExit: (_) => _resume(),
        child: GestureDetector(onTap: _withReset(cur.onOpen), child: backdrops),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(child: interactive),
          // Metadata layer: the TEXT crossfades with the backdrop (so the
          // title always matches), while the native CTA buttons stay STABLE
          // (never animated → no glitch/flicker). The buttons capture their
          // own touches; the empty areas let the drag/tap below through.
          Positioned.fill(
            child: HeroMetadata(
              text: ValueListenableBuilder<double>(
                valueListenable: _v,
                builder: (context, v, _) {
                  final mag = v.abs().clamp(0.0, 1.0);
                  final n = v == 0 ? null : (v < 0 ? _nextIndex : _prevIndex);
                  final align = Responsive.isPhone(context)
                      ? Alignment.bottomCenter
                      : Alignment.bottomLeft;
                  return Stack(
                    alignment: align,
                    children: [
                      Opacity(opacity: 1 - mag, child: _heroText(_current)),
                      if (n != null)
                        Opacity(opacity: mag, child: _heroText(n)),
                    ],
                  );
                },
              ),
              ctas: HeroCtas(
                onPlay: _withReset(cur.onPlay),
                onAdd: _withReset(cur.onAdd),
              ),
            ),
          ),
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
