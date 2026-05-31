import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/library/glass_large_title_header.dart';

Widget _host() {
  return MaterialApp(
    home: Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: GlassLargeTitleHeader(
              title: 'La mia lista',
              topPadding: 0,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 1200)),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('mostra il titolo (large + small renderizzati nello stack)',
      (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();
    // Sia il large title che il piccolo titolo nella barra portano il testo.
    expect(find.text('La mia lista'), findsWidgets);
  });
}
