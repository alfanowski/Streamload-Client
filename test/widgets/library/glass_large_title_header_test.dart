import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/library/glass_large_title_header.dart';

void main() {
  testWidgets('renderizza il titolo (scorre con la lista, non fissato)',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: LibraryTitleHeader(title: 'La mia lista', topPadding: 0),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 1200)),
          ],
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('La mia lista'), findsOneWidget);
  });
}
