// lib/presentation/widgets/library/glass_large_title_header.dart
//
// Header di "La mia lista" coerente con la Home: NESSUNA barra/box (la Home non
// ne ha — solo il wordmark che svanisce + lo scrim Dynamic Island di AppShell).
// Un large title Fraunces che, scrollando, fa cross-fade in un titolo piccolo
// centrato. La leggibilità sui poster che scorrono sotto è data da un'ombra sul
// testo, esattamente come il wordmark della Home — non da un pannello glass, che
// a tutta larghezza renderizzava come un brutto rettangolo opaco.
import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

class GlassLargeTitleHeader extends SliverPersistentHeaderDelegate {
  GlassLargeTitleHeader({
    required this.title,
    required this.topPadding,
  });

  final String title;
  final double topPadding;

  /// Banda della status bar / area titolo compatto.
  static const double _barHeight = 44;

  /// Banda extra del large title sotto la barra.
  static const double _largeBand = 54;

  /// Ombra morbida che rende i titoli leggibili sui poster che scorrono sotto —
  /// stessa idea del wordmark della Home.
  static const List<Shadow> _legibilityShadow = [
    Shadow(color: Colors.black, blurRadius: 14),
    Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
  ];

  @override
  double get maxExtent => topPadding + _barHeight + _largeBand;

  @override
  double get minExtent => topPadding + _barHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 1 = espanso (large title pieno), 0 = collassato (solo small title).
    final largeT = (1 - shrinkOffset / _largeBand).clamp(0.0, 1.0);

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          // Large title — ancorato al fondo della banda (che si accorcia mentre
          // collassa), così risale e svanisce.
          Positioned(
            left: 20,
            right: 20,
            bottom: 10,
            child: Opacity(
              opacity: largeT,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StreamloadTypography.display(fontSize: 30, italic: false)
                    .copyWith(
                  color: StreamloadColors.v3TextPrimary,
                  shadows: _legibilityShadow,
                ),
              ),
            ),
          ),
          // Titolo piccolo centrato — entra in cross-fade mentre il large esce.
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            height: _barHeight,
            child: IgnorePointer(
              ignoring: largeT > 0.5,
              child: Opacity(
                opacity: 1 - largeT,
                child: Center(
                  child: Text(
                    title,
                    style: StreamloadTypography.display(
                            fontSize: 17, italic: false)
                        .copyWith(
                      color: StreamloadColors.v3TextPrimary,
                      shadows: _legibilityShadow,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant GlassLargeTitleHeader old) =>
      old.title != title || old.topPadding != topPadding;
}
