// test/pages/home_page_test.dart
//
// v3 HomePage smoke tests (sub-plan 8, Phase D5). The page composes a
// HeroCarousel + a stack of row Consumers; we override each row
// provider with a synchronous AsyncData so the rows render immediately
// and we can assert their titles.
//
// The hero carousel uses webview_flutter, which is not driven in a
// widget test environment. We override heroSlidesProvider with an
// empty list so it renders the placeholder, keeping the test
// dependency-free.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_rows_api.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/data/remote/endpoints/progress_api.dart';
import 'package:streamload_client/data/remote/endpoints/watchlist_api.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/presentation/pages/home_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/database_provider.dart';
import 'package:streamload_client/state/home_rows_provider.dart';
import 'package:streamload_client/state/nav_scrolled_provider.dart';
import 'package:streamload_client/state/plugin_access_provider.dart';
import 'package:drift/native.dart';

class _FakeRowsApi implements CatalogRowsApi {
  _FakeRowsApi();
  @override
  Future<List<MediaSummary>> trending({
    String period = 'week',
    String mediaType = 'all',
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async {
    if (period == 'day') {
      return [
        const MediaSummary(tmdbId: 10, mediaType: 'movie', title: 'TrendingDayA'),
      ];
    }
    return const [];
  }

  @override
  Future<List<MediaSummary>> newReleases({
    required String mediaType,
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async =>
      [
        MediaSummary(
          tmdbId: 20,
          mediaType: mediaType,
          title: 'New-$mediaType',
        ),
      ];

  @override
  Future<List<MediaSummary>> byGenre({
    required List<int> genreIds,
    required String mediaType,
    String? originalLanguage,
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async =>
      [
        MediaSummary(
          tmdbId: 30,
          mediaType: mediaType,
          title: 'Genre-${genreIds.join("_")}-$mediaType',
        ),
      ];

  @override
  Future<List<MediaSummary>> topRated({
    required String mediaType,
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async =>
      [
        MediaSummary(
          tmdbId: 40,
          mediaType: mediaType,
          title: 'Top-$mediaType',
        ),
      ];

  @override
  Future<List<MediaSummary>> similar({
    required int tmdbId,
    required String mediaType,
    int limit = kDefaultRowLimit,
  }) async =>
      const [];

  @override
  Future<List<MediaSummary>> recommendations({
    required int tmdbId,
    required String mediaType,
    int limit = kDefaultRowLimit,
  }) async =>
      const [];
}

class _FavApiMock extends Mock implements FavoritesApi {}

class _WlApiMock extends Mock implements WatchlistApi {}

class _ProgressApiMock extends Mock implements ProgressApi {}

void main() {
  Future<void> pump(
    WidgetTester t, {
    String? filter,
    List<Override> extra = const [],
  }) async {
    await t.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final fav = _FavApiMock();
    when(fav.list).thenAnswer((_) async => const []);
    final wl = _WlApiMock();
    when(wl.list).thenAnswer((_) async => const []);
    final progress = _ProgressApiMock();
    when(progress.continueWatching).thenAnswer((_) async => {'items': []});

    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        for (final p in const ['/home', '/film', '/serie', '/anime'])
          GoRoute(
            path: p,
            builder: (_, state) => Scaffold(body: HomePage(filter: filter)),
          ),
        GoRoute(
          path: '/title/:tmdbId',
          builder: (_, s) => const Scaffold(body: Text('TitlePage')),
        ),
      ],
    );
    await t.pumpWidget(ProviderScope(
      overrides: [
        catalogRowsApiProvider.overrideWith((_) async => _FakeRowsApi()),
        favoritesApiProvider.overrideWith((_) async => fav),
        watchlistApiProvider.overrideWith((_) async => wl),
        progressApiProvider.overrideWith((_) async => progress),
        databaseProvider.overrideWithValue(db),
        // Hide hero (webview can't run in test env) — empty slide list
        // forces placeholder render.
        heroSlidesProvider.overrideWith((_) async => const []),
        pluginAccessProvider.overrideWith((_) => PluginAccess.available),
        ...extra,
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    // Two pumps: first the layout, then the async providers settle.
    await t.pump();
    await t.pump(const Duration(milliseconds: 50));
  }

  testWidgets('renders filter chips with the expected labels', (t) async {
    await pump(t);
    expect(find.text('Tutto'), findsOneWidget);
    expect(find.text('Film'), findsOneWidget);
    expect(find.text('Serie TV'), findsOneWidget);
    expect(find.text('Anime'), findsAtLeastNWidgets(1)); // chip + Anime row
  });

  // Helper: drag the outer page scrollable downward by [px] so off-screen
  // rows get built. We dispatch the drag at the very top of the page so
  // we hit the vertical (page) ListView rather than the horizontal rows
  // inside it.
  Future<void> scrollPage(WidgetTester t, double px) async {
    final list = find.byType(ListView).first;
    await t.drag(list, Offset(0, -px));
    await t.pump();
    await t.pump(const Duration(milliseconds: 16));
  }

  // Helper: scroll the page ListView until the row with the given title
  // is visible. Returns once visible; throws if not found in [maxSteps]
  // 400px steps. Use this instead of fixed-N scrolls so test assertions
  // don't break when the page gains / drops rows.
  Future<void> scrollUntilTitle(WidgetTester t, String title,
      {int maxSteps = 30}) async {
    final list = find.byType(ListView).first;
    await t.scrollUntilVisible(
      find.text(title),
      400,
      scrollable: find.descendant(
        of: list,
        matching: find.byType(Scrollable),
      ).first,
      maxScrolls: maxSteps,
    );
  }

  testWidgets('default (filter=null) shows the top + bottom rows',
      (t) async {
    await pump(t);
    await t.pumpAndSettle();
    expect(find.text('Tendenze oggi'), findsOneWidget);
    expect(find.text('Nuove uscite'), findsOneWidget);
    await scrollUntilTitle(t, 'Top di sempre');
    expect(find.text('Top di sempre'), findsOneWidget);
  });

  testWidgets('default filter renders the per-genere rows once scrolled',
      (t) async {
    await pump(t);
    await t.pumpAndSettle();
    await scrollUntilTitle(t, 'Crime & Thriller');
    expect(find.text('Crime & Thriller'), findsOneWidget);
    await scrollUntilTitle(t, 'Commedie italiane');
    expect(find.text('Commedie italiane'), findsOneWidget);
  });

  testWidgets('filter=movie shows movie-specific genre rows', (t) async {
    // P2 (2026-05-17): /film now renders a full Netflix-style catalog
    // with ~13 rows so the operator can browse by genre. Tests assert
    // the new top-row + a couple of representative genre rows
    // materialize after scrolling.
    await pump(t, filter: 'movie');
    await t.pumpAndSettle();
    expect(find.text('Tendenze film oggi'), findsOneWidget);
    // "Anime" chip is visible at top of page even on the /film route.
    expect(find.text('Anime'), findsOneWidget);
    await scrollUntilTitle(t, 'Azione');
    expect(find.text('Azione'), findsOneWidget);
    await scrollUntilTitle(t, 'Crime & Thriller');
    expect(find.text('Crime & Thriller'), findsOneWidget);
    await scrollUntilTitle(t, 'Commedie italiane');
    expect(find.text('Commedie italiane'), findsOneWidget);
  });

  testWidgets('filter=movie omits Documentari (TV-only genre)',
      (t) async {
    // Scroll to the very end so every row is materialized at some point
    // — Documentari should never appear in /film.
    await pump(t, filter: 'movie');
    await t.pumpAndSettle();
    await scrollUntilTitle(t, 'Top di sempre');
    // Documentari never built — it's not in the movie row set.
    expect(find.text('Documentari'), findsNothing);
  });

  testWidgets('filter=tv shows tv-specific genre rows', (t) async {
    await pump(t, filter: 'tv');
    await t.pumpAndSettle();
    expect(find.text('Tendenze serie TV oggi'), findsOneWidget);
    await scrollUntilTitle(t, 'Crime');
    expect(find.text('Crime'), findsOneWidget);
    await scrollUntilTitle(t, 'Documentari');
    expect(find.text('Documentari'), findsOneWidget);
  });

  testWidgets('filter=tv omits movie-only labels', (t) async {
    await pump(t, filter: 'tv');
    await t.pumpAndSettle();
    await scrollUntilTitle(t, 'Top di sempre');
    expect(find.text('Crime & Thriller'), findsNothing);
    expect(find.text('Commedie italiane'), findsNothing);
  });

  testWidgets('filter=anime shows only the Anime-relevant rows', (t) async {
    await pump(t, filter: 'anime');
    await t.pumpAndSettle();
    expect(find.text('Anime'), findsAtLeastNWidgets(1));
    await scrollUntilTitle(t, 'Tendenze TV oggi');
    expect(find.text('Tendenze TV oggi'), findsOneWidget);
    await scrollUntilTitle(t, 'Top serie TV');
    expect(find.text('Top serie TV'), findsOneWidget);
  });

  testWidgets('filter=anime omits non-anime rows', (t) async {
    await pump(t, filter: 'anime');
    await t.pumpAndSettle();
    await scrollUntilTitle(t, 'Top serie TV');
    expect(find.text('Nuove uscite'), findsNothing);
    expect(find.text('Crime & Thriller'), findsNothing);
  });

  testWidgets('scrolling past 80px flips navScrolledProvider true',
      (t) async {
    await pump(t);
    await t.pumpAndSettle();

    final container = ProviderScope.containerOf(
      t.element(find.byType(HomePage)),
    );
    expect(container.read(navScrolledProvider), isFalse);

    final list = find.byType(ListView).first;
    await t.drag(list, const Offset(0, -200));
    await t.pump();
    await t.pump(const Duration(milliseconds: 16));
    expect(container.read(navScrolledProvider), isTrue);
  });
}
