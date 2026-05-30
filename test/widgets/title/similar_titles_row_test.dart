// test/widgets/title/similar_titles_row_test.dart
//
// SimilarTitlesRow — Phase E4 of sub-plan 8. Verifies:
//   - shows recommendations when present
//   - falls back to similar when recommendations is empty
//   - renders nothing when both are empty
//   - shows the loading placeholder during initial fetch
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/presentation/widgets/poster_card.dart';
import 'package:streamload_client/presentation/widgets/title/similar_titles_row.dart';
import 'package:streamload_client/state/home_rows_provider.dart';

void main() {
  Widget host(Widget child, {List<Override> extra = const []}) {
    return ProviderScope(
      overrides: extra,
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1280, 800)),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: child,
          ),
        ),
      ),
    );
  }

  MediaSummary summary(int id, String title) => MediaSummary(
        tmdbId: id,
        mediaType: 'movie',
        title: title,
      );

  testWidgets('renders Titoli simili header when recommendations present',
      (t) async {
    await t.pumpWidget(host(
      const SimilarTitlesRow(tmdbId: 99, mediaType: 'movie'),
      extra: [
        recommendationsProvider.overrideWith((_, __) async => [
              summary(1, 'A'),
              summary(2, 'B'),
            ]),
      ],
    ));
    await t.pumpAndSettle();
    expect(find.text('Titoli simili'), findsOneWidget);
    // Rows are covers-only — assert the cards render by type.
    expect(find.byType(PosterCard), findsNWidgets(2));
  });

  testWidgets('falls back to similar when recommendations is empty',
      (t) async {
    await t.pumpWidget(host(
      const SimilarTitlesRow(tmdbId: 99, mediaType: 'movie'),
      extra: [
        recommendationsProvider
            .overrideWith((_, __) async => <MediaSummary>[]),
        similarProvider.overrideWith((_, __) async => [
              summary(7, 'X'),
            ]),
      ],
    ));
    await t.pumpAndSettle();
    expect(find.text('Titoli simili'), findsOneWidget);
    expect(find.byType(PosterCard), findsOneWidget);
  });

  testWidgets('renders nothing when both providers are empty', (t) async {
    await t.pumpWidget(host(
      const SimilarTitlesRow(tmdbId: 99, mediaType: 'movie'),
      extra: [
        recommendationsProvider
            .overrideWith((_, __) async => <MediaSummary>[]),
        similarProvider.overrideWith((_, __) async => <MediaSummary>[]),
      ],
    ));
    await t.pumpAndSettle();
    expect(find.text('Titoli simili'), findsNothing);
  });

  testWidgets('shows loading placeholder during initial fetch', (t) async {
    final pending = Completer<List<MediaSummary>>();
    await t.pumpWidget(host(
      const SimilarTitlesRow(tmdbId: 99, mediaType: 'movie'),
      extra: [
        recommendationsProvider.overrideWith((_, __) async => pending.future),
      ],
    ));
    await t.pump();
    expect(find.text('Titoli simili'), findsOneWidget);
    pending.complete(const <MediaSummary>[]);
    await t.pumpAndSettle();
  });
}
