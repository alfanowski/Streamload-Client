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
      titleTrailerProvider.overrideWith((_, __) async => null),
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
      expect(find.text('A hero rises.'), findsOneWidget);
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

  group('TitlePage — TV variant', () {
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
  });
}
