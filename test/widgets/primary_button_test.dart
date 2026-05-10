// test/widgets/primary_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/theme/theme.dart';
import 'package:streamload_client/presentation/widgets/primary_button.dart';

void main() {
  testWidgets('fires onPressed when enabled', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(MaterialApp(
      theme: streamloadTheme(),
      home: Scaffold(
        body: PrimaryButton(
          label: 'Accedi',
          onPressed: () => pressed++,
        ),
      ),
    ));
    await tester.tap(find.text('Accedi'));
    expect(pressed, 1);
  });

  testWidgets('shows progress and disables tap when busy', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(MaterialApp(
      theme: streamloadTheme(),
      home: Scaffold(
        body: PrimaryButton(
          label: 'Accedi',
          busy: true,
          onPressed: () => pressed++,
        ),
      ),
    ));
    await tester.tap(find.byType(PrimaryButton));
    expect(pressed, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
