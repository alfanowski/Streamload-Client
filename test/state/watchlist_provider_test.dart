// test/state/watchlist_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/watchlist_api.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/title_provider.dart';
import 'package:streamload_client/state/watchlist_provider.dart';

class _WatchlistApiMock extends Mock implements WatchlistApi {}

void main() {
  late _WatchlistApiMock api;
  setUp(() {
    api = _WatchlistApiMock();
    when(api.list).thenAnswer((_) async => [
          {
            'tmdb_id': 2,
            'media_type': 'tv',
            'title': 'Breaking Bad',
            'year': 2008,
            'poster_url': null,
          },
        ]);
  });

  test('initial load populates set from backend', () async {
    final c = ProviderContainer(overrides: [
      watchlistApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(c.dispose);
    final state = await c.read(watchlistProvider.future);
    expect(
      state.contains(const TitleKey(tmdbId: 2, mediaType: 'tv')),
      isTrue,
    );
  });

  test('toggle adds optimistically + calls api.add', () async {
    when(() => api.add(10, 'tv')).thenAnswer((_) async {});
    final c = ProviderContainer(overrides: [
      watchlistApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(c.dispose);
    await c.read(watchlistProvider.future);
    await c.read(watchlistProvider.notifier).toggle(
          const TitleKey(tmdbId: 10, mediaType: 'tv'),
        );
    final state = c.read(watchlistProvider).value!;
    expect(
      state.contains(const TitleKey(tmdbId: 10, mediaType: 'tv')),
      isTrue,
    );
    verify(() => api.add(10, 'tv')).called(1);
  });

  test('toggle on existing item removes via api.remove', () async {
    when(() => api.remove(2, 'tv')).thenAnswer((_) async {});
    final c = ProviderContainer(overrides: [
      watchlistApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(c.dispose);
    await c.read(watchlistProvider.future);
    await c.read(watchlistProvider.notifier).toggle(
          const TitleKey(tmdbId: 2, mediaType: 'tv'),
        );
    final state = c.read(watchlistProvider).value!;
    expect(
      state.contains(const TitleKey(tmdbId: 2, mediaType: 'tv')),
      isFalse,
    );
    verify(() => api.remove(2, 'tv')).called(1);
  });

  test('rolls back optimistic add when api throws', () async {
    when(() => api.add(10, 'tv')).thenThrow(Exception('boom'));
    final c = ProviderContainer(overrides: [
      watchlistApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(c.dispose);
    await c.read(watchlistProvider.future);
    await expectLater(
      c.read(watchlistProvider.notifier).toggle(
        const TitleKey(tmdbId: 10, mediaType: 'tv'),
      ),
      throwsException,
    );
    final state = c.read(watchlistProvider).value!;
    expect(
      state.contains(const TitleKey(tmdbId: 10, mediaType: 'tv')),
      isFalse,
    );
  });
}
