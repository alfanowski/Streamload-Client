// lib/presentation/responsive.dart
//
// Breakpoint helper for the v3 UI refactor. Same widgets render on desktop /
// tablet / phone; layouts branch on these breakpoints inside LayoutBuilder
// or via the helper methods below.
//
// Phone        < 600 px wide
// Tablet      600..899
// Desktop     ≥ 900
//
// Rationale: at 600 px the standard 16:9 video tile + side metadata stops
// fitting horizontally; at 900 px the 2-column title page (synopsis 2/3 +
// cast sidebar 1/3) becomes the natural layout.
import 'package:flutter/widgets.dart';

class Breakpoints {
  Breakpoints._();
  static const double phone = 600.0;
  static const double tablet = 900.0;
}

class Responsive {
  Responsive._();

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Device-class metric: the screen's SHORTEST side, not the current width.
  /// Branching on this means rotating a phone into landscape (the video
  /// player) does NOT flip the UI into the desktop layout — a phone stays a
  /// phone in any orientation. (The old width-based check made the landscape
  /// player render the desktop shell.)
  static double _deviceWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide;

  static bool isPhone(BuildContext context) =>
      _deviceWidth(context) < Breakpoints.phone;

  static bool isTablet(BuildContext context) {
    final w = _deviceWidth(context);
    return w >= Breakpoints.phone && w < Breakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) =>
      _deviceWidth(context) >= Breakpoints.tablet;

  /// True for phone + tablet (any non-desktop). Useful for "no hover effects"
  /// branches that should also apply to small tablets in portrait.
  static bool isMobile(BuildContext context) =>
      _deviceWidth(context) < Breakpoints.tablet;
}
