import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/primitives/responsive_grid.dart';

void main() {
  group('ResponsiveGrid.columnsForWidth', () {
    test('phone width uses phoneColumns', () {
      expect(
        ResponsiveGrid.columnsForWidth(360,
            phoneColumns: 3, tabletColumns: 4, desktopColumns: 6),
        3,
      );
    });
    test('tablet width uses tabletColumns', () {
      expect(
        ResponsiveGrid.columnsForWidth(800,
            phoneColumns: 3, tabletColumns: 4, desktopColumns: 6),
        4,
      );
    });
    test('desktop width uses desktopColumns', () {
      expect(
        ResponsiveGrid.columnsForWidth(1280,
            phoneColumns: 3, tabletColumns: 4, desktopColumns: 6),
        6,
      );
    });
  });

  testWidgets('builds every item without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1280,
            height: 800,
            child: ResponsiveGrid(
              itemCount: 12,
              itemAspectRatio: 2 / 3,
              itemBuilder: (context, i) => Text('item$i'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('item0'), findsOneWidget);
    expect(find.text('item11'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
