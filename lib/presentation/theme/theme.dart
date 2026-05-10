// lib/presentation/theme/theme.dart
//
// Cinematic Editorial ThemeData. Single entry point: streamloadTheme().

import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

ThemeData streamloadTheme() {
  const colorScheme = ColorScheme.dark(
    surface: StreamloadColors.surface1,
    onSurface: StreamloadColors.textPrimary,
    primary: StreamloadColors.accent,
    onPrimary: Color(0xFF1A1308),
    secondary: StreamloadColors.gold,
    onSecondary: Color(0xFF1A1308),
    error: StreamloadColors.critical,
    onError: Colors.white,
    surfaceContainerHighest: StreamloadColors.surface3,
    outline: StreamloadColors.borderStrong,
    outlineVariant: StreamloadColors.border,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: StreamloadColors.bg,
    canvasColor: StreamloadColors.bg,
    colorScheme: colorScheme,
    textTheme: StreamloadTypography.textTheme(),
    splashFactory: NoSplash.splashFactory,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: StreamloadColors.surface2,
      hoverColor: StreamloadColors.surface3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: StreamloadColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: StreamloadColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: StreamloadColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: StreamloadColors.critical),
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
      backgroundColor: StreamloadColors.surface2,
      contentTextStyle: TextStyle(color: StreamloadColors.textPrimary),
    ),
  );
}
