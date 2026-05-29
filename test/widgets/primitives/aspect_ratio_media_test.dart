import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/primitives/aspect_ratio_media.dart';

void main() {
  testWidgets('null url renders the initials fallback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            child: AspectRatioMedia(
              aspectRatio: 2 / 3,
              imageUrl: null,
              fallbackLabel: 'Blade Runner',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('BR'), findsOneWidget);
  });

  testWidgets('empty url renders the fallback (not a broken image)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            child: AspectRatioMedia(
              aspectRatio: 2 / 3,
              imageUrl: '',
              fallbackLabel: 'Dune',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('never overflows inside a tight constraint', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 40,
            height: 40,
            child: AspectRatioMedia(
              aspectRatio: 2 / 3,
              imageUrl: null,
              fallbackLabel: 'X',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
