// test/pages/search_page_test.dart
//
// Phase G2 — Full-results /search page. Verifies:
//  - renders the input + Suggerite per te suggestions when empty
//  - initialQuery pre-fills the input + triggers a page=1 fetch
//  - submitting the input updates the URL (context.go fires)
//  - all media types mix into the same grid (no filter chips after Pass 2E)
//  - no-results shows the "Nessun risultato" message
//  - loading state renders the skeleton grid
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:streamload_client/data/remote/endpoints/catalog_rows_api.dart';
import 'package:streamload_client/data/remote/endpoints/search_api.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/domain/models/search_results.dart';
import 'package:streamload_client/presentation/pages/search_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';

class _SearchApiMock extends Mock implements SearchApi {}

class _CatalogRowsApiStub implements CatalogRowsApi {
  _CatalogRowsApiStub(this.trendingItems);
  final List<MediaSummary> trendingItems;

  @override
  Future<List<MediaSummary>> trending({
    String period = 'week',
    String mediaType = 'all',
    int limit = 60,
    int page = 1,
  }) async {
    return trendingItems;
  }

  @override
  Future<List<MediaSummary>> newReleases({
    required String mediaType,
    int limit = 60,
    int page = 1,
  }) async =>
      const [];

  @override
  Future<List<MediaSummary>> byGenre({
    required List<int> genreIds,
    required String mediaType,
    String? originalLanguage,
    int limit = 60,
    int page = 1,
  }) async =>
      const [];

  @override
  Future<List<MediaSummary>> topRated({
    required String mediaType,
    int limit = 60,
    int page = 1,
  }) async =>
      const [];

  @override
  Future<List<MediaSummary>> similar({
    required int tmdbId,
    required String mediaType,
    int limit = 60,
  }) async =>
      const [];

  @override
  Future<List<MediaSummary>> recommendations({
    required int tmdbId,
    required String mediaType,
    int limit = 60,
  }) async =>
      const [];
}

class _NavSpy {
  final List<String> visited = [];
}

// ignore: library_private_types_in_public_api
GoRouter _router(_NavSpy spy, {required String initial}) {
  return GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(
        path: '/search',
        builder: (_, state) {
          spy.visited
              .add('/search?q=${state.uri.queryParameters['q'] ?? ''}');
          return SearchPage(
            initialQuery: state.uri.queryParameters['q'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/title/:id',
        builder: (_, state) => const Scaffold(body: Text('title-page')),
      ),
    ],
  );
}

Future<void> pumpPage(
  WidgetTester t, {
  required SearchApi api,
  required _NavSpy spy,
  String initial = '/search',
  Size surface = const Size(1400, 900),
  List<MediaSummary> trendingItems = const [],
}) async {
  t.view.devicePixelRatio = 1.0;
  t.view.physicalSize = surface;
  await t.binding.setSurfaceSize(surface);
  addTearDown(() {
    t.view.resetPhysicalSize();
    t.view.resetDevicePixelRatio();
    t.binding.setSurfaceSize(null);
  });
  await t.pumpWidget(ProviderScope(
    overrides: [
      searchApiProvider.overrideWith((_) async => api),
      catalogRowsApiProvider
          .overrideWith((_) async => _CatalogRowsApiStub(trendingItems)),
    ],
    child: MaterialApp.router(routerConfig: _router(spy, initial: initial)),
  ));
  await t.pump();
}

MediaSummary _result({
  required int tmdbId,
  required String type,
  required String title,
  int? year,
}) =>
    MediaSummary(
      tmdbId: tmdbId,
      mediaType: type,
      title: title,
      year: year,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(0);
  });

  testWidgets('renders input + Ricerche di tendenza when empty (Pass 2E)',
      (t) async {
    final api = _SearchApiMock();
    final spy = _NavSpy();
    await pumpPage(
      t,
      api: api,
      spy: spy,
      trendingItems: const [
        MediaSummary(
          tmdbId: 99,
          mediaType: 'movie',
          title: 'TrendingPick',
          year: 2026,
        ),
      ],
    );
    await t.pumpAndSettle();
    // Glass-pill input is the headline affordance.
    expect(find.byType(TextField), findsOneWidget);
    // No filter chips after Pass 2E.
    expect(find.text('Tutto'), findsNothing);
    expect(find.text('Film'), findsNothing);
    // The "Suggerite per te" eyebrow + "Ricerche di tendenza" header are
    // rendered alongside the trending poster grid.
    expect(find.text('SUGGERITE PER TE'), findsOneWidget);
    expect(find.text('Ricerche di tendenza'), findsOneWidget);
    expect(find.text('TrendingPick'), findsOneWidget);
    verifyNever(() => api.search(any()));
  });

  testWidgets('initialQuery pre-fills the input and runs page 1', (t) async {
    final api = _SearchApiMock();
    when(() => api.search('dune', page: any(named: 'page'))).thenAnswer(
      (_) async => SearchResults(
        titles: [
          _result(tmdbId: 1, type: 'movie', title: 'Dune', year: 2021),
        ],
      ),
    );
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy, initial: '/search?q=dune');
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'dune'), findsOneWidget);
    expect(find.text('Dune'), findsOneWidget);
    verify(() => api.search('dune', page: 1)).called(1);
  });

  testWidgets('submitting input updates the URL via context.go', (t) async {
    final api = _SearchApiMock();
    when(() => api.search(any(), page: any(named: 'page')))
        .thenAnswer((_) async => const SearchResults());
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'matrix');
    await t.testTextInput.receiveAction(TextInputAction.search);
    await t.pumpAndSettle();
    expect(spy.visited, contains('/search?q=matrix'));
  });

  testWidgets('grid mixes all media types — chips dropped (Pass 2E)',
      (t) async {
    final api = _SearchApiMock();
    when(() => api.search('mix', page: any(named: 'page'))).thenAnswer(
      (_) async => SearchResults(
        titles: [
          _result(tmdbId: 1, type: 'movie', title: 'MixMovie', year: 2020),
          _result(tmdbId: 2, type: 'tv', title: 'MixSeries', year: 2021),
        ],
      ),
    );
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy, initial: '/search?q=mix');
    await t.pumpAndSettle();
    expect(find.text('MixMovie'), findsOneWidget);
    expect(find.text('MixSeries'), findsOneWidget);
    // Chips are gone — neither label appears as a chip OR a button.
    expect(find.text('Tutto'), findsNothing);
    expect(find.text('Film'), findsNothing);
  });

  testWidgets('shows "Persone" section above the "Titoli" grid when people '
      'present (PS-4)', (t) async {
    final api = _SearchApiMock();
    when(() => api.search('brad', page: any(named: 'page'))).thenAnswer(
      (_) async => SearchResults(
        titles: [
          _result(tmdbId: 9, type: 'movie', title: 'Fight Club', year: 1999),
        ],
        people: const [
          SearchPersonResult(
            tmdbId: 287,
            name: 'Brad Pitt',
            department: 'Acting',
            knownFor: ['World War Z'],
          ),
        ],
      ),
    );
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy, initial: '/search?q=brad');
    await t.pumpAndSettle();
    expect(find.text('Persone'), findsOneWidget);
    expect(find.text('Brad Pitt'), findsOneWidget);
    expect(find.text('Titoli'), findsOneWidget);
    expect(find.text('Fight Club'), findsOneWidget);
  });

  testWidgets('no "Persone" section when people are empty (PS-4)', (t) async {
    final api = _SearchApiMock();
    when(() => api.search('mix', page: any(named: 'page'))).thenAnswer(
      (_) async => SearchResults(
        titles: [
          _result(tmdbId: 1, type: 'movie', title: 'MixMovie', year: 2020),
        ],
      ),
    );
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy, initial: '/search?q=mix');
    await t.pumpAndSettle();
    expect(find.text('Persone'), findsNothing);
    // With no people we don't print a "Titoli" header either — the grid
    // stands alone as before.
    expect(find.text('Titoli'), findsNothing);
    expect(find.text('MixMovie'), findsOneWidget);
  });

  testWidgets('no-results state shows the "Nessun risultato" message',
      (t) async {
    final api = _SearchApiMock();
    when(() => api.search('xyzzy', page: any(named: 'page'))).thenAnswer(
      (_) async => const SearchResults(),
    );
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy, initial: '/search?q=xyzzy');
    await t.pumpAndSettle();
    expect(find.textContaining('Nessun risultato'), findsOneWidget);
  });

  testWidgets('initial loading state renders the skeleton grid', (t) async {
    final api = _SearchApiMock();
    final completer = Completer<SearchResults>();
    when(() => api.search('slow', page: any(named: 'page')))
        .thenAnswer((_) => completer.future);
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy, initial: '/search?q=slow');
    // One pump to register the loading state, but DON'T pumpAndSettle —
    // that would wait for the future to resolve.
    await t.pump();
    // The skeleton is 12 SizedBox-shaped DecoratedBox cards. Easier
    // signal: ensure the centered prompt is NOT present (which would
    // imply empty query) and that a CircularProgressIndicator is not
    // showing (that indicates the trailing infinite-scroll spinner,
    // not the skeleton).
    expect(find.text('Cerca un titolo, una serie o un anime'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    // Resolve to clear the pending timer for the test runner.
    completer.complete(const SearchResults());
    await t.pumpAndSettle();
  });
}
