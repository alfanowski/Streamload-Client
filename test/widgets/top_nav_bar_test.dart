// test/widgets/top_nav_bar_test.dart
//
// Phase B1 — TopNavBar renders the 5 tabs + logo + search; tapping a tab
// navigates the GoRouter to the right path; flipping navScrolledProvider
// switches the background color via AnimatedContainer.
//
// Phase G1 (2026-05-16) updated the search button to open the SearchOverlay
// on desktop / tablet instead of navigating to /search. The phone branch
// (when this widget would hypothetically render under 600 px wide) still
// navigates to /search, but since the AppShell only mounts TopNavBar on
// desktop / tablet, the overlay path is the realistic test.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:streamload_client/data/remote/endpoints/search_api.dart';
import 'package:streamload_client/domain/models/search_results.dart';
import 'package:streamload_client/presentation/widgets/search_overlay.dart';
import 'package:streamload_client/presentation/widgets/top_nav_bar.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/nav_scrolled_provider.dart';

class _SearchApiStub implements SearchApi {
  @override
  Future<Map<String, dynamic>> run(String query, {int page = 1}) async =>
      {'results': []};

  @override
  Future<SearchResults> search(String query, {int page = 1}) async =>
      const SearchResults();
}

void main() {
  Future<void> pumpWith(
    WidgetTester t, {
    required String initial,
    ProviderContainer? container,
  }) async {
    // Widget targets desktop / tablet; resize the test view so the 5 tabs +
    // spacer + search + avatar fit without overflowing.
    await t.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: initial,
      routes: [
        for (final p in const [
          '/home',
          '/film',
          '/serie',
          '/anime',
          '/list',
          '/search',
          '/profile',
        ])
          GoRoute(
            path: p,
            builder: (_, __) => Scaffold(
              body: Column(
                children: [
                  const TopNavBar(),
                  Text('page:$p'),
                ],
              ),
            ),
          ),
      ],
    );
    await t.pumpWidget(UncontrolledProviderScope(
      container: container ??
          ProviderContainer(overrides: [
            searchApiProvider.overrideWith((_) async => _SearchApiStub()),
          ]),
      child: MaterialApp.router(routerConfig: router),
    ));
  }

  testWidgets('renders logo + 5 tabs + search', (t) async {
    await pumpWith(t, initial: '/home');
    await t.pump();

    expect(find.text('Streamload'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Film'), findsOneWidget);
    expect(find.text('Serie TV'), findsOneWidget);
    expect(find.text('Anime'), findsOneWidget);
    expect(find.text('La mia lista'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('tapping a tab navigates to that route', (t) async {
    await pumpWith(t, initial: '/home');
    await t.pump();

    expect(find.text('page:/home'), findsOneWidget);

    await t.tap(find.text('Film'));
    await t.pumpAndSettle();
    expect(find.text('page:/film'), findsOneWidget);

    await t.tap(find.text('Serie TV'));
    await t.pumpAndSettle();
    expect(find.text('page:/serie'), findsOneWidget);

    await t.tap(find.text('Anime'));
    await t.pumpAndSettle();
    expect(find.text('page:/anime'), findsOneWidget);

    await t.tap(find.text('La mia lista'));
    await t.pumpAndSettle();
    expect(find.text('page:/list'), findsOneWidget);
  });

  testWidgets('tapping search opens the SearchOverlay on desktop',
      (t) async {
    await pumpWith(t, initial: '/home');
    await t.pump();

    expect(find.byType(SearchOverlay), findsNothing);
    await t.tap(find.byIcon(Icons.search));
    // Pump past the showGeneralDialog transition.
    await t.pump();
    await t.pump(const Duration(milliseconds: 250));
    expect(find.byType(SearchOverlay), findsOneWidget);
    // Original page is still mounted under the overlay.
    expect(find.text('page:/home'), findsOneWidget);
  });

  testWidgets('survives a navScrolled flip (glass bar deepens, no crash)',
      (t) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpWith(t, initial: '/home', container: container);
    await t.pump();

    // 2026-05-29 (UI refactor): the nav is now a liquid-glass bar whose
    // tint deepens on scroll (no opaque AnimatedContainer to assert). We
    // verify the scroll flip rebuilds the bar cleanly and the chrome
    // stays present.
    expect(find.text('Streamload'), findsOneWidget);
    container.read(navScrolledProvider.notifier).state = true;
    await t.pumpAndSettle();
    expect(find.text('Streamload'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
