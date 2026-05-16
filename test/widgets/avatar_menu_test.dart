// test/widgets/avatar_menu_test.dart
//
// Phase B2 — AvatarMenu renders a small circular avatar that opens a popup
// menu with the user header + Impostazioni + Esci entries; Impostazioni
// routes to /settings; Esci calls authNotifier.logout(); the header shows
// firstName+lastName when set and falls back to username otherwise.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:streamload_client/domain/models/user.dart';
import 'package:streamload_client/presentation/widgets/avatar_menu.dart';
import 'package:streamload_client/state/auth_provider.dart';

class _PreAuthedNotifier extends AuthNotifier {
  _PreAuthedNotifier(super.ref, User initialUser) {
    state = AuthAuthenticated(initialUser);
  }

  int logoutCalls = 0;
  @override
  Future<void> logout() async {
    logoutCalls += 1;
    state = const AuthUnauthenticated();
  }
}

const _userWithName = User(
  id: 'u',
  username: 'aalfano',
  email: 'a@b.com',
  emailVerified: true,
  firstName: 'Andrea',
  lastName: 'Alfano',
  profileComplete: true,
);

const _userWithoutName = User(
  id: 'u',
  username: 'aalfano',
  email: 'a@b.com',
  emailVerified: true,
  profileComplete: true,
);

Widget _wrap(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, __) => const Scaffold(
          body: Padding(padding: EdgeInsets.all(48), child: AvatarMenu()),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const Scaffold(body: Text('page:/settings')),
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

ProviderContainer _containerFor(User user) {
  return ProviderContainer(overrides: [
    authProvider.overrideWith((ref) => _PreAuthedNotifier(ref, user)),
  ]);
}

void main() {
  testWidgets('opens menu with header, Impostazioni, Esci on tap',
      (t) async {
    final c = _containerFor(_userWithName);
    addTearDown(c.dispose);

    await t.pumpWidget(_wrap(c));
    await t.pump();

    expect(find.byType(AvatarMenu), findsOneWidget);
    await t.tap(find.byType(AvatarMenu));
    await t.pumpAndSettle();

    expect(find.text('Andrea Alfano'), findsOneWidget);
    expect(find.text('a@b.com'), findsOneWidget);
    expect(find.text('Impostazioni'), findsOneWidget);
    expect(find.text('Esci'), findsOneWidget);
  });

  testWidgets('falls back to username when first/last name missing',
      (t) async {
    final c = _containerFor(_userWithoutName);
    addTearDown(c.dispose);

    await t.pumpWidget(_wrap(c));
    await t.pump();

    await t.tap(find.byType(AvatarMenu));
    await t.pumpAndSettle();

    expect(find.text('aalfano'), findsOneWidget);
    expect(find.text('a@b.com'), findsOneWidget);
  });

  testWidgets('tapping Impostazioni routes to /settings', (t) async {
    final c = _containerFor(_userWithName);
    addTearDown(c.dispose);

    await t.pumpWidget(_wrap(c));
    await t.pump();

    await t.tap(find.byType(AvatarMenu));
    await t.pumpAndSettle();

    await t.tap(find.text('Impostazioni'));
    await t.pumpAndSettle();

    expect(find.text('page:/settings'), findsOneWidget);
  });

  testWidgets('tapping Esci calls authNotifier.logout', (t) async {
    final c = _containerFor(_userWithName);
    addTearDown(c.dispose);

    // Force the notifier to materialize so we can read it back as the
    // _PreAuthedNotifier subclass.
    c.read(authProvider);
    final notifier = c.read(authProvider.notifier) as _PreAuthedNotifier;

    await t.pumpWidget(_wrap(c));
    await t.pump();

    await t.tap(find.byType(AvatarMenu));
    await t.pumpAndSettle();

    expect(notifier.logoutCalls, 0);
    await t.tap(find.text('Esci'));
    await t.pumpAndSettle();
    expect(notifier.logoutCalls, 1);
  });
}
