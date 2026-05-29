// test/pages/library_page_test.dart
//
// 2026-05-17 (P3 hotfix): LibraryPage is now "La mia lista" — the user's
// favorites ∪ watchlist, resolved against the local drift cache. These
// tests pin the new contract:
//
//   - empty favorites + watchlist → empty-state card with the "+" hint
//   - one favorite movie → grid renders that movie (or the #tmdbId
//     placeholder when the catalog cache is empty, as in tests)
//   - tabs Film + Serie TV are still visible
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/data/remote/endpoints/watchlist_api.dart';
import 'package:streamload_client/presentation/pages/library_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/database_provider.dart';

class _FavApiMock extends Mock implements FavoritesApi {}

class _WlApiMock extends Mock implements WatchlistApi {}

Widget _wrap({
  required FavoritesApi fav,
  required WatchlistApi wl,
  required StreamloadDatabase db,
}) {
  return ProviderScope(
    overrides: [
      favoritesApiProvider.overrideWith((_) async => fav),
      watchlistApiProvider.overrideWith((_) async => wl),
      databaseProvider.overrideWithValue(db),
    ],
    child: const MaterialApp(home: LibraryPage()),
  );
}

void main() {
  testWidgets('shows the empty state when favorites + watchlist are empty',
      (tester) async {
    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => const <Map<String, dynamic>>[]);
    when(wl.list).thenAnswer((_) async => const <Map<String, dynamic>>[]);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(fav: fav, wl: wl, db: db));
    await tester.pumpAndSettle();

    expect(find.text('La tua lista è vuota'), findsOneWidget);
    expect(
      find.text('Tocca ＋ La mia lista su un titolo per aggiungerlo qui.'),
      findsOneWidget,
    );
  });

  testWidgets('renders a card per favorite (placeholder when cache empty)',
      (tester) async {
    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => [
          {'tmdb_id': 27205, 'media_type': 'movie'},
        ]);
    when(wl.list).thenAnswer((_) async => const <Map<String, dynamic>>[]);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(fav: fav, wl: wl, db: db));
    await tester.pumpAndSettle();

    // Catalog cache is empty in tests → resolver falls back to a
    // "#tmdbId" placeholder card.
    expect(find.text('#27205'), findsOneWidget);
  });

  testWidgets('shows Film and Serie TV tabs', (tester) async {
    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => [
          {'tmdb_id': 1, 'media_type': 'movie'},
        ]);
    when(wl.list).thenAnswer((_) async => const <Map<String, dynamic>>[]);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(fav: fav, wl: wl, db: db));
    await tester.pumpAndSettle();

    // Scope to the Tab widget — cards now carry a 'Film'/'Serie' meta
    // label too, so a bare find.text('Film') would match both.
    expect(find.widgetWithText(Tab, 'Film'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Serie TV'), findsOneWidget);
    expect(find.text('La mia lista'), findsOneWidget);
  });

  testWidgets('union of favorites + watchlist (deduped by tmdbId)',
      (tester) async {
    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => [
          {'tmdb_id': 1, 'media_type': 'movie'},
          {'tmdb_id': 2, 'media_type': 'movie'},
        ]);
    when(wl.list).thenAnswer((_) async => [
          // 2 is in both — should not double-render.
          {'tmdb_id': 2, 'media_type': 'movie'},
          {'tmdb_id': 3, 'media_type': 'movie'},
        ]);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(fav: fav, wl: wl, db: db));
    await tester.pumpAndSettle();

    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('#3'), findsOneWidget);
  });
}
