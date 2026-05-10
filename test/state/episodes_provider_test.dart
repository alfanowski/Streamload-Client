// test/state/episodes_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/episodes_api.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/episodes_provider.dart';

class _EpisodesApiMock extends Mock implements EpisodesApi {}

void main() {
  test('episodesProvider parses seasons + episodes from the api response',
      () async {
    final api = _EpisodesApiMock();
    when(() => api.list(99)).thenAnswer((_) async => {
          'seasons': [
            {
              'number': 1,
              'name': 'Stagione 1',
              'episodes': [
                {
                  'season': 1,
                  'episode': 1,
                  'title': 'Pilot',
                  'overview': 'An intro.',
                  'still_url': null,
                  'runtime_minutes': 42,
                  'air_date': '2024-01-01',
                },
              ],
            },
          ],
        });

    final container = ProviderContainer(overrides: [
      episodesApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    final result = await container.read(episodesProvider(99).future);

    expect(result.seasons, hasLength(1));
    expect(result.seasons.first.name, 'Stagione 1');
    expect(result.seasons.first.episodes, hasLength(1));
    expect(result.seasons.first.episodes.first.title, 'Pilot');
    expect(result.seasons.first.episodes.first.runtimeMinutes, 42);
  });

  test('episodesProvider handles empty seasons gracefully', () async {
    final api = _EpisodesApiMock();
    when(() => api.list(1)).thenAnswer((_) async => {'seasons': []});

    final container = ProviderContainer(overrides: [
      episodesApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    final result = await container.read(episodesProvider(1).future);
    expect(result.seasons, isEmpty);
  });
}
