// lib/presentation/widgets/hero/hero_cta_button.dart
//
// HeroCtaButton — the hero's two primary actions, rebuilt from scratch.
//
//   .primary  → solid cream-white pill, near-black label, soft lift shadow.
//               The unmistakable "Watch" affordance (Apple TV+ / Netflix).
//   .glass    → real translucent glass: a BackdropFilter blur of the art
//               behind it + a faint top sheen + a hairline rim, white label.
//
// Built in pure Flutter (no platform views) so the two buttons are pixel-
// identical in size, perfectly symmetric, genuinely translucent, and never
// flicker — the things the native glass button kept getting wrong.
//
// Both variants share one geometry (fixed height, pill radius, icon + label
// centred) so a row of one .primary + one .glass always lines up.
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../press_feedback.dart';

class HeroCtaButton extends StatelessWidget {
  const HeroCtaButton._({
    required this.label,
    required this.icon,
    required this.glass,
    this.active = false,
    this.onTap,
  });

  /// Solid cream-white pill — the primary "Guarda" action.
  const HeroCtaButton.primary({
    Key? key,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) : this._(label: label, icon: icon, glass: false, onTap: onTap);

  /// Translucent liquid-glass pill — the secondary "La mia lista" action.
  /// [active] = the title is already in the list → the icon/label pick up the
  /// signature amber so the "added" state reads at a glance.
  const HeroCtaButton.glass({
    Key? key,
    required String label,
    required IconData icon,
    bool active = false,
    VoidCallback? onTap,
  }) : this._(label: label, icon: icon, glass: true, active: active, onTap: onTap);

  final String label;
  final IconData icon;
  final bool glass;
  final bool active;
  final VoidCallback? onTap;

  static const double _height = 48;
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = glass ? Colors.white : StreamloadTokens.ctaPrimaryFg;
    // In the "added" state the glass icon picks up the signature amber so the
    // toggle reads instantly; the label stays white for legibility.
    final iconColor = (glass && active) ? StreamloadTokens.accent : fg;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: _iconSize, color: iconColor),
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

    final body = glass ? _glassBody(content) : _primaryBody(content);

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: PressFeedback(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: body,
        ),
      ),
    );
  }

  Widget _primaryBody(Widget content) {
    return Container(
      height: _height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: StreamloadTokens.ctaPrimaryBg,
        borderRadius: BorderRadius.circular(StreamloadTokens.radiusPill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _glassBody(Widget content) {
    final radius = BorderRadius.circular(StreamloadTokens.radiusPill);
    return Container(
      height: _height,
      // Rim drawn on top of the clip so it stays crisp (never half-clipped).
      // Picks up a faint amber when the title is in the list.
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: active
              ? StreamloadTokens.accent.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.22),
        ),
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
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.06),
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
