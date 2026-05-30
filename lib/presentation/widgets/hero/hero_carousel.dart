// lib/presentation/widgets/hero/hero_carousel.dart
//
// HeroCarousel — shows a list of HeroSlide entries one at a time, advancing
// MANUALLY (no auto-rotate) with a clean discrete CROSSFADE between slides.
//
// The crossfade lives on its own layer (backdrop + title dissolve together)
// while a SINGLE stable CTA row sits on top — so the native glass buttons
// never animate / flicker, and the title always matches its backdrop. The
// transition is a discrete AnimatedSwitcher (always completes), never a
// finger-following drag, so it can't get stuck half-way.
//
// Interactions:
//   - desktop : hover reveals ◀ ▶ glass arrows on the edges; click to advance
//   - mobile  : a horizontal swipe (fling) commits exactly one step; a tap
//               opens the title. Swiping on a CTA never changes slide.
//   - indicator dots reflect the current slide; active dot is wider/brighter
//
// Data is supplied as a list of HeroSlideData records so the carousel
// stays a pure visual primitive — Phase D wires real providers to it.

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

class _HeroCarouselState extends State<HeroCarousel> {
  // Index of the slide currently shown. Advancing wraps both ways
  // (circular). The transition between slides is a clean crossfade — the
  // backdrop + title dissolve together while the CTAs stay put.
  int _current = 0;

  // +1 when moving forward, -1 when moving back. Drives which direction the
  // crossfade slides a hair (a few px) so the dissolve feels directional
  // without becoming a full slide.
  int _dir = 1;

  int get _len => widget.slides.length;

  void _advance(int delta) {
    if (_len < 2) return;
    setState(() {
      _dir = delta >= 0 ? 1 : -1;
      _current = (_current + delta) % _len;
      if (_current < 0) _current += _len;
    });
  }

  HeroSlideData get _slide => widget.slides[_current.clamp(0, _len - 1)];

  // A clean discrete crossfade: the outgoing child fades out as the incoming
  // one fades in (plus a tiny directional drift). Always completes — no
  // finger-following, so it can never get stuck half-way.
  //
  // [expand] picks the layout: the backdrop fills the hero (StackFit.expand,
  // it lives in a Positioned.fill), while the title block self-sizes inside
  // the metadata Column (default loose, centred) so it never demands an
  // infinite height.
  Widget _crossfade(Widget child, {bool expand = false}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 480),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: expand
          ? (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, if (current != null) current],
              )
          : AnimatedSwitcher.defaultLayoutBuilder,
      transitionBuilder: (c, anim) {
        final slide = Tween<Offset>(
          begin: Offset(0.04 * _dir, 0),
          end: Offset.zero,
        ).animate(anim);
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(position: slide, child: c),
        );
      },
      child: KeyedSubtree(key: ValueKey<int>(_current), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return SizedBox(height: widget.height);
    }
    final isMobile = Responsive.isMobile(context);
    final count = _len;
    final s = _slide;

    // The backdrop crossfades on its own layer; a SINGLE stable CTA row sits
    // on top (so the native glass buttons never animate / flicker), with the
    // title text crossfading right above them.
    Widget content = Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: _crossfade(
            HeroBackdrop(backdropUrl: s.backdropUrl, posterUrl: s.posterUrl),
            expand: true,
          ),
        ),
        Positioned.fill(
          child: HeroMetadata(
            text: _crossfade(
              HeroText(
                title: s.title,
                mediaType: s.mediaType,
                year: s.year,
                runtimeMinutes: s.runtimeMinutes,
                episodeCount: s.episodeCount,
                rating: s.rating,
                label: 'IN EVIDENZA',
                languageCode: s.languageCode,
              ),
            ),
            ctas: HeroCtas(onPlay: s.onPlay, onAdd: s.onAdd),
          ),
        ),
      ],
    );

    // Mobile: a swipe (fling) commits exactly one step. We use drag *end*
    // velocity — not finger position — so the dissolve is a clean discrete
    // animation, never a stuck half-state. Touches that land on the native
    // CTAs are captured by them, so dragging a button never changes slide.
    if (isMobile) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: s.onOpen,
        onHorizontalDragEnd: count < 2
            ? null
            : (d) {
                final v = d.primaryVelocity ?? 0;
                if (v < -250) {
                  _advance(1);
                } else if (v > 250) {
                  _advance(-1);
                }
              },
        child: content,
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(child: content),
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
                onPrev: () => _advance(-1),
                onNext: () => _advance(1),
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
