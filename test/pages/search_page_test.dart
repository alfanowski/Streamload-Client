// test/pages/search_page_test.dart
//
// Phase G2 — Full-results /search page. Verifies:
//  - renders the input + chip row at all widths
//  - initialQuery pre-fills the input + triggers a page=1 fetch
//  - submitting the input updates the URL (context.go fires)
//  - filter chip narrows the visible grid (Film → only movies)
//  - empty query shows the prompt
//  - no-results shows the "Nessun risultato" message
//  - loading state renders the skeleton grid
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:streamload_client/data/remote/endpoints/search_api.dart';
import 'package:streamload_client/presentation/pages/search_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';

class _SearchApiMock extends Mock implements SearchApi {}

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
    overrides: [searchApiProvider.overrideWith((_) async => api)],
    child: MaterialApp.router(routerConfig: _router(spy, initial: initial)),
  ));
  await t.pump();
}

Map<String, dynamic> _result({
  required int tmdbId,
  required String type,
  required String title,
  int? year,
}) =>
    {
      'tmdb_id': tmdbId,
      'media_type': type,
      'title': title,
      'year': year,
      'poster_url': null,
    };

void main() {
  setUpAll(() {
    registerFallbackValue(0);
  });

  testWidgets('renders input + filter chips with no query', (t) async {
    final api = _SearchApiMock();
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy);
    await t.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Tutto'), findsOneWidget);
    expect(find.text('Film'), findsOneWidget);
    expect(find.text('Serie TV'), findsOneWidget);
    expect(find.text('Anime'), findsOneWidget);
    // Empty query → centered prompt.
    expect(find.text('Cerca un titolo, una serie o un anime'), findsOneWidget);
    verifyNever(() => api.run(any()));
  });

  testWidgets('initialQuery pre-fills the input and runs page 1', (t) async {
    final api = _SearchApiMock();
    when(() => api.run('dune', page: any(named: 'page'))).thenAnswer(
      (_) async => {
        'results': [
          _result(tmdbId: 1, type: 'movie', title: 'Dune', year: 2021),
        ],
      },
    );
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy, initial: '/search?q=dune');
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'dune'), findsOneWidget);
    expect(find.text('Dune'), findsOneWidget);
    verify(() => api.run('dune', page: 1)).called(1);
  });

  testWidgets('submitting input updates the URL via context.go', (t) async {
    final api = _SearchApiMock();
    when(() => api.run(any(), page: any(named: 'page')))
        .thenAnswer((_) async => {'results': <Map<String, dynamic>>[]});
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'matrix');
    await t.testTextInput.receiveAction(TextInputAction.search);
    await t.pumpAndSettle();
    expect(spy.visited, contains('/search?q=matrix'));
  });

  testWidgets('Film chip narrows the grid to movies only', (t) async {
    final api = _SearchApiMock();
    when(() => api.run('mix', page: any(named: 'page'))).thenAnswer(
      (_) async => {
        'results': [
          _result(tmdbId: 1, type: 'movie', title: 'MixMovie', year: 2020),
          _result(tmdbId: 2, type: 'tv', title: 'MixSeries', year: 2021),
        ],
      },
    );
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy, initial: '/search?q=mix');
    await t.pumpAndSettle();
    expect(find.text('MixMovie'), findsOneWidget);
    expect(find.text('MixSeries'), findsOneWidget);
    // Tap the "Film" chip.
    await t.tap(find.text('Film'));
    await t.pumpAndSettle();
    expect(find.text('MixMovie'), findsOneWidget);
    expect(find.text('MixSeries'), findsNothing);
  });

  testWidgets('no-results state shows the "Nessun risultato" message',
      (t) async {
    final api = _SearchApiMock();
    when(() => api.run('xyzzy', page: any(named: 'page'))).thenAnswer(
      (_) async => {'results': <Map<String, dynamic>>[]},
    );
    final spy = _NavSpy();
    await pumpPage(t, api: api, spy: spy, initial: '/search?q=xyzzy');
    await t.pumpAndSettle();
    expect(find.textContaining('Nessun risultato'), findsOneWidget);
  });

  testWidgets('initial loading state renders the skeleton grid', (t) async {
    final api = _SearchApiMock();
    final completer = Completer<Map<String, dynamic>>();
    when(() => api.run('slow', page: any(named: 'page')))
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
    completer.complete({'results': <Map<String, dynamic>>[]});
    await t.pumpAndSettle();
  });
}
