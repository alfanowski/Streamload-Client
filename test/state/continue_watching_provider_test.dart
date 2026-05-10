// test/state/continue_watching_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/progress_api.dart';
import 'package:streamload_client/domain/models/continue_watching_item.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/continue_watching_provider.dart';

class _ProgressApiMock extends Mock implements ProgressApi {}

void main() {
  test('parses one item returned from the API', () async {
    final api = _ProgressApiMock();
    when(api.continueWatching).thenAnswer((_) async => {
      'items': [
        {
          'tmdb_id': 1396,
          'media_type': 'tv',
          'title': 'Breaking Bad',
          'poster_url': 'https://example.com/bb.jpg',
          'season_number': 1,
          'episode_number': 3,
          'position_seconds': 420,
          'duration_seconds': 2700,
        }
      ],
    });

    final container = ProviderContainer(overrides: [
      progressApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    final items = await container.read(continueWatchingProvider.future);

    expect(items, hasLength(1));
    final item = items.first;
    expect(item.tmdbId, 1396);
    expect(item.mediaType, 'tv');
    expect(item.title, 'Breaking Bad');
    expect(item.posterUrl, 'https://example.com/bb.jpg');
    expect(item.seasonNumber, 1);
    expect(item.episodeNumber, 3);
    expect(item.positionSeconds, 420);
    expect(item.durationSeconds, 2700);
  });

  test('returns empty list when API returns no items', () async {
    final api = _ProgressApiMock();
    when(api.continueWatching).thenAnswer((_) async => {'items': []});

    final container = ProviderContainer(overrides: [
      progressApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    final items = await container.read(continueWatchingProvider.future);
    expect(items, isEmpty);
  });

  test('parses movie item (no season/episode)', () async {
    final api = _ProgressApiMock();
    when(api.continueWatching).thenAnswer((_) async => {
      'items': [
        {
          'tmdb_id': 42,
          'media_type': 'movie',
          'title': 'Dune',
          'poster_url': null,
          'season_number': null,
          'episode_number': null,
          'position_seconds': 3600,
          'duration_seconds': 9000,
        }
      ],
    });

    final container = ProviderContainer(overrides: [
      progressApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    final items = await container.read(continueWatchingProvider.future);
    expect(items.first.seasonNumber, isNull);
    expect(items.first.episodeNumber, isNull);
    expect(
      items.first,
      isA<ContinueWatchingItem>()
          .having((i) => i.tmdbId, 'tmdbId', 42)
          .having((i) => i.mediaType, 'mediaType', 'movie'),
    );
  });
}
