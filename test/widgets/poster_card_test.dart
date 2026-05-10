// test/widgets/poster_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/presentation/widgets/poster_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders title and year', (tester) async {
    await tester.pumpWidget(wrap(PosterCard(
      summary: const MediaSummary(
        tmdbId: 1, mediaType: 'movie', title: 'Dune', year: 2021,
      ),
      onTap: () {},
    )));
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('2021'), findsOneWidget);
  });

  testWidgets('omits year when null', (tester) async {
    await tester.pumpWidget(wrap(PosterCard(
      summary: const MediaSummary(tmdbId: 1, mediaType: 'movie', title: 'Untitled'),
      onTap: () {},
    )));
    expect(find.text('Untitled'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^\d{4}$')), findsNothing);
  });

  testWidgets('tap fires the callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(PosterCard(
      summary: const MediaSummary(tmdbId: 1, mediaType: 'movie', title: 'X'),
      onTap: () => taps++,
    )));
    await tester.tap(find.byType(PosterCard));
    expect(taps, 1);
  });
}
