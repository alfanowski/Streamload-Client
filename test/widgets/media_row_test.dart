// test/widgets/media_row_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/presentation/widgets/media_row.dart';
import 'package:streamload_client/presentation/widgets/poster_card.dart';

void main() {
  testWidgets('MediaRow renders the section title and N posters', (tester) async {
    final items = List.generate(5, (i) => MediaSummary(
      tmdbId: i, mediaType: 'movie', title: 'T$i',
    ));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: MediaRow(
      title: 'In tendenza',
      items: items,
      onTap: (_) {},
    ))));
    expect(find.text('In tendenza'), findsOneWidget);
    expect(find.byType(PosterCard), findsNWidgets(5));
  });

  testWidgets('MediaRow hides itself when items is empty', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: MediaRow(
      title: 'Vuoto', items: const [], onTap: (_) {},
    ))));
    expect(find.text('Vuoto'), findsNothing);
  });
}
