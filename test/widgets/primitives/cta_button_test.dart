import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/primitives/cta_button.dart';

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders label and leading glyph', (tester) async {
    await tester.pumpWidget(_host(
      const CtaButton(label: 'Guarda', leading: '▶'),
    ));
    await tester.pump();
    expect(find.text('Guarda'), findsOneWidget);
    expect(find.text('▶'), findsOneWidget);
  });

  testWidgets('filled variant uses the cream fill', (tester) async {
    await tester.pumpWidget(_host(
      const CtaButton(label: 'Guarda', onTap: _noop, filled: true),
    ));
    await tester.pump();
    expect(find.byKey(const ValueKey('cta-fill')), findsOneWidget);
    expect(find.byKey(const ValueKey('cta-ghost')), findsNothing);
  });

  testWidgets('ghost variant has no fill', (tester) async {
    await tester.pumpWidget(_host(
      const CtaButton(label: 'La mia lista', onTap: _noop, filled: false),
    ));
    await tester.pump();
    expect(find.byKey(const ValueKey('cta-ghost')), findsOneWidget);
    expect(find.byKey(const ValueKey('cta-fill')), findsNothing);
  });

  testWidgets('invokes onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(
      CtaButton(label: 'Guarda', onTap: () => taps++),
    ));
    await tester.pump();
    await tester.tap(find.byType(CtaButton));
    expect(taps, 1);
  });

  testWidgets('disabled (onTap null) is dimmed and inert', (tester) async {
    await tester.pumpWidget(_host(const CtaButton(label: 'Guarda')));
    await tester.pump();
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(CtaButton),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, lessThan(1.0));
  });
}

void _noop() {}
