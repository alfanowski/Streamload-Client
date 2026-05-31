// lib/presentation/widgets/library/glass_large_title_header.dart
//
// Nav Apple-style per "La mia lista": un titolo grande (Fraunces) che, scrollando,
// scorre SOTTO una barra in liquid glass nativo (GlassSurface → Apple Liquid Glass
// su iOS) e lascia il posto a un titolo piccolo centrato.
//
// La barra glass è SEMPRE renderizzata (niente Opacity animata sul platform-view
// nativo, che su iOS produce flicker): a riposo, su sfondo nero e senza contenuto
// sotto, è impercettibile; appena i poster scorrono sotto, il vetro li rifrange —
// esattamente come una nav bar iOS. Solo i due TESTI fanno cross-fade.
import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../primitives/glass_surface.dart';

class GlassLargeTitleHeader extends SliverPersistentHeaderDelegate {
  GlassLargeTitleHeader({
    required this.title,
    required this.topPadding,
  });

  final String title;
  final double topPadding;

  /// Altezza della barra compatta (contenuto, sotto la status bar).
  static const double _barHeight = 44;

  /// Banda extra del large title sotto la barra.
  static const double _largeBand = 54;

  @override
  double get maxExtent => topPadding + _barHeight + _largeBand;

  @override
  double get minExtent => topPadding + _barHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 1 = espanso (large title pieno), 0 = collassato (solo barra + small title).
    final largeT = (1 - shrinkOffset / _largeBand).clamp(0.0, 1.0);

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          // Large title — ancorato al fondo della banda (che si accorcia mentre
          // collassa), così risale naturalmente e svanisce dietro la barra.
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
                    .copyWith(color: StreamloadColors.v3TextPrimary),
              ),
            ),
          ),
          // Barra glass sempre presente, disegnata SOPRA il large title così
          // questo le scorre dietro.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + _barHeight,
            child: const GlassSurface(
              borderRadius: 0,
              child: SizedBox.expand(),
            ),
          ),
          // Titolo piccolo centrato nella barra — entra in cross-fade mentre il
          // large title esce.
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            height: _barHeight,
            child: Opacity(
              opacity: 1 - largeT,
              child: Center(
                child: Text(
                  title,
                  style: StreamloadTypography.display(fontSize: 17, italic: false)
                      .copyWith(color: StreamloadColors.v3TextPrimary),
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
