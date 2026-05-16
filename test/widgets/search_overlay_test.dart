// test/widgets/search_overlay_test.dart
//
// Phase G1 — SearchOverlay renders empty input with no suggestions,
// debounces typing (200ms), shows top-5 suggestions from a mocked search
// API, dispatches on row tap + on "Mostra tutti", and closes on Esc.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:streamload_client/data/remote/endpoints/search_api.dart';
import 'package:streamload_client/presentation/widgets/search_overlay.dart';
import 'package:streamload_client/state/api_client_provider.dart';

class _SearchApiMock extends Mock implements SearchApi {}

/// Spies on context.go destinations so we can assert navigation without
/// rendering the actual target pages.
class _NavSpy {
  final List<String> visited = [];
}

// ignore: library_private_types_in_public_api
GoRouter _router(_NavSpy spy, Widget Function() opener) {
  return GoRouter(
    initialLocation: '/host',
    routes: [
      GoRoute(
        path: '/host',
        builder: (_, __) => Scaffold(body: opener()),
      ),
      GoRoute(
        path: '/title/:id',
        builder: (_, state) {
          spy.visited.add(
            '/title/${state.pathParameters['id']}?'
            'media_type=${state.uri.queryParameters['media_type']}',
          );
          return const Scaffold(body: Text('title-page'));
        },
      ),
      GoRoute(
        path: '/search',
        builder: (_, state) {
          spy.visited.add(
            '/search?q=${state.uri.queryParameters['q'] ?? ''}',
          );
          return const Scaffold(body: Text('search-page'));
        },
      ),
    ],
  );
}

Future<void> pumpOverlayHost(
  WidgetTester t, {
  required SearchApi api,
  required _NavSpy spy,
}) async {
  await t.binding.setSurfaceSize(const Size(1400, 900));
  addTearDown(() => t.binding.setSurfaceSize(null));

  late BuildContext capturedCtx;
  final router = _router(spy, () => Builder(builder: (ctx) {
        capturedCtx = ctx;
        return const Center(child: Text('host'));
      }));

  await t.pumpWidget(ProviderScope(
    overrides: [searchApiProvider.overrideWith((_) async => api)],
    child: MaterialApp.router(routerConfig: router),
  ));
  await t.pump();

  // ignore: use_build_context_synchronously
  SearchOverlay.show(capturedCtx);
  // Pump past the showGeneralDialog transition (180ms) so the overlay
  // is fully present and its initState/focus requests have run.
  await t.pump();
  await t.pump(const Duration(milliseconds: 250));
}

void main() {
  testWidgets('renders with empty input and no suggestions', (t) async {
    final api = _SearchApiMock();
    final spy = _NavSpy();
    await pumpOverlayHost(t, api: api, spy: spy);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Cerca un titolo…'), findsOneWidget);
    // No query → suggestions list is not built, so no "Mostra tutti".
    expect(find.text('Mostra tutti i risultati →'), findsNothing);
    verifyNever(() => api.run(any()));
  });

  testWidgets('typing triggers a debounced search after 200ms', (t) async {
    final api = _SearchApiMock();
    when(() => api.run('dune')).thenAnswer((_) async => {
          'results': [
            {
              'tmdb_id': 1,
              'media_type': 'movie',
              'title': 'Dune',
              'year': 2021,
              'poster_url': null,
            }
          ],
        });
    final spy = _NavSpy();
    await pumpOverlayHost(t, api: api, spy: spy);

    await t.enterText(find.byType(TextField), 'dune');
    // Before the debounce fires, no API call yet.
    await t.pump(const Duration(milliseconds: 50));
    verifyNever(() => api.run(any()));

    // Pump past the 200ms debounce → API resolves → suggestion appears.
    await t.pump(const Duration(milliseconds: 250));
    await t.pumpAndSettle();
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Film · 2021'), findsOneWidget);
    expect(find.text('Mostra tutti i risultati →'), findsOneWidget);
    verify(() => api.run('dune')).called(1);
  });

  testWidgets('tapping a suggestion pops the overlay and navigates to /title',
      (t) async {
    final api = _SearchApiMock();
    when(() => api.run('dune')).thenAnswer((_) async => {
          'results': [
            {
              'tmdb_id': 42,
              'media_type': 'movie',
              'title': 'Dune',
              'year': 2021,
              'poster_url': null,
            }
          ],
        });
    final spy = _NavSpy();
    await pumpOverlayHost(t, api: api, spy: spy);

    await t.enterText(find.byType(TextField), 'dune');
    await t.pump(const Duration(milliseconds: 250));
    await t.pumpAndSettle();
    await t.tap(find.text('Dune'));
    await t.pumpAndSettle();

    expect(spy.visited, contains('/title/42?media_type=movie'));
    // Overlay is gone (search-page route is /search, not the title page,
    // so we just check that the input field is no longer rendered).
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('"Mostra tutti" navigates to /search?q=<query>', (t) async {
    final api = _SearchApiMock();
    when(() => api.run('inter')).thenAnswer((_) async => {
          'results': [
            {
              'tmdb_id': 1,
              'media_type': 'movie',
              'title': 'Interstellar',
              'year': 2014,
              'poster_url': null,
            }
          ],
        });
    final spy = _NavSpy();
    await pumpOverlayHost(t, api: api, spy: spy);

    await t.enterText(find.byType(TextField), 'inter');
    await t.pump(const Duration(milliseconds: 250));
    await t.pumpAndSettle();

    await t.tap(find.text('Mostra tutti i risultati →'));
    await t.pumpAndSettle();
    expect(spy.visited, contains('/search?q=inter'));
  });

  testWidgets('Esc key closes the overlay', (t) async {
    final api = _SearchApiMock();
    final spy = _NavSpy();
    await pumpOverlayHost(t, api: api, spy: spy);

    expect(find.byType(TextField), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('tapping outside the input panel closes the overlay',
      (t) async {
    final api = _SearchApiMock();
    final spy = _NavSpy();
    await pumpOverlayHost(t, api: api, spy: spy);

    // Tap near the bottom-left where the backdrop catches it (well below
    // the input column, which is pinned to the top-center).
    await t.tapAt(const Offset(40, 800));
    await t.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
  });
}
