// lib/presentation/theme/theme.dart
//
// Cinematic Editorial ThemeData. Single entry point: streamloadTheme().

import 'package:flutter/material.dart';

import 'colors.dart';
import 'tokens.dart';
import 'typography.dart';

ThemeData streamloadTheme() {
  // Colors are sourced from StreamloadTokens — the single design-system
  // source of truth (spec §3). textTheme + filledButtonTheme stay on the
  // legacy helpers for now so onboarding/form buttons don't regress; they
  // migrate when those screens do.
  final colorScheme = ColorScheme.dark(
    surface: StreamloadTokens.surface,
    onSurface: StreamloadTokens.textPrimary,
    primary: StreamloadTokens.accent,
    onPrimary: StreamloadTokens.ctaPrimaryFg,
    secondary: StreamloadTokens.accentHover,
    onSecondary: StreamloadTokens.ctaPrimaryFg,
    error: StreamloadTokens.critical,
    onError: Colors.white,
    surfaceContainerHighest: StreamloadTokens.surfaceHi,
    outline: StreamloadTokens.borderStrong,
    outlineVariant: StreamloadTokens.border,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: StreamloadTokens.bg,
    canvasColor: StreamloadTokens.bg,
    colorScheme: colorScheme,
    textTheme: StreamloadTypography.textTheme(),
    splashFactory: NoSplash.splashFactory,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: StreamloadTokens.surface,
      hoverColor: StreamloadTokens.surfaceHi,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: StreamloadTokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: StreamloadTokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: StreamloadTokens.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: StreamloadTokens.critical),
      ),
      labelStyle: StreamloadTypography.mono(
        fontSize: 11,
        color: StreamloadColors.textTertiary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(StreamloadColors.accent),
        foregroundColor: const WidgetStatePropertyAll(Color(0xFF1A1308)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        textStyle: WidgetStatePropertyAll(
          StreamloadTypography.body(
            fontSize: 14,
            weight: FontWeight.w600,
            color: const Color(0xFF1A1308),
          ),
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: StreamloadTokens.surface,
      contentTextStyle: TextStyle(color: StreamloadTokens.textPrimary),
    ),
  );
}
