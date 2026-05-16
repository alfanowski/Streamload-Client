// test/state/home_rows_provider_test.dart
//
// Covers home_rows_provider — the riverpod surface feeding HomePage in
// sub-plan 8 / Phase D2. We override catalogRowsApiProvider with a fake
// implementation so the tests stay offline. heroSlidesProvider also
// overrides catalogApiProvider (it fetches per-title videos).
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_api.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_rows_api.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/data/remote/endpoints/watchlist_api.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/favorites_provider.dart';
import 'package:streamload_client/state/home_rows_provider.dart';
import 'package:streamload_client/state/watchlist_provider.dart';

class _FakeRowsApi implements CatalogRowsApi {
  _FakeRowsApi({this.trendingDay, this.trendingWeek, this.newReleasesByType});
  final List<MediaSummary>? trendingDay;
  final List<MediaSummary>? trendingWeek;
  final Map<String, List<MediaSummary>>? newReleasesByType;

  @override
  Future<List<MediaSummary>> trending({
    String period = 'week',
    String mediaType = 'all',
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async =>
      period == 'day'
          ? (trendingDay ?? const [])
          : (trendingWeek ?? const []);

  @override
  Future<List<MediaSummary>> newReleases({
    required String mediaType,
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async =>
      newReleasesByType?[mediaType] ?? const [];

  @override
  Future<List<MediaSummary>> byGenre({
    required List<int> genreIds,
    required String mediaType,
    String? originalLanguage,
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async =>
      const [];

  @override
  Future<List<MediaSummary>> topRated({
    required String mediaType,
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async =>
      const [];

  @override
  Future<List<MediaSummary>> similar({
    required int tmdbId,
    required String mediaType,
    int limit = kDefaultRowLimit,
  }) async =>
      const [];

  @override
  Future<List<MediaSummary>> recommendations({
    required int tmdbId,
    required String mediaType,
    int limit = kDefaultRowLimit,
  }) async =>
      const [];
}

class _DioMock extends Mock implements Dio {}

class _FavApiMock extends Mock implements FavoritesApi {}

class _WlApiMock extends Mock implements WatchlistApi {}

MediaSummary _summary({
  required int id,
  String mediaType = 'movie',
  String title = 'T',
  String? backdrop = 'bd',
}) =>
    MediaSummary(
      tmdbId: id,
      mediaType: mediaType,
      title: title,
      backdropUrl: backdrop,
    );

void main() {
  group('row providers forward to CatalogRowsApi', () {
    test('trendingDay / trendingWeek return their respective lists', () async {
      final fake = _FakeRowsApi(
        trendingDay: [_summary(id: 1, title: 'D')],
        trendingWeek: [_summary(id: 2, title: 'W')],
      );
      final c = ProviderContainer(overrides: [
        catalogRowsApiProvider.overrideWith((_) async => fake),
      ]);
      addTearDown(c.dispose);

      final day = await c.read(trendingDayProvider.future);
      final week = await c.read(trendingWeekProvider.future);
      expect(day.single.title, 'D');
      expect(week.single.title, 'W');
    });

    test('newReleasesAllProvider concatenates movie + tv', () async {
      final fake = _FakeRowsApi(newReleasesByType: {
        'movie': [_summary(id: 1, title: 'M1'), _summary(id: 2, title: 'M2')],
        'tv': [_summary(id: 3, mediaType: 'tv', title: 'T1')],
      });
      final c = ProviderContainer(overrides: [
        catalogRowsApiProvider.overrideWith((_) async => fake),
      ]);
      addTearDown(c.dispose);

      final all = await c.read(newReleasesAllProvider.future);
      expect(all.map((m) => m.title), containsAll(['M1', 'M2', 'T1']));
    });
  });

  group('row key equality', () {
    test('GenreRowKey same fields are equal', () {
      const a = GenreRowKey(genreIds: [1, 2], mediaType: 'movie');
      const b = GenreRowKey(genreIds: [1, 2], mediaType: 'movie');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('GenreRowKey different list order is not equal', () {
      const a = GenreRowKey(genreIds: [1, 2], mediaType: 'movie');
      const b = GenreRowKey(genreIds: [2, 1], mediaType: 'movie');
      expect(a, isNot(equals(b)));
    });

    test('GenreRowKey with language differs', () {
      const a = GenreRowKey(genreIds: [35], mediaType: 'movie');
      const b = GenreRowKey(
        genreIds: [35],
        mediaType: 'movie',
        originalLanguage: 'it',
      );
      expect(a, isNot(equals(b)));
    });

    test('TmdbKey equality / hashCode', () {
      const a = TmdbKey(tmdbId: 1, mediaType: 'tv');
      const b = TmdbKey(tmdbId: 1, mediaType: 'tv');
      const c = TmdbKey(tmdbId: 1, mediaType: 'movie');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('heroSlidesProvider', () {
    test('takes top 5 trending and resolves YouTube trailer keys', () async {
      final trending = List.generate(
        7,
        (i) => _summary(id: 100 + i, title: 'T$i', backdrop: 'bd$i'),
      );
      final fakeRows = _FakeRowsApi(trendingWeek: trending);

      // Fake CatalogApi via mocked Dio — videos() shape per tmdbId.
      final dio = _DioMock();
      for (var i = 0; i < 5; i++) {
        when(() => dio.get<dynamic>(
              '/api/catalog/${100 + i}/videos',
              queryParameters: {'media_type': 'movie'},
            )).thenAnswer((_) async => Response<dynamic>(
              requestOptions: RequestOptions(path: '/api/catalog/${100 + i}/videos'),
              statusCode: 200,
              data: [
                // First entry isn't official → should be skipped in favor
                // of the second official trailer.
                {
                  'key': 'fan$i',
                  'site': 'YouTube',
                  'type': 'Trailer',
                  'official': false,
                },
                {
                  'key': 'yt$i',
                  'site': 'YouTube',
                  'type': 'Trailer',
                  'official': true,
                },
              ],
            ));
      }

      final c = ProviderContainer(overrides: [
        catalogRowsApiProvider.overrideWith((_) async => fakeRows),
        catalogApiProvider.overrideWith((_) async => CatalogApi(ApiClient.test(dio))),
      ]);
      addTearDown(c.dispose);

      final slides = await c.read(heroSlidesProvider.future);
      expect(slides, hasLength(5));
      // Keys come from the second (official) entry.
      expect(slides[0].videoId, 'yt0');
      expect(slides[4].videoId, 'yt4');
      expect(slides[0].title, 'T0');
      expect(slides[0].backdropUrl, 'bd0');
    });

    test('falls back to null videoId when no videos exist', () async {
      final trending = [_summary(id: 200, title: 'Only')];
      final fakeRows = _FakeRowsApi(trendingWeek: trending);

      final dio = _DioMock();
      when(() => dio.get<dynamic>(
            '/api/catalog/200/videos',
            queryParameters: {'media_type': 'movie'},
          )).thenAnswer((_) async => Response<dynamic>(
            requestOptions: RequestOptions(path: '/api/catalog/200/videos'),
            statusCode: 200,
            data: [],
          ));

      final c = ProviderContainer(overrides: [
        catalogRowsApiProvider.overrideWith((_) async => fakeRows),
        catalogApiProvider.overrideWith((_) async => CatalogApi(ApiClient.test(dio))),
      ]);
      addTearDown(c.dispose);

      final slides = await c.read(heroSlidesProvider.future);
      expect(slides, hasLength(1));
      expect(slides[0].videoId, isNull);
    });

    test('returns empty list when trending is empty', () async {
      final fakeRows = _FakeRowsApi(trendingWeek: const []);
      final c = ProviderContainer(overrides: [
        catalogRowsApiProvider.overrideWith((_) async => fakeRows),
      ]);
      addTearDown(c.dispose);
      final slides = await c.read(heroSlidesProvider.future);
      expect(slides, isEmpty);
    });

    test('swallows videos errors and yields null videoId for that slide',
        () async {
      final trending = [_summary(id: 300, title: 'Err')];
      final fakeRows = _FakeRowsApi(trendingWeek: trending);

      final dio = _DioMock();
      when(() => dio.get<dynamic>(
            '/api/catalog/300/videos',
            queryParameters: {'media_type': 'movie'},
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: '/api/catalog/300/videos'),
            error: 'boom',
          ));

      final c = ProviderContainer(overrides: [
        catalogRowsApiProvider.overrideWith((_) async => fakeRows),
        catalogApiProvider.overrideWith((_) async => CatalogApi(ApiClient.test(dio))),
      ]);
      addTearDown(c.dispose);

      final slides = await c.read(heroSlidesProvider.future);
      expect(slides, hasLength(1));
      expect(slides[0].videoId, isNull);
    });
  });

  group('myListKeysProvider', () {
    test('combines favorites + watchlist deduped by tmdbId', () async {
      final fav = _FavApiMock();
      final wl = _WlApiMock();
      when(fav.list).thenAnswer((_) async => [
            {'tmdb_id': 1, 'media_type': 'movie'},
            {'tmdb_id': 2, 'media_type': 'tv'},
          ]);
      when(wl.list).thenAnswer((_) async => [
            {'tmdb_id': 2, 'media_type': 'tv'},
            {'tmdb_id': 3, 'media_type': 'movie'},
          ]);

      final c = ProviderContainer(overrides: [
        favoritesApiProvider.overrideWith((_) async => fav),
        watchlistApiProvider.overrideWith((_) async => wl),
      ]);
      addTearDown(c.dispose);

      await c.read(favoritesProvider.future);
      await c.read(watchlistProvider.future);

      final keys = c.read(myListKeysProvider);
      final ids = keys.map((k) => k.tmdbId).toSet();
      expect(ids, equals({1, 2, 3}));
      // No duplicates.
      expect(keys.length, 3);
    });

    test('empty when both lists empty', () async {
      final fav = _FavApiMock();
      final wl = _WlApiMock();
      when(fav.list).thenAnswer((_) async => const []);
      when(wl.list).thenAnswer((_) async => const []);
      final c = ProviderContainer(overrides: [
        favoritesApiProvider.overrideWith((_) async => fav),
        watchlistApiProvider.overrideWith((_) async => wl),
      ]);
      addTearDown(c.dispose);
      await c.read(favoritesProvider.future);
      await c.read(watchlistProvider.future);
      expect(c.read(myListKeysProvider), isEmpty);
    });
  });
}
