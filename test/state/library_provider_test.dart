// test/state/library_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/library_api.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/library_provider.dart';

class _LibraryApiMock extends Mock implements LibraryApi {}

void main() {
  test('libraryProvider passes mediaType+page to api and returns LibraryPageData',
      () async {
    final api = _LibraryApiMock();
    when(() => api.page(mediaType: 'movie', page: 2, perPage: 24))
        .thenAnswer((_) async => {
              'items': [
                {
                  'tmdb_id': 1,
                  'media_type': 'movie',
                  'title': 'X',
                  'year': 2024,
                  'poster_url': null,
                }
              ],
              'page': 2,
              'per_page': 24,
              'total': 100,
            });

    final container = ProviderContainer(overrides: [
      libraryApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    final got = await container.read(
      libraryProvider(const LibraryQuery(mediaType: 'movie', page: 2)).future,
    );
    expect(got.total, 100);
    expect(got.items.single.title, 'X');
  });
}
