// test/data/remote/catalog_rows_api_test.dart
//
// Covers HttpCatalogRowsApi — the client wrapper over the backend's
// /api/catalog/rows/* endpoints (sub-plan 8, Phase D1). Mocks Dio
// directly because the responses are JSON arrays (ApiClient.getJson
// only unwraps maps).
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_rows_api.dart';

class _DioMock extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  Response<dynamic> mkResp(List<Map<String, dynamic>> data, String path) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: data,
    );
  }

  test('trending() defaults to period=week, media_type=all, limit=40, page=1',
      () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>(
          '/api/catalog/rows/trending',
          queryParameters: {
            'period': 'week',
            'media_type': 'all',
            'limit': 40,
            'page': 1,
          },
        )).thenAnswer((_) async => mkResp([
          {
            'tmdb_id': 1,
            'media_type': 'movie',
            'title': 'A',
            'year': 2025,
            'poster_url': 'p',
            'backdrop_url': 'b',
          },
          {
            'tmdb_id': 2,
            'media_type': 'tv',
            'title': 'B',
          },
        ], '/api/catalog/rows/trending'));

    final api = HttpCatalogRowsApi(ApiClient.test(dio));
    final out = await api.trending();
    expect(out, hasLength(2));
    expect(out[0].tmdbId, 1);
    expect(out[0].title, 'A');
    expect(out[0].year, 2025);
    expect(out[0].posterUrl, 'p');
    expect(out[1].mediaType, 'tv');
  });

  test('newReleases() forwards media_type + default limit/page', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>(
          '/api/catalog/rows/new-releases',
          queryParameters: {'media_type': 'movie', 'limit': 40, 'page': 1},
        )).thenAnswer((_) async => mkResp(
              [
                {'tmdb_id': 9, 'media_type': 'movie', 'title': 'N'},
              ],
              '/api/catalog/rows/new-releases',
            ));

    final api = HttpCatalogRowsApi(ApiClient.test(dio));
    final out = await api.newReleases(mediaType: 'movie');
    expect(out.single.title, 'N');
  });

  test('byGenre() joins genre IDs with comma and forwards language', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>(
          '/api/catalog/rows/by-genre',
          queryParameters: {
            'genre_ids': '80,53',
            'media_type': 'movie',
            'original_language': 'it',
            'limit': 40,
            'page': 1,
          },
        )).thenAnswer((_) async => mkResp(
              [
                {'tmdb_id': 5, 'media_type': 'movie', 'title': 'G'},
              ],
              '/api/catalog/rows/by-genre',
            ));

    final api = HttpCatalogRowsApi(ApiClient.test(dio));
    final out = await api.byGenre(
      genreIds: const [80, 53],
      mediaType: 'movie',
      originalLanguage: 'it',
    );
    expect(out.single.title, 'G');
  });

  test('topRated() forwards media_type + default limit/page', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>(
          '/api/catalog/rows/top-rated',
          queryParameters: {'media_type': 'tv', 'limit': 40, 'page': 1},
        )).thenAnswer((_) async => mkResp(
              [
                {'tmdb_id': 12, 'media_type': 'tv', 'title': 'GOAT'},
              ],
              '/api/catalog/rows/top-rated',
            ));

    final api = HttpCatalogRowsApi(ApiClient.test(dio));
    final out = await api.topRated(mediaType: 'tv');
    expect(out.single.title, 'GOAT');
  });

  test('similar() and recommendations() target the correct path', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>(
          '/api/catalog/1396/similar',
          queryParameters: {'media_type': 'tv', 'limit': 40},
        )).thenAnswer((_) async => mkResp(
              [
                {'tmdb_id': 1397, 'media_type': 'tv', 'title': 'sim'},
              ],
              '/api/catalog/1396/similar',
            ));
    when(() => dio.get<dynamic>(
          '/api/catalog/1396/recommendations',
          queryParameters: {'media_type': 'tv', 'limit': 40},
        )).thenAnswer((_) async => mkResp(
              [
                {'tmdb_id': 1398, 'media_type': 'tv', 'title': 'rec'},
              ],
              '/api/catalog/1396/recommendations',
            ));

    final api = HttpCatalogRowsApi(ApiClient.test(dio));
    final sim = await api.similar(tmdbId: 1396, mediaType: 'tv');
    final rec = await api.recommendations(tmdbId: 1396, mediaType: 'tv');
    expect(sim.single.title, 'sim');
    expect(rec.single.title, 'rec');
  });

  test('any endpoint returns empty list on null / non-list body', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>(
          '/api/catalog/rows/trending',
          queryParameters: {
            'period': 'week',
            'media_type': 'all',
            'limit': 40,
            'page': 1,
          },
        )).thenAnswer((_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/api/catalog/rows/trending'),
          statusCode: 200,
          data: null,
        ));

    final api = HttpCatalogRowsApi(ApiClient.test(dio));
    final out = await api.trending();
    expect(out, isEmpty);
  });
}
