import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/primitives/glass_surface.dart';

void main() {
  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassSurface(
              borderRadius: 20,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('GLASS'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('GLASS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('uses the fake (non-shader) path under flutter test', () {
    expect(GlassSurface.useFake(), isTrue);
  });
}
