// test/state/favorites_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/favorites_provider.dart';
import 'package:streamload_client/state/title_provider.dart';

class _FavApiMock extends Mock implements FavoritesApi {}

void main() {
  late _FavApiMock api;
  setUp(() {
    api = _FavApiMock();
    when(api.list).thenAnswer((_) async => [
          {
            'tmdb_id': 1,
            'media_type': 'movie',
            'title': 'Dune',
            'year': 2021,
            'poster_url': null,
          },
        ]);
  });

  test('initial load populates set from backend', () async {
    final c = ProviderContainer(overrides: [
      favoritesApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(c.dispose);
    final state = await c.read(favoritesProvider.future);
    expect(
      state.contains(const TitleKey(tmdbId: 1, mediaType: 'movie')),
      isTrue,
    );
  });

  test('toggle adds optimistically + calls api.add', () async {
    when(() => api.add(5, 'movie')).thenAnswer((_) async {});
    final c = ProviderContainer(overrides: [
      favoritesApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(c.dispose);
    await c.read(favoritesProvider.future);
    await c.read(favoritesProvider.notifier).toggle(
          const TitleKey(tmdbId: 5, mediaType: 'movie'),
        );
    final state = c.read(favoritesProvider).value!;
    expect(
      state.contains(const TitleKey(tmdbId: 5, mediaType: 'movie')),
      isTrue,
    );
    verify(() => api.add(5, 'movie')).called(1);
  });

  test('toggle on existing item removes via api.remove', () async {
    when(() => api.remove(1, 'movie')).thenAnswer((_) async {});
    final c = ProviderContainer(overrides: [
      favoritesApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(c.dispose);
    await c.read(favoritesProvider.future);
    await c.read(favoritesProvider.notifier).toggle(
          const TitleKey(tmdbId: 1, mediaType: 'movie'),
        );
    final state = c.read(favoritesProvider).value!;
    expect(
      state.contains(const TitleKey(tmdbId: 1, mediaType: 'movie')),
      isFalse,
    );
    verify(() => api.remove(1, 'movie')).called(1);
  });

  test('rolls back optimistic add when api throws', () async {
    when(() => api.add(5, 'movie')).thenThrow(Exception('boom'));
    final c = ProviderContainer(overrides: [
      favoritesApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(c.dispose);
    await c.read(favoritesProvider.future);
    await expectLater(
      c.read(favoritesProvider.notifier).toggle(
        const TitleKey(tmdbId: 5, mediaType: 'movie'),
      ),
      throwsException,
    );
    final state = c.read(favoritesProvider).value!;
    expect(
      state.contains(const TitleKey(tmdbId: 5, mediaType: 'movie')),
      isFalse,
    );
  });
}
