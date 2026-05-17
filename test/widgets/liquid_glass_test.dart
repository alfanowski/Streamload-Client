// test/widgets/liquid_glass_test.dart
//
// Pass 2B — LiquidGlass renders its child + applies a BackdropFilter for
// the glassmorphism blur. The widget is a pure visual primitive so the
// surface area is tiny; we mostly verify it doesn't drop the child and
// that the requested tint shows up in the decoration.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:streamload_client/presentation/theme/colors.dart';
import 'package:streamload_client/presentation/widgets/liquid_glass.dart';

void main() {
  Future<void> pumpGlass(WidgetTester t, Widget glass) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: glass),
      ),
    ));
  }

  testWidgets('renders its child', (t) async {
    await pumpGlass(
      t,
      const LiquidGlass(child: Text('hello-glass')),
    );
    await t.pump();
    expect(find.text('hello-glass'), findsOneWidget);
  });

  testWidgets('applies BackdropFilter for the blur', (t) async {
    await pumpGlass(
      t,
      const LiquidGlass(child: Text('child')),
    );
    await t.pump();
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('respects the provided borderRadius', (t) async {
    await pumpGlass(
      t,
      LiquidGlass(
        borderRadius: BorderRadius.circular(24),
        child: const Text('child'),
      ),
    );
    await t.pump();
    final clip = t.widget<ClipRRect>(find.byType(ClipRRect).first);
    expect(clip.borderRadius, BorderRadius.circular(24));
  });

  testWidgets('liquidGlassYellow tints with brand yellow', (t) async {
    await pumpGlass(
      t,
      liquidGlassYellow(child: const Text('y')),
    );
    await t.pump();
    // The helper produces a LiquidGlass; check that one exists with the
    // brand tint passed through.
    final glass = t.widget<LiquidGlass>(find.byType(LiquidGlass));
    expect(glass.tint, StreamloadColors.v3AccentYellow);
  });
}
