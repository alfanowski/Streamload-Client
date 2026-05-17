// lib/presentation/widgets/liquid_glass.dart
//
// LiquidGlass — Apple-style "liquid glass" surface (Pass 2B of the v3 UI
// refactor). Approximates the iOS 26 / macOS Tahoe vibe in Flutter using
// primitives we already have:
//
//   1. ClipRRect at the requested radius so the blur composites cleanly.
//   2. BackdropFilter(blur) reads the underlying content and softens it
//      — this is the "wet" feel that distinguishes glass from plain
//      tinted Container.
//   3. A subtle vertical gradient (white highlight at the top → tint at
//      the bottom) gives the surface depth without ColorFilter math.
//   4. A 1px gradient border (white24 → white12) at the top edge plays
//      the role of a reflective "wet" highlight on the rim.
//   5. The whole stack accepts an optional [tint] so callers can warm
//      the glass with the brand yellow on hover / active states.
//
// We intentionally skip the ColorFilter saturation boost mentioned in the
// brief — every additional layer is GPU cost we pay 60 fps for, and the
// blur + tint already reads convincingly as glass in the dark theme.
// If the operator wants a punchier effect later, dial blur up to 40+
// rather than stacking matrix filters.
//
// Usage examples (see Pass 2B callers for the real wiring):
//
//   // Floating nav bar (transparent over the body):
//   LiquidGlass(
//     borderRadius: BorderRadius.zero,
//     opacity: 0.35,
//     child: SafeArea(child: Row(children: [...])),
//   )
//
//   // Popover menu surface:
//   LiquidGlass(
//     borderRadius: BorderRadius.circular(14),
//     opacity: 0.55,
//     tint: StreamloadColors.v3PopoverBg,
//     child: ...,
//   )
//
//   // Brand-tinted hover pill:
//   LiquidGlass(
//     borderRadius: BorderRadius.circular(20),
//     tint: StreamloadColors.v3AccentYellow,
//     opacity: 0.16,
//     child: ...,
//   )
//
// The widget is a pure visual primitive — no state, no controllers. Drop
// it anywhere a Container + BackdropFilter combo would have gone.
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/colors.dart';

class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius,
    this.tint,
    this.opacity = 0.10,
    this.blur = 32,
    this.borderOpacity = 0.18,
    this.padding,
    this.highlight = true,
  });

  /// Subject of the glass surface — laid out unchanged inside the padded
  /// interior. Wrap layout widgets (Padding, Column, etc.) — LiquidGlass
  /// owns the surface chrome only.
  final Widget child;

  /// Corner radius of the glass card. Null = sharp corners (e.g. a full-
  /// width nav bar). Use a small radius (8–14) for pills and popovers,
  /// larger (20–28) for cards.
  final BorderRadius? borderRadius;

  /// Base tint color. Null = neutral white tint (most callers). Pass the
  /// brand yellow for hover/active surfaces; pass v3PopoverBg for dark
  /// floating menus that need a more opaque substrate.
  final Color? tint;

  /// 0..1 — alpha of the [tint] fill layer above the backdrop blur.
  /// 0.08–0.18 reads as glass; 0.5+ starts feeling like a flat container.
  final double opacity;

  /// BackdropFilter sigma. The visible "blurriness" of the underlying
  /// content. 16 is subtle, 32 (default) is the Apple sweet spot, 48+
  /// turns the substrate into a smear.
  final double blur;

  /// Alpha of the 1px reflective border that sits along the entire rim.
  /// 0.10–0.24 reads as a "wet edge"; higher and it starts looking like
  /// a hard outline. The top edge gets an extra highlight gradient when
  /// [highlight] is true.
  final double borderOpacity;

  /// Inner padding applied to [child]. Optional — most call sites prefer
  /// to add their own Padding inside `child` for finer control.
  final EdgeInsetsGeometry? padding;

  /// When true, paints an extra brighter band along the top edge to
  /// simulate the wet highlight on a glass rim. Disable for surfaces
  /// where another widget is rendered immediately above the glass (e.g.
  /// a nav bar pinned to the device notch).
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final tintColor = tint ?? const Color(0xFFFFFFFF);

    Widget inner = child;
    if (padding != null) {
      inner = Padding(padding: padding!, child: inner);
    }

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          // Diagonal gradient: brighter top-left, slightly cooler bottom-
          // right. Mimics the way real glass picks up ambient light from
          // above and behind. Tint controls both stops so a yellow tint
          // looks warm-on-warm instead of yellow-on-white.
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tintColor.withValues(alpha: opacity + 0.04),
                tintColor.withValues(alpha: opacity),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              if (highlight)
                // The "wet rim" highlight: 1px tall white-fading-to-clear
                // strip at the very top of the glass, only visible when
                // there's another surface above. Lives inside the
                // borderRadius clip so curved corners stay clean.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              inner,
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience extension: spawn a tinted LiquidGlass at the brand yellow
/// for "active state" decorations (hover chips, pressed pills, etc.).
/// Saves a dozen repeated `LiquidGlass(tint: v3AccentYellow, opacity:
/// 0.16, ...)` calls across the call sites.
LiquidGlass liquidGlassYellow({
  Key? key,
  required Widget child,
  BorderRadius? borderRadius,
  EdgeInsetsGeometry? padding,
}) {
  return LiquidGlass(
    key: key,
    borderRadius: borderRadius,
    padding: padding,
    tint: StreamloadColors.v3AccentYellow,
    opacity: 0.16,
    borderOpacity: 0.22,
    blur: 24,
    child: child,
  );
}
