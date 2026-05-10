// test/theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamload_client/presentation/theme/theme.dart';
import 'package:streamload_client/presentation/theme/colors.dart';

void main() {
  setUpAll(() {
    // Prevent google_fonts from hitting the network during tests.
    // Fonts fall back to the system default; the TextStyle values are still set.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('streamloadTheme()', () {
    testWidgets('uses dark Cinematic Editorial colors', (tester) async {
      final theme = streamloadTheme();
      // Pump a minimal widget so that the flutter binding handles the async
      // font-load callbacks that google_fonts fires.
      await tester.pumpWidget(MaterialApp(theme: theme, home: const SizedBox()));
      await tester.pump();

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, StreamloadColors.bg);
      expect(theme.colorScheme.surface, StreamloadColors.surface1);
      expect(theme.colorScheme.primary, StreamloadColors.accent);
      expect(theme.colorScheme.error, StreamloadColors.critical);
    });

    testWidgets('text theme is non-empty and primary text is warm off-white',
        (tester) async {
      final theme = streamloadTheme();
      await tester.pumpWidget(MaterialApp(theme: theme, home: const SizedBox()));
      await tester.pump();

      expect(theme.textTheme.bodyMedium, isNotNull);
      expect(theme.textTheme.bodyMedium!.color, StreamloadColors.textPrimary);
    });
  });
}
