// test/widgets/splash/splash_gate_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/splash/splash_gate.dart';

void main() {
  testWidgets('shows the splash overlay then removes it, revealing the child',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: SplashGate(
        child: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => tapped = true,
              child: const Text('APP READY'),
            ),
          ),
        ),
      ),
    ));

    // First frame: overlay is up (black ColoredBox painted over the child).
    await tester.pump();
    expect(find.byType(SplashGate), findsOneWidget);

    // Let the font load + the ~2.6s animation run to completion. pumpAndSettle
    // drives the AnimationController to the end, which removes the overlay.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // The child is now visible AND interactive (overlay no longer intercepts).
    expect(find.text('APP READY'), findsOneWidget);
    await tester.tap(find.text('APP READY'));
    expect(tapped, isTrue);
  });
}
