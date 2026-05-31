// lib/presentation/widgets/modal/stretchy_hero_scroll_view.dart
//
// StretchyHeroScrollView — a CustomScrollView whose first sliver is a hero
// that ZOOMS like the Home hero on a downward overscroll at the top, then
// scrolls away naturally (no SliverAppBar parallax / pin / overlap).
//
// The zoom is a PAINT-ONLY transform on the hero: we cancel the overscroll
// shift and grow the hero downward so it fills the gap and scales up. Its
// layout height never changes, so normal scroll-down stays a clean 1:1. At
// rest (overscroll == 0) the transform is the identity.
import 'package:flutter/material.dart';

class StretchyHeroScrollView extends StatefulWidget {
  const StretchyHeroScrollView({
    super.key,
    required this.heroHeight,
    required this.hero,
    required this.slivers,
    this.maxStretch = 220,
  });

  /// Resting height of the hero (it's free to paint taller on overscroll).
  final double heroHeight;

  /// Hero content, sized to [heroHeight] by this widget.
  final Widget hero;

  /// Body slivers rendered below the hero.
  final List<Widget> slivers;

  /// How far the hero may stretch before the pull stops growing it.
  final double maxStretch;

  @override
  State<StretchyHeroScrollView> createState() => _StretchyHeroScrollViewState();
}

class _StretchyHeroScrollViewState extends State<StretchyHeroScrollView> {
  double _overscroll = 0;

  bool _onScroll(ScrollNotification n) {
    if (n is ScrollUpdateNotification || n is OverscrollNotification) {
      final o = (n.metrics.minScrollExtent - n.metrics.pixels)
          .clamp(0.0, widget.maxStretch)
          .toDouble();
      if ((o - _overscroll).abs() > 0.5) setState(() => _overscroll = o);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.heroHeight;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: h,
              child: Transform.translate(
                offset: Offset(0, -_overscroll),
                child: Transform.scale(
                  scale: (h + _overscroll) / h,
                  alignment: Alignment.topCenter,
                  child: widget.hero,
                ),
              ),
            ),
          ),
          ...widget.slivers,
        ],
      ),
    );
  }
}
