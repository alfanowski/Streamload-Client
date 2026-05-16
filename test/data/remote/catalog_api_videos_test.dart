// test/data/remote/catalog_api_videos_test.dart
//
// Covers CatalogApi.videos — the new endpoint feeding HeroTrailer.
// Mocks the underlying Dio because the response is a JSON list (whereas
// ApiClient.getJson only unwraps maps).
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_api.dart';

class _DioMock extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  test('videos() parses YouTube list + passes media_type', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>(
          '/api/catalog/1396/videos',
          queryParameters: {'media_type': 'tv'},
        )).thenAnswer((_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/api/catalog/1396/videos'),
          statusCode: 200,
          data: [
            {
              'key': 'yt1',
              'site': 'YouTube',
              'type': 'Trailer',
              'official': true,
              'name': 'Official Trailer',
            },
            {
              'key': 'yt2',
              'site': 'YouTube',
              'type': 'Teaser',
              'official': false,
              'name': null,
            },
          ],
        ));

    final api = CatalogApi(ApiClient.test(dio));
    final out = await api.videos(1396, mediaType: 'tv');

    expect(out, hasLength(2));
    expect(out[0].key, 'yt1');
    expect(out[0].type, 'Trailer');
    expect(out[0].official, isTrue);
    expect(out[0].name, 'Official Trailer');
    expect(out[1].key, 'yt2');
    expect(out[1].official, isFalse);
    expect(out[1].name, isNull);
  });

  test('videos() returns empty list when body is null / non-list', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>(
          '/api/catalog/42/videos',
          queryParameters: {'media_type': 'movie'},
        )).thenAnswer((_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/api/catalog/42/videos'),
          statusCode: 200,
          data: null,
        ));

    final api = CatalogApi(ApiClient.test(dio));
    final out = await api.videos(42, mediaType: 'movie');
    expect(out, isEmpty);
  });
}
