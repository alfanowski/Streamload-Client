// lib/presentation/theme/tokens.dart
//
// Single source of truth for the 2026 UI refactor ("Cinematic Premium").
// Consolidates the old v2/v3 token split. New primitives and migrated
// screens read ONLY from here. Legacy StreamloadColors/Typography/Spacing/
// Motion stay until each screen is migrated.
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class StreamloadTokens {
  StreamloadTokens._();

  // ── Color ────────────────────────────────────────────────────────────────
  static const Color bg = Color(0xFF0F0E0D); // warm near-black
  static const Color bgScrolled = Color(0xFF0A0A09);
  static const Color surface = Color(0xFF161412);
  static const Color surfaceHi = Color(0xFF211D1A);

  static const Color textPrimary = Color(0xFFF5F2EC); // warm cream
  static final Color textSecondary =
      const Color(0xFFF5F2EC).withValues(alpha: 0.65);
  static final Color textMuted =
      const Color(0xFFF5F2EC).withValues(alpha: 0.42);

  static final Color border = const Color(0xFFF5F2EC).withValues(alpha: 0.08);
  static final Color borderStrong =
      const Color(0xFFF5F2EC).withValues(alpha: 0.14);

  static const Color accent = Color(0xFFD4A574); // discreet signature amber
  static const Color accentHover = Color(0xFFE8C9A0);

  static const Color ctaPrimaryBg = Color(0xFFF5F2EC); // cream-white Play
  static const Color ctaPrimaryFg = Color(0xFF0F0E0D);

  static const Color critical = Color(0xFFF26B5E);

  // ── Radii ────────────────────────────────────────────────────────────────
  static const double radiusCard = 8;
  static const double radiusLarge = 12;
  static const double radiusPill = 999;

  // ── Spacing (4pt scale) ────────────────────────────────────────────────────
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space12 = 48;
  static const double space16 = 64;

  // ── Breakpoints (canonical for new primitives) ─────────────────────────────
  static const double bpPhone = 600;
  static const double bpDesktop = 1024;

  // ── Motion ─────────────────────────────────────────────────────────────────
  static const Duration tap = Duration(milliseconds: 110);
  static const Duration hover = Duration(milliseconds: 200);
  static const Duration page = Duration(milliseconds: 280);
  static const Duration heroCrossfade = Duration(milliseconds: 600);
  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve springCurve = Curves.easeOutBack; // tactile overshoot
  static final SpringDescription spring =
      SpringDescription(mass: 1, stiffness: 320, damping: 24);
}
