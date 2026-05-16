// test/widgets/primary_pill_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/primary_pill.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('idle state shows label and is tappable', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(host(PrimaryPill(
      label: 'Verifica',
      onPressed: () => tapped++,
    )));
    expect(find.text('Verifica'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.byType(PrimaryPill));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('busy state hides label and shows spinner', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(host(PrimaryPill(
      label: 'Verifica',
      busy: true,
      onPressed: () => tapped++,
    )));
    // Label is suppressed during busy.
    expect(find.text('Verifica'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Tapping a busy pill is a no-op.
    await tester.tap(find.byType(PrimaryPill));
    await tester.pump();
    expect(tapped, 0);
  });

  testWidgets('null onPressed renders as disabled (no tap)', (tester) async {
    await tester.pumpWidget(host(const PrimaryPill(label: 'Salva')));
    expect(find.text('Salva'), findsOneWidget);
    // Tap should not throw even though onPressed is null.
    await tester.tap(find.byType(PrimaryPill));
    await tester.pump();
  });

  testWidgets('leadingIcon renders before the label', (tester) async {
    await tester.pumpWidget(host(PrimaryPill(
      label: 'Accedi',
      leadingIcon: Icons.lock_outline,
      onPressed: () {},
    )));
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('Accedi'), findsOneWidget);
  });
}
