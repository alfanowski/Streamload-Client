// Cinematic Editorial typography, ported from v2 SvelteKit.
// Display: Fraunces (variable serif). Body: Geist. Mono: Geist Mono.
// All loaded on-demand via google_fonts (no asset bundling needed).
//
// 2026-05-16: extended with Netflix×AppleTV refactor styles (v3*) — Inter
// for everything readable, JetBrains Mono for metadata labels. Same
// google_fonts delivery pattern (no asset bundling).
//
// 2026-05-17 (Cinema Magazine pivot, CM-1): the v3 hero / page title /
// section-header styles get a sober editorial overhaul. We KEEP the
// `v3*` names so existing call sites just inherit the new look:
//
//   - v3DisplayHero  → Fraunces italic serif, big editorial weight
//   - v3DisplayPage  → Fraunces italic, one tier down
//   - v3SectionHeader→ Fraunces (non-italic 18px) — row headers like
//                       "Tendenze settimana"; replaces the old Inter
//                       14px / 600-weight title which read as "app chrome"
//                       rather than "editorial heading"
//   - v3Body         → Inter (kept — best reading face for body)
//   - v3MetaMono     → JetBrains Mono (kept — "metadata as data" look)
//   - v3LabelMono    → JetBrains Mono uppercase (kept)
//   - v3CtaLabel     → Inter w500 (toned down from w600 — typographic CTAs
//                       in CM-4 want the weight to read as text, not button)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class StreamloadTypography {
  StreamloadTypography._();

  // ──────────────────────────────────────────────────────────────────────────
  // v2 cinematic editorial styles (kept for backward-compat)
  // ──────────────────────────────────────────────────────────────────────────

  /// Editorial display titles. Use sparingly: hero, page titles, section headers.
  static TextStyle display({
    double fontSize = 48,
    FontWeight weight = FontWeight.w400,
    bool italic = true,
    Color color = StreamloadColors.textPrimary,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: weight,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: -0.025 * fontSize,
      height: 1.0,
      color: color,
    );
  }

  /// Body text — Geist.
  static TextStyle body({
    double fontSize = 14,
    FontWeight weight = FontWeight.w400,
    Color color = StreamloadColors.textPrimary,
    double height = 1.5,
  }) {
    return GoogleFonts.geist(
      fontSize: fontSize,
      fontWeight: weight,
      letterSpacing: -0.005 * fontSize,
      height: height,
      color: color,
    );
  }

  /// Monospace — used for technical labels (eyebrow text, version strings, IDs).
  static TextStyle mono({
    double fontSize = 11,
    FontWeight weight = FontWeight.w400,
    Color color = StreamloadColors.textTertiary,
    double letterSpacing = 0.18,
  }) {
    return GoogleFonts.geistMono(
      fontSize: fontSize,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// Bundle a complete TextTheme.
  static TextTheme textTheme() {
    return TextTheme(
      displayLarge: display(fontSize: 64),
      displayMedium: display(fontSize: 48),
      displaySmall: display(fontSize: 36),
      headlineLarge: display(fontSize: 32),
      headlineMedium: display(fontSize: 24),
      headlineSmall: display(fontSize: 20),
      titleLarge: body(fontSize: 18, weight: FontWeight.w500),
      titleMedium: body(fontSize: 16, weight: FontWeight.w500),
      titleSmall: body(fontSize: 14, weight: FontWeight.w500),
      bodyLarge: body(fontSize: 16),
      bodyMedium: body(fontSize: 14),
      bodySmall: body(fontSize: 12, color: StreamloadColors.textSecondary),
      labelLarge: body(fontSize: 14, weight: FontWeight.w500),
      labelMedium: mono(fontSize: 12),
      labelSmall: mono(fontSize: 10),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // v3 Netflix×AppleTV refactor styles (Phase A1, sub-plan 8)
  //
  // Inter for everything readable; JetBrains Mono for "metadata as data"
  // labels ("IN EVIDENZA · 2 DI 5", "2025 · 8 ep · IT · ⭐ 7.8"). This is
  // what gives us the indie-editorial feel that distinguishes us from a
  // pure Netflix clone.
  // ──────────────────────────────────────────────────────────────────────────

  /// Hero title — Fraunces serif italic. Big, editorial, "in primo piano"
  /// magazine feel. CM-5 sets the size per breakpoint (56 / 44 / 36); the
  /// default here is the desktop size so call sites without an override
  /// still look right.
  static TextStyle v3DisplayHero({Color? color}) => GoogleFonts.fraunces(
        fontSize: 56,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.025 * 56,
        height: 1.0,
        color: color ?? StreamloadColors.v3TextPrimary,
      );

  /// Page title — one level down from hero. Fraunces italic.
  static TextStyle v3DisplayPage({Color? color}) => GoogleFonts.fraunces(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.025 * 36,
        height: 1.05,
        color: color ?? StreamloadColors.v3TextPrimary,
      );

  /// Row header ("Tendenze oggi", "Continua a guardare"). Fraunces
  /// non-italic 18px — gives the row separator a quiet editorial weight
  /// that says "section" without shouting like a Netflix tab bar would.
  static TextStyle v3SectionHeader({Color? color}) => GoogleFonts.fraunces(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        letterSpacing: -0.01 * 18,
        color: color ?? StreamloadColors.v3TextPrimary,
      );

  /// Standard body / synopsis.
  static TextStyle v3Body({double fontSize = 14, Color? color}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? StreamloadColors.v3TextPrimary,
      );

  /// Metadata mono ("2025 · 8 ep · IT · ⭐ 7.8") — read like a data row.
  static TextStyle v3MetaMono({Color? color}) => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color ?? StreamloadColors.v3TextSecondary,
      );

  /// Label mono ("IN EVIDENZA", "EPISODI") — uppercase, wide tracking, small.
  static TextStyle v3LabelMono({Color? color}) => GoogleFonts.jetBrainsMono(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.0,
        color: color ?? StreamloadColors.v3TextMuted,
      );

  /// CTA label (Guarda / La mia lista / etc). w500 reads as text on the
  /// typographic CTAs added in CM-4; the pill version (PrimaryPill in
  /// onboarding) still looks fine at this weight too.
  static TextStyle v3CtaLabel({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? StreamloadColors.v3CtaPrimaryFg,
      );
}
