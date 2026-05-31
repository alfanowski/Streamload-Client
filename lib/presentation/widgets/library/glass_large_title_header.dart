// lib/presentation/widgets/library/glass_large_title_header.dart
//
// Nav Apple-style per "La mia lista": un titolo grande (Fraunces) che, scrollando,
// collassa in una barra compatta in liquid glass nativo (GlassSurface → Apple
// Liquid Glass su iOS). In modalità isolata mostra un chevron back + il nome
// categoria.
import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../primitives/glass_surface.dart';

class GlassLargeTitleHeader extends SliverPersistentHeaderDelegate {
  GlassLargeTitleHeader({
    required this.title,
    required this.topPadding,
    this.isolatedLabel,
    this.onBack,
  });

  final String title;
  final double topPadding;

  /// Quando non-null, la barra è in modalità "categoria isolata": chevron back
  /// a sinistra + questo testo come titolo, niente large title.
  final String? isolatedLabel;
  final VoidCallback? onBack;

  static const double _compactBar = 52;
  static const double _largeBand = 60;

  @override
  double get maxExtent => topPadding + _compactBar + _largeBand;

  @override
  double get minExtent => topPadding + _compactBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isolated = isolatedLabel != null;
    // t: 0 = espanso, 1 = collassato.
    final t = (shrinkOffset / _largeBand).clamp(0.0, 1.0);
    final glassOpacity = isolated ? 1.0 : t;

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Barra glass compatta pinnata in alto (il vetro entra man mano che t→1).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + _compactBar,
            child: Opacity(
              opacity: glassOpacity,
              child: const GlassSurface(
                borderRadius: 0,
                child: SizedBox.expand(),
              ),
            ),
          ),
          // Titolo piccolo centrato nella barra compatta.
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            height: _compactBar,
            child: Opacity(
              opacity: isolated ? 1.0 : t,
              child: Center(
                child: Text(
                  isolated ? isolatedLabel! : title,
                  style: StreamloadTypography.display(fontSize: 17, italic: false)
                      .copyWith(color: StreamloadColors.v3TextPrimary),
                ),
              ),
            ),
          ),
          // Chevron back (solo isolata).
          if (isolated)
            Positioned(
              top: topPadding,
              left: 4,
              height: _compactBar,
              child: IconButton(
                icon: const Icon(Icons.chevron_left),
                color: StreamloadColors.v3TextPrimary,
                onPressed: onBack,
              ),
            ),
          // Large title (solo overview, svanisce mentre t→1).
          if (!isolated)
            Positioned(
              left: 16,
              right: 16,
              bottom: 8,
              child: Opacity(
                opacity: 1 - t,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StreamloadTypography.display(fontSize: 32, italic: false)
                      .copyWith(color: StreamloadColors.v3TextPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant GlassLargeTitleHeader old) =>
      old.title != title ||
      old.topPadding != topPadding ||
      old.isolatedLabel != isolatedLabel ||
      old.onBack != onBack;
}
