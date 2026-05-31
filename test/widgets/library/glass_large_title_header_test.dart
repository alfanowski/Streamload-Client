import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/library/glass_large_title_header.dart';

Widget _host({String? isolated, VoidCallback? onBack}) {
  return MaterialApp(
    home: Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: GlassLargeTitleHeader(
              title: 'La mia lista',
              topPadding: 0,
              isolatedLabel: isolated,
              onBack: onBack,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 1200)),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('mostra il titolo grande in overview', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();
    expect(find.text('La mia lista'), findsWidgets);
  });

  testWidgets('modalità isolata: chevron back chiama onBack + mostra label',
      (tester) async {
    var back = false;
    await tester.pumpWidget(_host(isolated: 'Anime', onBack: () => back = true));
    await tester.pump();
    expect(find.text('Anime'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    expect(back, isTrue);
  });
}
