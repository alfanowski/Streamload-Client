// lib/presentation/widgets/hero/hero_cta_button.dart
//
// HeroCtaButton — the hero's two actions, both rendered as real translucent
// liquid glass (BackdropFilter blur of the art behind + a faint top sheen +
// a hairline rim, white label):
//
//   .primary  → "Guarda": the same glass, a touch BRIGHTER, so it reads as
//               the primary action without going back to a flat opaque pill.
//   .glass    → "La mia lista": the neutral glass. [active] swaps ＋→✓ and
//               "Nella lista" with a slightly fuller frost (no tint colour).
//
// Built in pure Flutter (no platform views) so the two buttons are pixel-
// identical in size, perfectly symmetric, genuinely translucent, and never
// flicker — the things the native glass button kept getting wrong.
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

  /// Primary "Guarda" — a slightly brighter frost so it leads the eye.
  const HeroCtaButton.primary({
    Key? key,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) : this._(label: label, icon: icon, prominent: true, onTap: onTap);

  /// Secondary "La mia lista". [active] = the title is already in the list,
  /// so it shows ✓ "Nella lista" with a slightly fuller frost.
  const HeroCtaButton.glass({
    Key? key,
    required String label,
    required IconData icon,
    bool active = false,
    VoidCallback? onTap,
  }) : this._(label: label, icon: icon, prominent: false, active: active, onTap: onTap);

  final String label;
  final IconData icon;

  /// The primary action ("Guarda") — a touch brighter than the neutral glass.
  final bool prominent;

  /// In-list state ("Nella lista", ✓).
  final bool active;

  final VoidCallback? onTap;

  static const double _height = 48;
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: _iconSize, color: Colors.white),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
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

    // One glass family, three weights. Secondary is the baseline the operator
    // already loves; primary is a hair brighter to lead; active is a touch
    // fuller so "added" reads — all white, no tint colour.
    final double fillTop, fillBottom, rimAlpha;
    if (prominent) {
      fillTop = 0.26;
      fillBottom = 0.11;
      rimAlpha = 0.36;
    } else if (active) {
      fillTop = 0.22;
      fillBottom = 0.10;
      rimAlpha = 0.32;
    } else {
      fillTop = 0.18;
      fillBottom = 0.06;
      rimAlpha = 0.22;
    }

    return Container(
      height: _height,
      // Rim drawn on top of the clip so it stays crisp (never half-clipped).
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: Colors.white.withValues(alpha: rimAlpha)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              // Faint top-down sheen over a low-opacity wash → reads as glass,
              // not a flat scrim. Stays translucent so the art shows through.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: fillTop),
                  Colors.white.withValues(alpha: fillBottom),
                ],
              ),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
