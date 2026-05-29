import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/primitives/skeleton_box.dart';

void main() {
  testWidgets('renders at the requested size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: SkeletonBox(width: 120, height: 40))),
      ),
    );
    await tester.pump(); // start the repeating animation; do NOT pumpAndSettle

    expect(find.byType(SkeletonBox), findsOneWidget);
    final size = tester.getSize(find.byType(SkeletonBox));
    expect(size.width, 120);
    expect(size.height, 40);
  });

  testWidgets('disposes its controller without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SkeletonBox(width: 10, height: 10))),
    );
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    expect(tester.takeException(), isNull);
  });
}
