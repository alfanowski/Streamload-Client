// lib/presentation/theme/spacing.dart
// v3 Netflix×AppleTV refactor spacing tokens (sub-plan 8, Phase A1).
//
// 2026-05-17 (Cinema Magazine pivot, CM-8): per-breakpoint row gaps +
// roomier page padding on desktop. Editorial density — let the rows
// breathe instead of compressing the page into a Netflix wall.
import 'package:flutter/widgets.dart';

class StreamloadSpacing {
  StreamloadSpacing._();

  /// Vertical gap between rows on Home / browse pages. Desktop default
  /// (kept on [rowGap] for back-compat with call sites that haven't
  /// branched on breakpoint yet). Per-breakpoint tokens below.
  static const double rowGap = 56.0;

  /// Per-breakpoint row gaps — CM-8. HomePage picks the right one based
  /// on Responsive.is*. Tablet sits between desktop and phone so the
  /// iPad layout doesn't feel as crammed as the phone layout would.
  static const double rowGapDesktop = 56.0;
  static const double rowGapTablet = 32.0;
  static const double rowGapPhone = 24.0;

  /// Page horizontal padding by breakpoint. CM-8 bumps desktop from 48
  /// to 64 so the page reads as a magazine spread with generous outer
  /// margins, not a Netflix full-bleed wall.
  static const EdgeInsets pagePaddingDesktop = EdgeInsets.symmetric(horizontal: 64);
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
