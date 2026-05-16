// test/widgets/app_shell_test.dart
//
// Phase B4 — AppShell branches on Responsive.isPhone. Phone width gets a
// StreamloadBottomTabBar (no top bar); desktop width gets a stacked
// TopNavBar floating over the body. Also smoke-tests that the router's
// new routes (/film, /serie, /anime, /list) resolve through the shell.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:streamload_client/presentation/widgets/app_shell.dart';
import 'package:streamload_client/presentation/widgets/bottom_tab_bar.dart';
import 'package:streamload_client/presentation/widgets/top_nav_bar.dart';
import 'package:streamload_client/state/auth_provider.dart';
import 'package:streamload_client/domain/models/user.dart';

class _PreAuthedNotifier extends AuthNotifier {
  _PreAuthedNotifier(super.ref, User user) {
    state = AuthAuthenticated(user);
  }
}

const _user = User(
  id: 'u',
  username: 'aalfano',
  email: 'a@b.com',
  emailVerified: true,
  profileComplete: true,
);

Future<void> pumpShell(
  WidgetTester t, {
  required Size surface,
  String initial = '/home',
}) async {
  // Both `setSurfaceSize` and `view.physicalSize` need to agree, otherwise
  // MediaQuery (read by Responsive.isPhone) keeps the 800×600 default and
  // the shell sees itself as desktop regardless of the surface we set.
  t.view.devicePixelRatio = 1.0;
  t.view.physicalSize = surface;
  await t.binding.setSurfaceSize(surface);
  addTearDown(() {
    t.view.resetPhysicalSize();
    t.view.resetDevicePixelRatio();
    t.binding.setSurfaceSize(null);
  });

  final router = GoRouter(
    initialLocation: initial,
    routes: [
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          for (final p in const [
            '/home',
            '/film',
            '/serie',
            '/anime',
            '/list',
            '/search',
            '/settings',
            '/profile',
          ])
            GoRoute(
              path: p,
              builder: (_, __) =>
                  Scaffold(body: Center(child: Text('body:$p'))),
            ),
        ],
      ),
    ],
  );

  await t.pumpWidget(ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) => _PreAuthedNotifier(ref, _user)),
    ],
    child: MaterialApp.router(routerConfig: router),
  ));
}

void main() {
  testWidgets('phone surface uses bottom tab bar, no top nav bar',
      (t) async {
    await pumpShell(t, surface: const Size(390, 844));
    await t.pump();

    final ctx = t.element(find.text('body:/home'));
    final mqW = MediaQuery.sizeOf(ctx).width;
    expect(mqW, lessThan(600.0),
        reason: 'MediaQuery width should be phone-sized but was $mqW');

    expect(find.byType(StreamloadBottomTabBar), findsOneWidget);
    expect(find.byType(TopNavBar), findsNothing);
    expect(find.text('body:/home'), findsOneWidget);
  });

  testWidgets('desktop surface uses top nav bar, no bottom tab bar',
      (t) async {
    await pumpShell(t, surface: const Size(1400, 900));
    await t.pump();

    expect(find.byType(TopNavBar), findsOneWidget);
    expect(find.byType(StreamloadBottomTabBar), findsNothing);
    expect(find.text('body:/home'), findsOneWidget);
  });

  testWidgets('tablet surface uses top nav bar (non-phone branch)',
      (t) async {
    await pumpShell(t, surface: const Size(750, 1024));
    await t.pump();

    expect(find.byType(TopNavBar), findsOneWidget);
    expect(find.byType(StreamloadBottomTabBar), findsNothing);
  });

  testWidgets('Phase B routes /film /serie /anime /list resolve through shell',
      (t) async {
    for (final p in const ['/film', '/serie', '/anime', '/list']) {
      await pumpShell(t, surface: const Size(1400, 900), initial: p);
      await t.pump();
      expect(find.text('body:$p'), findsOneWidget, reason: 'route $p');
    }
  });
}
