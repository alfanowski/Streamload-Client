// test/state/search_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/search_api.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/search_provider.dart';

class _SearchApiMock extends Mock implements SearchApi {}

void main() {
  test('setQuery debounces and produces a result list', () async {
    final api = _SearchApiMock();
    when(() => api.run('dune')).thenAnswer((_) async => {
          'items': [
            {
              'tmdb_id': 1,
              'media_type': 'movie',
              'title': 'Dune',
              'year': 2021,
              'poster_url': null
            }
          ],
        });
    final container = ProviderContainer(overrides: [
      searchApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    final ctrl = container.read(searchControllerProvider.notifier);
    ctrl.setQuery('dune');
    // wait for the debounce window plus the api call.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final state = container.read(searchControllerProvider);
    expect(state.value, isNotNull);
    expect(state.value!.first.title, 'Dune');
  });

  test('empty query produces an empty list, no api call', () async {
    final api = _SearchApiMock();
    final container = ProviderContainer(overrides: [
      searchApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    container.read(searchControllerProvider.notifier).setQuery('');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final state = container.read(searchControllerProvider);
    expect(state.value, isEmpty);
    verifyNever(() => api.run(any()));
  });
}
