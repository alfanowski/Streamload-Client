// Cinematic Editorial typography, ported from v2 SvelteKit.
// Display: Fraunces (variable serif). Body: Geist. Mono: Geist Mono.
// All loaded on-demand via google_fonts (no asset bundling needed).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class StreamloadTypography {
  StreamloadTypography._();

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
}
