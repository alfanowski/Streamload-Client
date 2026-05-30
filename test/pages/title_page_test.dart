// test/pages/title_page_test.dart
//
// v3 TitlePage (Phase E1+) — verifies the high-level page wiring:
//   - titleProvider data renders the hero title + meta
//   - the page renders without throwing for both movie + tv items
//
// Detailed CTA / sidebar / episode list assertions live in dedicated
// widget tests (title_hero_test, title_sidebar_test, etc.). This file
// stays focused on the page-level glue.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_api.dart';
import 'package:streamload_client/data/remote/endpoints/episodes_api.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/domain/models/catalog_credits.dart';
import 'package:streamload_client/domain/models/catalog_item.dart';
import 'package:streamload_client/domain/models/continue_watching_item.dart';
import 'package:streamload_client/presentation/pages/title_page.dart';
import 'package:streamload_client/presentation/widgets/cast/cast_card.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/availability_provider.dart';
import 'package:streamload_client/state/continue_watching_provider.dart';
import 'package:streamload_client/state/database_provider.dart';
import 'package:streamload_client/state/home_rows_provider.dart';
import 'package:streamload_client/state/plugin_access_provider.dart';

class _CatalogApiMock extends Mock implements CatalogApi {}

class _EpisodesApiMock extends Mock implements EpisodesApi {}

class _FavApiMock extends Mock implements FavoritesApi {}

Widget wrap({
  required Widget child,
  required CatalogApi catalogApi,
  EpisodesApi? episodesApi,
  required StreamloadDatabase db,
  PluginAccess access = PluginAccess.available,
  Size size = const Size(1280, 800),
  CatalogCredits credits = const CatalogCredits(),
}) {
  final fav = _FavApiMock();
  when(fav.list).thenAnswer((_) async => <Map<String, dynamic>>[]);
  return ProviderScope(
    overrides: [
      catalogApiProvider.overrideWith((_) async => catalogApi),
      if (episodesApi != null)
        episodesApiProvider.overrideWith((_) async => episodesApi),
      databaseProvider.overrideWith((_) => db),
      pluginAccessProvider.overrideWithValue(access),
      favoritesApiProvider.overrideWith((_) async => fav),
      continueWatchingProvider
          .overrideWith((_) async => <ContinueWatchingItem>[]),
      // Phase F3: TitleHero's Guarda CTA now subscribes to
      // availabilityProvider, which by default reaches into the real
      // playControllerProvider (plugin runtime, catalog API). Stub it
      // to a settled true here so the page-level tests still render
      // the play CTA without spinning up plugins.
      availabilityProvider.overrideWith((_, __) async => true),
      // Pass 3 CAST-4: the cast row + sidebar both read creditsProvider.
      // Default to an empty payload so existing tests don't have to care;
      // the cast-row tests override per-call with synthetic cast data.
      creditsProvider.overrideWith((_, __) async => credits),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
    ),
  );
}

void main() {
  group('TitlePage — movie', () {
    testWidgets('renders title, Riproduci CTA, Trama, close button',
        (tester) async {
      final catalogApi = _CatalogApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(1, mediaType: 'movie'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 1,
                mediaType: 'movie',
                title: 'Dune',
                year: 2021,
                runtimeMinutes: 155,
                overview: 'A hero rises.',
              ));

      await tester.pumpWidget(wrap(
        catalogApi: catalogApi,
        db: db,
        child: const TitlePage(tmdbId: 1, mediaType: 'movie'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Dune'), findsOneWidget);
      expect(find.text('A hero rises.'), findsOneWidget);
      expect(find.text('Trama'), findsOneWidget);
      // Glass primary CTA + the modal close button.
      expect(find.text('Riproduci'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('phone renders the title', (tester) async {
      final catalogApi = _CatalogApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(2, mediaType: 'movie'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 2, mediaType: 'movie', title: 'Phone Film',
              ));

      await tester.pumpWidget(wrap(
        catalogApi: catalogApi,
        db: db,
        size: const Size(390, 844),
        child: const TitlePage(tmdbId: 2, mediaType: 'movie'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Phone Film'), findsOneWidget);
    });
  });

  group('TitlePage — TV', () {
    testWidgets('renders title + Riproduci', (tester) async {
      final catalogApi = _CatalogApiMock();
      final episodesApi = _EpisodesApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(99, mediaType: 'tv'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 99, mediaType: 'tv', title: 'Breaking Bad',
                year: 2008, seasonsCount: 5,
              ));
      when(() => episodesApi.list(99))
          .thenAnswer((_) async => <String, dynamic>{'seasons': []});

      await tester.pumpWidget(wrap(
        catalogApi: catalogApi,
        episodesApi: episodesApi,
        db: db,
        child: const TitlePage(tmdbId: 99, mediaType: 'tv'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Breaking Bad'), findsOneWidget);
      expect(find.text('Riproduci'), findsOneWidget);
    });

    testWidgets('cast row renders photos + Info genres', (tester) async {
      final catalogApi = _CatalogApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(123, mediaType: 'movie'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 123,
                mediaType: 'movie',
                title: 'Once Upon a Time in Hollywood',
                overview: 'A western fairytale.',
                genres: ['Drama'],
              ));

      await tester.pumpWidget(wrap(
        catalogApi: catalogApi,
        db: db,
        credits: const CatalogCredits(
          cast: [
            CatalogCreditPerson(id: 287, name: 'Brad Pitt', character: 'Cliff Booth'),
            CatalogCreditPerson(id: 6193, name: 'Leonardo DiCaprio', character: 'Rick Dalton'),
          ],
        ),
        child: const TitlePage(tmdbId: 123, mediaType: 'movie'),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Cast'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Cast'), findsOneWidget);
      expect(find.byType(CastCard), findsNWidgets(2));
      expect(find.text('Brad Pitt'), findsOneWidget);
      expect(find.text('Cliff Booth'), findsOneWidget);

      // Info block: genres as chips.
      await tester.scrollUntilVisible(
        find.text('Drama'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Drama'), findsOneWidget);
    });

    testWidgets('TV episodes section renders', (tester) async {
      final catalogApi = _CatalogApiMock();
      final episodesApi = _EpisodesApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(99, mediaType: 'tv'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 99, mediaType: 'tv', title: 'Breaking Bad',
              ));
      when(() => episodesApi.list(99)).thenAnswer((_) async => {
            'seasons': [
              {
                'season_number': 1,
                'episodes': [
                  {'episode_number': 1, 'title': 'Pilot', 'still_url': null, 'runtime_minutes': 58},
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

      await tester.scrollUntilVisible(
        find.text('EPISODI · S1'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('EPISODI · S1'), findsOneWidget);
      expect(find.text('Pilot'), findsOneWidget);
    });
  });
}
