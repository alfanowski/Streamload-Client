// test/widgets/bottom_tab_bar_test.dart
//
// Phase B3 — StreamloadBottomTabBar renders 4 tabs (Home / Cerca / La mia
// lista / Profilo); each tap navigates to its path; the active tab uses
// v3TextPrimary (warm off-white, CM-2) while inactive use v3TextMuted.
// The Pass 2A yellow tint was dropped in the Cinema Magazine pivot.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:streamload_client/presentation/theme/colors.dart';
import 'package:streamload_client/presentation/widgets/bottom_tab_bar.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester t, {
    required String initial,
  }) async {
    // Phone-sized surface; the bar targets phone only.
    await t.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: initial,
      routes: [
        for (final p in const ['/home', '/search', '/list', '/profile'])
          GoRoute(
            path: p,
            builder: (_, __) => Scaffold(
              body: Center(child: Text('page:$p')),
              bottomNavigationBar: const StreamloadBottomTabBar(),
            ),
          ),
      ],
    );
    await t.pumpWidget(ProviderScope(
      child: MaterialApp.router(routerConfig: router),
    ));
  }

  testWidgets('renders 4 tabs with icons and labels', (t) async {
    await pumpBar(t, initial: '/home');
    await t.pump();

    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Cerca'), findsOneWidget);
    expect(find.text('Lista'), findsOneWidget);
    expect(find.text('Profilo'), findsOneWidget);
  });

  testWidgets('tapping a tab routes to its path', (t) async {
    await pumpBar(t, initial: '/home');
    await t.pump();
    expect(find.text('page:/home'), findsOneWidget);

    await t.tap(find.text('Cerca'));
    await t.pumpAndSettle();
    expect(find.text('page:/search'), findsOneWidget);

    await t.tap(find.text('Lista'));
    await t.pumpAndSettle();
    expect(find.text('page:/list'), findsOneWidget);

    await t.tap(find.text('Profilo'));
    await t.pumpAndSettle();
    expect(find.text('page:/profile'), findsOneWidget);
  });

  testWidgets('active tab uses v3TextPrimary, others use v3TextMuted',
      (t) async {
    await pumpBar(t, initial: '/search');
    await t.pump();

    final searchIcon = t.widget<Icon>(find.byIcon(Icons.search));
    final homeIcon = t.widget<Icon>(find.byIcon(Icons.home_outlined));

    expect(searchIcon.color, StreamloadColors.v3TextPrimary);
    expect(homeIcon.color, StreamloadColors.v3TextMuted);
  });
}
