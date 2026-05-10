// test/state/collections_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/collections_api.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/collections_provider.dart';

class _CollectionsApiMock extends Mock implements CollectionsApi {}

void main() {
  test('collectionsProvider parses CollectionSummary list', () async {
    final api = _CollectionsApiMock();
    when(api.list).thenAnswer((_) async => [
          {
            'id': 'trending_movies',
            'title': 'In Tendenza',
            'media_type': 'movie',
            'items': [
              {
                'tmdb_id': 1,
                'media_type': 'movie',
                'title': 'X',
                'year': 2024,
                'poster_url': 'https://p/x.jpg',
              },
            ],
          },
        ]);

    final container = ProviderContainer(overrides: [
      collectionsApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    final result = await container.read(collectionsProvider.future);
    expect(result, hasLength(1));
    expect(result.first.id, 'trending_movies');
    expect(result.first.items.first.title, 'X');
  });
}
