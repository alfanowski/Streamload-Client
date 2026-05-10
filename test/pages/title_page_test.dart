// test/pages/title_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_api.dart';
import 'package:streamload_client/data/remote/endpoints/episodes_api.dart';
import 'package:streamload_client/domain/models/catalog_item.dart';
import 'package:streamload_client/presentation/pages/title_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/database_provider.dart';
import 'package:drift/native.dart';
import 'package:streamload_client/data/local/database.dart';

class _CatalogApiMock extends Mock implements CatalogApi {}

class _EpisodesApiMock extends Mock implements EpisodesApi {}

void main() {
  Widget wrap({
    required Widget child,
    required CatalogApi catalogApi,
    EpisodesApi? episodesApi,
    required StreamloadDatabase db,
  }) {
    return ProviderScope(
      overrides: [
        catalogApiProvider.overrideWith((_) async => catalogApi),
        if (episodesApi != null)
          episodesApiProvider.overrideWith((_) async => episodesApi),
        databaseProvider.overrideWith((_) => db),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('TitlePage — movie variant', () {
    testWidgets('shows title, year and overview', (tester) async {
      final catalogApi = _CatalogApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(1, mediaType: 'movie'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 1,
                mediaType: 'movie',
                title: 'Dune',
                year: 2021,
                overview: 'A hero rises.',
              ));

      await tester.pumpWidget(wrap(
        catalogApi: catalogApi,
        db: db,
        child: const TitlePage(tmdbId: 1, mediaType: 'movie'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Dune'), findsOneWidget);
      expect(find.text('2021'), findsOneWidget);
      expect(find.text('A hero rises.'), findsOneWidget);
      expect(find.text('Guarda'), findsOneWidget);
    });

    testWidgets('shows title without year when year is null', (tester) async {
      final catalogApi = _CatalogApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(2, mediaType: 'movie'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 2,
                mediaType: 'movie',
                title: 'Untitled',
              ));

      await tester.pumpWidget(wrap(
        catalogApi: catalogApi,
        db: db,
        child: const TitlePage(tmdbId: 2, mediaType: 'movie'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Untitled'), findsOneWidget);
    });
  });

  group('TitlePage — TV variant', () {
    testWidgets('shows season picker and episode list', (tester) async {
      final catalogApi = _CatalogApiMock();
      final episodesApi = _EpisodesApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(99, mediaType: 'tv'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 99,
                mediaType: 'tv',
                title: 'Breaking Bad',
                year: 2008,
                seasonsCount: 5,
              ));

      when(() => episodesApi.list(99)).thenAnswer((_) async => {
            'seasons': [
              {
                'number': 1,
                'name': 'Stagione 1',
                'episodes': [
                  {
                    'season': 1,
                    'episode': 1,
                    'title': 'Pilot',
                    'overview': null,
                    'still_url': null,
                    'runtime_minutes': 58,
                    'air_date': '2008-01-20',
                  },
                  {
                    'season': 1,
                    'episode': 2,
                    'title': "Cat's in the Bag",
                    'overview': null,
                    'still_url': null,
                    'runtime_minutes': 48,
                    'air_date': '2008-01-27',
                  },
                ],
              },
            ],
          });

      await tester.pumpWidget(wrap(
        catalogApi: catalogApi,
        episodesApi: episodesApi,
        db: db,
        child: const TitlePage(tmdbId: 99, mediaType: 'tv'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Breaking Bad'), findsOneWidget);
      // Season chip
      expect(find.text('Stagione 1'), findsOneWidget);
      // Episode list items
      expect(find.text('1. Pilot'), findsOneWidget);
      expect(find.textContaining("Cat's in the Bag"), findsOneWidget);
    });
  });
}
