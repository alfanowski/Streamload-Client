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
import 'package:streamload_client/domain/models/catalog_item.dart';
import 'package:streamload_client/domain/models/continue_watching_item.dart';
import 'package:streamload_client/presentation/pages/title_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/availability_provider.dart';
import 'package:streamload_client/state/continue_watching_provider.dart';
import 'package:streamload_client/state/database_provider.dart';
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
  group('TitlePage — movie variant', () {
    testWidgets('renders title + Guarda CTA', (tester) async {
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
      // P4 (2026-05-17): the synopsis only renders in the "TRAMA" body
      // block now, not in the hero — so exactly one match.
      expect(find.text('A hero rises.'), findsOneWidget);
      expect(find.text('TRAMA'), findsOneWidget);
      expect(find.text('▶ Guarda'), findsOneWidget);
    });

    testWidgets('phone layout still renders title', (tester) async {
      final catalogApi = _CatalogApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(2, mediaType: 'movie'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 2,
                mediaType: 'movie',
                title: 'Phone Film',
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

  group('TitlePage — TV variant + responsive layouts', () {
    testWidgets('renders title + Guarda S1 E1 CTA', (tester) async {
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
      expect(find.text('▶ Guarda S1 E1'), findsOneWidget);
    });

    testWidgets('desktop layout renders 2-col synopsis + sidebar',
        (tester) async {
      final catalogApi = _CatalogApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(50, mediaType: 'movie'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 50,
                mediaType: 'movie',
                title: 'Desktop',
                overview: 'Two-column body should render.',
                genres: ['Drama'],
              ));

      await tester.pumpWidget(wrap(
        catalogApi: catalogApi,
        db: db,
        size: const Size(1280, 800),
        child: const TitlePage(tmdbId: 50, mediaType: 'movie'),
      ));
      await tester.pumpAndSettle();

      // TRAMA + GENERI both render — desktop body has both columns.
      expect(find.text('TRAMA'), findsOneWidget);
      expect(find.text('GENERI'), findsOneWidget);
    });

    testWidgets('tablet layout renders 2-col body', (tester) async {
      final catalogApi = _CatalogApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(60, mediaType: 'movie'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 60,
                mediaType: 'movie',
                title: 'Tablet',
                overview: 'Tablet body.',
                genres: ['Comedy'],
              ));

      await tester.pumpWidget(wrap(
        catalogApi: catalogApi,
        db: db,
        size: const Size(800, 1200),
        child: const TitlePage(tmdbId: 60, mediaType: 'movie'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('TRAMA'), findsOneWidget);
      expect(find.text('GENERI'), findsOneWidget);
    });

    testWidgets('phone layout hides sidebar until expansion tapped',
        (tester) async {
      final catalogApi = _CatalogApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(70, mediaType: 'movie'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 70,
                mediaType: 'movie',
                title: 'Phone',
                overview: 'Phone body.',
                genres: ['Sci-Fi'],
              ));

      // Use a phone-narrow MediaQuery so the responsive helper lands on
      // the mobile layout (the ListView is scrollable so screen height
      // doesn't matter — we ensureVisible before tapping the expander).
      await tester.pumpWidget(wrap(
        catalogApi: catalogApi,
        db: db,
        size: const Size(390, 600),
        child: const TitlePage(tmdbId: 70, mediaType: 'movie'),
      ));
      await tester.pumpAndSettle();

      // Mobile layout: expandable "Mostra dettagli" present, GENERI is
      // inside the collapsed subtree so it's not yet in the tree.
      expect(find.text('Mostra dettagli'), findsOneWidget);
      expect(find.text('GENERI'), findsNothing);
      await tester.ensureVisible(find.text('Mostra dettagli'));
      await tester.tap(find.text('Mostra dettagli'));
      await tester.pumpAndSettle();
      expect(find.text('GENERI'), findsOneWidget);
    });

    testWidgets('TV with episodes shows EPISODI section + episode rows',
        (tester) async {
      final catalogApi = _CatalogApiMock();
      final episodesApi = _EpisodesApiMock();
      final db = StreamloadDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      when(() => catalogApi.get(99, mediaType: 'tv'))
          .thenAnswer((_) async => const CatalogItemResponse(
                tmdbId: 99,
                mediaType: 'tv',
                title: 'Breaking Bad',
              ));

      when(() => episodesApi.list(99)).thenAnswer((_) async => {
            'seasons': [
              {
                'season_number': 1,
                'episodes': [
                  {
                    'episode_number': 1,
                    'title': 'Pilot',
                    'still_url': null,
                    'runtime_minutes': 58,
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

      expect(find.text('EPISODI · S1'), findsOneWidget);
      expect(find.text('Pilot'), findsOneWidget);
    });
  });
}
