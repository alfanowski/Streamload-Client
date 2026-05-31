import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/theme/page_transitions.dart';

void main() {
  testWidgets('wraps child in a fade + scale and preserves it', (tester) async {
    final controller = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 300),
    )..value = 0.5;
    addTearDown(controller.dispose);

    // Minimal host (no MaterialApp/route) so the only fade+scale in the
    // tree is the one our function produces.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: streamloadPageTransition(controller, const Text('PAGE')),
      ),
    );
    await tester.pump();

    expect(find.text('PAGE'), findsOneWidget);
    expect(find.byType(FadeTransition), findsOneWidget);
    expect(find.byType(ScaleTransition), findsOneWidget);
  });
}
