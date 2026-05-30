// lib/presentation/widgets/hero/hero_cta_button.dart
//
// HeroCtaButton — the hero's two actions, both real liquid glass but clearly
// differentiated:
//
//   .primary  → "Guarda": a BRIGHT frosted-white glass (ice) with dark text.
//               Reads as the primary action, still translucent/blurred — not
//               a flat opaque pill.
//   .glass    → "La mia lista": the neutral dark glass with white text.
//               [active] (already in the list) turns it GREEN — green check,
//               green rim, faint green wash — so "added" is obvious.
//
// Pure Flutter (no platform views): pixel-identical sizes, perfectly
// symmetric, genuinely translucent, never flicker.
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../press_feedback.dart';

class HeroCtaButton extends StatelessWidget {
  const HeroCtaButton._({
    required this.label,
    required this.icon,
    required this.prominent,
    this.active = false,
    this.onTap,
  });

  /// Primary "Guarda" — bright frosted-white glass, dark text.
  const HeroCtaButton.primary({
    Key? key,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) : this._(label: label, icon: icon, prominent: true, onTap: onTap);

  /// Secondary "La mia lista". [active] = already in the list → green state.
  const HeroCtaButton.glass({
    Key? key,
    required String label,
    required IconData icon,
    bool active = false,
    VoidCallback? onTap,
  }) : this._(label: label, icon: icon, prominent: false, active: active, onTap: onTap);

  final String label;
  final IconData icon;
  final bool prominent;
  final bool active;
  final VoidCallback? onTap;

  static const double _height = 48;
  static const double _iconSize = 18;

  /// Success green for the "in list" state — desaturated a touch so it sits
  /// against the warm/mono palette rather than glowing neon.
  static const Color _added = Color(0xFF5BD08C);

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    final Color fg;
    if (active) {
      fg = _added; // green "added" state
    } else {
      fg = Colors.white; // white label on both Guarda and La mia lista
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: _iconSize, color: fg),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: PressFeedback(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: _glassBody(content),
        ),
      ),
    );
  }

  Widget _glassBody(Widget content) {
    final radius = BorderRadius.circular(StreamloadTokens.radiusPill);

    late final List<Color> fill;
    late final Color rim;
    if (prominent) {
      // Same glass family, just a bit LIGHTER than La mia lista so Guarda
      // leads — white label stays legible over the dark lower hero.
      fill = [
        Colors.white.withValues(alpha: 0.30),
        Colors.white.withValues(alpha: 0.13),
      ];
      rim = Colors.white.withValues(alpha: 0.42);
    } else if (active) {
      // Green wash + green rim → unmistakably "in the list".
      fill = [
        _added.withValues(alpha: 0.22),
        _added.withValues(alpha: 0.08),
      ];
      rim = _added.withValues(alpha: 0.80);
    } else {
      // Neutral dark glass (the operator's favourite).
      fill = [
        Colors.white.withValues(alpha: 0.18),
        Colors.white.withValues(alpha: 0.06),
      ];
      rim = Colors.white.withValues(alpha: 0.22);
    }

    return Container(
      height: _height,
      // Rim drawn on top of the clip so it stays crisp (never half-clipped).
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: rim, width: active ? 1.5 : 1.0),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: fill,
              ),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
