// Cinematic Editorial typography, ported from v2 SvelteKit.
// Display: Fraunces (variable serif). Body: Geist. Mono: Geist Mono.
// All loaded on-demand via google_fonts (no asset bundling needed).
//
// 2026-05-16: extended with Netflix×AppleTV refactor styles (v3*) — Inter
// for everything readable, JetBrains Mono for metadata labels. Same
// google_fonts delivery pattern (no asset bundling).

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

  /// Hero title — 36px / extra-bold / tight tracking. Use for the rotating
  /// home hero and the title page header.
  static TextStyle v3DisplayHero({Color? color}) => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.0,
        color: color ?? StreamloadColors.v3TextPrimary,
      );

  /// Page title (one level down from hero).
  static TextStyle v3DisplayPage({Color? color}) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.05,
        color: color ?? StreamloadColors.v3TextPrimary,
      );

  /// Row header ("Tendenze oggi", "Continua a guardare").
  static TextStyle v3SectionHeader({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
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

  /// Pill button label (Guarda / La mia lista / etc).
  static TextStyle v3CtaLabel({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color ?? StreamloadColors.v3CtaPrimaryFg,
      );
}
