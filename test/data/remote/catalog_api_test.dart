// test/data/remote/catalog_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_api.dart';

class _ClientMock extends Mock implements ApiClient {}

void main() {
  test('catalog.get with media_type appends query', () async {
    final client = _ClientMock();
    when(() => client.getJson('/api/catalog/1396',
        query: {'media_type': 'tv'})).thenAnswer((_) async => {
          'tmdb_id': 1396,
          'media_type': 'tv',
          'title': 'Breaking Bad',
          'original_title': null,
          'year': 2008,
          'poster_url': null,
          'backdrop_url': null,
          'overview': null,
          'rating': null,
          'runtime_minutes': null,
          'seasons_count': 5,
          'genres': <String>[],
          'sources': <Map<String, dynamic>>[],
        });
    final api = CatalogApi(client);
    final item = await api.get(1396, mediaType: 'tv');
    expect(item.title, 'Breaking Bad');
    expect(item.seasonsCount, 5);
    expect(item.sources, isEmpty);
  });
}
