import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_api.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/data/remote/endpoints/watchlist_api.dart';
import 'package:streamload_client/domain/models/catalog_item.dart';
import 'package:streamload_client/domain/models/library_category.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/database_provider.dart';
import 'package:streamload_client/state/my_list_items_provider.dart';

class _FavApiMock extends Mock implements FavoritesApi {}

class _WlApiMock extends Mock implements WatchlistApi {}

class _CatalogApiMock extends Mock implements CatalogApi {}

ProviderContainer _container({
  required FavoritesApi fav,
  required WatchlistApi wl,
  required CatalogApi catalog,
  required StreamloadDatabase db,
}) {
  final c = ProviderContainer(overrides: [
    favoritesApiProvider.overrideWith((_) async => fav),
    watchlistApiProvider.overrideWith((_) async => wl),
    catalogApiProvider.overrideWith((_) async => catalog),
    databaseProvider.overrideWithValue(db),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('lista vuota → []', () async {
    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => const []);
    when(wl.list).thenAnswer((_) async => const []);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    final c = _container(fav: fav, wl: wl, catalog: _CatalogApiMock(), db: db);
    final items = await c.read(myListItemsProvider.future);
    expect(items, isEmpty);
  });

  test('film con generi già in cache → Film, nessun backfill', () async {
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
    final catalog = _CatalogApiMock();

    final c = _container(fav: fav, wl: wl, catalog: catalog, db: db);
    final items = await c.read(myListItemsProvider.future);

    expect(items.single.category, LibraryCategory.film);
    verifyNever(() => catalog.get(any(), mediaType: any(named: 'mediaType')));
  });

  test('tv senza cache → backfill dal backend, generi classificano (anime)',
      () async {
    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => [
          {'tmdb_id': 7, 'media_type': 'tv', 'title': 'Naruto', 'year': 2002,
           'poster_url': null},
        ]);
    when(wl.list).thenAnswer((_) async => const []);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = _CatalogApiMock();
    when(() => catalog.get(7, mediaType: 'tv')).thenAnswer((_) async =>
        const CatalogItemResponse(
          tmdbId: 7, mediaType: 'tv', title: 'Naruto', genres: ['Animazione'],
        ));

    final c = _container(fav: fav, wl: wl, catalog: catalog, db: db);
    final items = await c.read(myListItemsProvider.future);

    expect(items.single.category, LibraryCategory.anime);
    verify(() => catalog.get(7, mediaType: 'tv')).called(1);
  });

  test('errore backend per-item → bucket di default (serieTv), nessuna eccezione',
      () async {
    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => [
          {'tmdb_id': 9, 'media_type': 'tv', 'title': '#9', 'year': null,
           'poster_url': null},
        ]);
    when(wl.list).thenAnswer((_) async => const []);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = _CatalogApiMock();
    when(() => catalog.get(9, mediaType: 'tv'))
        .thenThrow(Exception('boom'));

    final c = _container(fav: fav, wl: wl, catalog: catalog, db: db);
    final items = await c.read(myListItemsProvider.future);

    expect(items.single.category, LibraryCategory.serieTv);
    expect(items.single.summary.title, '#9');
  });
}
