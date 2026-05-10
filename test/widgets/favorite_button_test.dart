// test/widgets/favorite_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/presentation/widgets/favorite_button.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/title_provider.dart';

class _FavApiMock extends Mock implements FavoritesApi {}

void main() {
  testWidgets('renders outline when not favorited; tap calls api.add',
      (tester) async {
    final api = _FavApiMock();
    when(api.list).thenAnswer((_) async => []);
    when(() => api.add(7, 'movie')).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [favoritesApiProvider.overrideWith((_) async => api)],
      child: const MaterialApp(
        home: Scaffold(
          body: Center(
            child: FavoriteButton(
              target: TitleKey(tmdbId: 7, mediaType: 'movie'),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    verify(() => api.add(7, 'movie')).called(1);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('renders filled when already favorited; tap calls api.remove',
      (tester) async {
    final api = _FavApiMock();
    when(api.list).thenAnswer((_) async => [
          {
            'tmdb_id': 7,
            'media_type': 'movie',
            'title': 'Test',
            'year': 2020,
            'poster_url': null,
          }
        ]);
    when(() => api.remove(7, 'movie')).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [favoritesApiProvider.overrideWith((_) async => api)],
      child: const MaterialApp(
        home: Scaffold(
          body: Center(
            child: FavoriteButton(
              target: TitleKey(tmdbId: 7, mediaType: 'movie'),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();
    verify(() => api.remove(7, 'movie')).called(1);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });
}
