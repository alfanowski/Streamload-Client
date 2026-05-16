// lib/presentation/theme/spacing.dart
// v3 Netflix×AppleTV refactor spacing tokens (sub-plan 8, Phase A1).
import 'package:flutter/widgets.dart';

class StreamloadSpacing {
  StreamloadSpacing._();

  /// Vertical gap between rows on Home / browse pages.
  static const double rowGap = 28.0;

  /// Page horizontal padding by breakpoint.
  static const EdgeInsets pagePaddingDesktop = EdgeInsets.symmetric(horizontal: 48);
  static const EdgeInsets pagePaddingTablet = EdgeInsets.symmetric(horizontal: 32);
  static const EdgeInsets pagePaddingPhone = EdgeInsets.symmetric(horizontal: 16);

  /// Gap between cards inside a row.
  static const double cardGap = 8.0;

  /// Corner radii.
  static const double cardRadius = 6.0;
  static const double cardRadiusLarge = 12.0;
  static const double pillRadius = 20.0;
  static const double chipRadius = 14.0;

  /// Card widths by breakpoint (used by PosterCard / BackdropCard).
  static const double posterCardWidthDesktop = 160;
  static const double posterCardWidthTablet = 130;
  static const double posterCardWidthPhone = 110;
  static const double backdropCardWidthDesktop = 320;
  static const double backdropCardWidthTablet = 260;
  static const double backdropCardWidthPhone = 220;
}
