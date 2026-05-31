// test/pages/category_list_page_test.dart
import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_api.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/data/remote/endpoints/watchlist_api.dart';
import 'package:streamload_client/domain/models/library_category.dart';
import 'package:streamload_client/presentation/pages/category_list_page.dart';
import 'package:streamload_client/presentation/widgets/poster_card.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/database_provider.dart';

class _FavApiMock extends Mock implements FavoritesApi {}

class _WlApiMock extends Mock implements WatchlistApi {}

class _CatalogApiMock extends Mock implements CatalogApi {}

Widget _wrap({
  required FavoritesApi fav,
  required WatchlistApi wl,
  required CatalogApi catalog,
  required StreamloadDatabase db,
  required LibraryCategory category,
}) {
  return ProviderScope(
    overrides: [
      favoritesApiProvider.overrideWith((_) async => fav),
      watchlistApiProvider.overrideWith((_) async => wl),
      catalogApiProvider.overrideWith((_) async => catalog),
      databaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp(home: CategoryListPage(category: category)),
  );
}

void main() {
  testWidgets('mostra titolo categoria + griglia copertine dei titoli',
      (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => [
          {'tmdb_id': 1, 'media_type': 'movie', 'title': 'Dune', 'year': 2021,
           'poster_url': null},
        ]);
    when(wl.list).thenAnswer((_) async => const []);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    await db.catalogDao.upsert(CatalogItemsCompanion.insert(
      tmdbId: 1,
      mediaType: 'movie',
      title: 'Dune',
      genresJson: Value(jsonEncode(['Azione'])),
    ));

    await tester.pumpWidget(_wrap(
      fav: fav,
      wl: wl,
      catalog: _CatalogApiMock(),
      db: db,
      category: LibraryCategory.film,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Film'), findsOneWidget);
    expect(find.byType(PosterCard), findsOneWidget);
  });
}
