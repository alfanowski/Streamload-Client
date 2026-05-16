// test/widgets/top_nav_bar_test.dart
//
// Phase B1 — TopNavBar renders the 5 tabs + logo + search; tapping a tab
// navigates the GoRouter to the right path; flipping navScrolledProvider
// switches the background color via AnimatedContainer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:streamload_client/presentation/theme/colors.dart';
import 'package:streamload_client/presentation/widgets/top_nav_bar.dart';
import 'package:streamload_client/state/nav_scrolled_provider.dart';

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
      container: container ?? ProviderContainer(),
      child: MaterialApp.router(routerConfig: router),
    ));
  }

  testWidgets('renders logo + 5 tabs + search', (t) async {
    await pumpWith(t, initial: '/home');
    await t.pump();

    expect(find.text('STREAMLOAD'), findsOneWidget);
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

  testWidgets('tapping search navigates to /search', (t) async {
    await pumpWith(t, initial: '/home');
    await t.pump();

    await t.tap(find.byIcon(Icons.search));
    await t.pumpAndSettle();
    expect(find.text('page:/search'), findsOneWidget);
  });

  testWidgets('background animates from glass to solid when scrolled flips',
      (t) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpWith(t, initial: '/home', container: container);
    await t.pump();

    Color findBg() {
      final ac = t.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      return (ac.decoration as BoxDecoration).color!;
    }

    final initial = findBg();
    // Glass starts translucent.
    expect(initial.a, lessThan(1.0));
    expect(initial, equals(
      StreamloadColors.v3BgScrolled.withValues(alpha: 0.85),
    ));

    container.read(navScrolledProvider.notifier).state = true;
    await t.pumpAndSettle();

    final after = findBg();
    expect(after, equals(StreamloadColors.v3BgScrolled));
  });
}
