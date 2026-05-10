// test/pages/plugin_onboarding_page_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/secure/secure_storage.dart';
import 'package:streamload_client/domain/models/user.dart';
import 'package:streamload_client/plugins/github_oauth.dart';
import 'package:streamload_client/presentation/pages/plugin_onboarding_page.dart';
import 'package:streamload_client/presentation/theme/theme.dart';
import 'package:streamload_client/state/auth_provider.dart';
import 'package:streamload_client/state/github_token_provider.dart';
import 'package:streamload_client/state/plugins_provider.dart';
import 'package:streamload_client/plugins/loader.dart';

class _StorageMock extends Mock implements SecureStorage {}

class _OAuthMock extends Mock implements GithubOAuth {}

class _FakeRef extends Fake implements Ref {}

/// A no-op PluginRefreshController so tests don't need the full plugin stack.
class _StubRefreshController extends PluginRefreshController {
  _StubRefreshController() : super(_FakeRef()) {
    state = AsyncData(RefreshSummary.notRun());
  }

  @override
  Future<void> refresh() async {
    // no-op in tests
  }
}

/// AuthNotifier stub that returns a fixed User from loginWithGithub.
class _StubAuthNotifier extends AuthNotifier {
  _StubAuthNotifier(this._returnUser) : super(_FakeRefForAuth());

  final User _returnUser;

  @override
  Future<User> loginWithGithub(String accessToken) async {
    state = AuthAuthenticated(_returnUser);
    return _returnUser;
  }
}

class _FakeRefForAuth extends Fake implements Ref {
  // AuthNotifier constructor takes Ref but we override loginWithGithub entirely.
}

const _fakeDevice = DeviceCodeRequest(
  deviceCode: 'dev-code-123',
  userCode: 'ABCD-1234',
  verificationUri: 'https://github.com/login/device',
  expiresIn: Duration(seconds: 900),
  pollInterval: Duration(milliseconds: 10),
);

const _userProfileIncomplete = User(
  id: 'u1',
  username: 'newuser',
  email: 'new@example.com',
  emailVerified: true,
  profileComplete: false,
);

const _userProfileComplete = User(
  id: 'u1',
  username: 'returning',
  email: 'ret@example.com',
  emailVerified: true,
  profileComplete: true,
);

/// Build a GoRouter-backed app so context.go('/...') succeeds.
Widget buildApp({
  required SecureStorage storage,
  required GithubOAuth mockOauth,
  User returnUser = _userProfileIncomplete,
  List<GoRoute> extraRoutes = const [],
}) {
  final defaultExtraRoutes = [
    GoRoute(
      path: '/home',
      builder: (_, __) => const Scaffold(body: Text('Home')),
    ),
    GoRoute(
      path: '/onboarding/profile',
      builder: (_, __) => const Scaffold(body: Text('ProfileCompletion')),
    ),
  ];
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) =>
            PluginOnboardingPage(oauthFactory: () => mockOauth),
      ),
      ...defaultExtraRoutes,
      ...extraRoutes,
    ],
  );
  return ProviderScope(
    overrides: [
      secureStorageProvider.overrideWithValue(storage),
      pluginRefreshControllerProvider.overrideWith(
        (_) => _StubRefreshController(),
      ),
      authProvider.overrideWith(
        (_) => _StubAuthNotifier(returnUser),
      ),
    ],
    child: MaterialApp.router(
      theme: streamloadTheme(),
      routerConfig: router,
    ),
  );
}

/// Simple widget without GoRouter for tests that don't trigger navigation.
Widget buildSimplePage({
  required SecureStorage storage,
  required GithubOAuth mockOauth,
}) {
  return ProviderScope(
    overrides: [
      secureStorageProvider.overrideWithValue(storage),
      pluginRefreshControllerProvider.overrideWith(
        (_) => _StubRefreshController(),
      ),
    ],
    child: MaterialApp(
      theme: streamloadTheme(),
      home: PluginOnboardingPage(oauthFactory: () => mockOauth),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(Duration.zero);
  });

  testWidgets('idle state shows Accedi con GitHub button', (tester) async {
    final storage = _StorageMock();
    final oauth = _OAuthMock();
    when(storage.githubToken).thenAnswer((_) async => null);

    await tester.pumpWidget(
        buildSimplePage(storage: storage, mockOauth: oauth));
    await tester.pump();

    expect(find.byKey(const Key('onboarding.github_login')), findsOneWidget);
    expect(find.text('Accedi con GitHub'), findsWidgets);
  });

  testWidgets('tap login button shows user_code after requestDeviceCode',
      (tester) async {
    final storage = _StorageMock();
    final oauth = _OAuthMock();
    when(storage.githubToken).thenAnswer((_) async => null);
    // requestDeviceCode returns the fake device immediately.
    when(() => oauth.requestDeviceCode()).thenAnswer((_) async => _fakeDevice);
    // pollForToken never resolves in this test.
    final pollCompleter = Completer<String>();
    when(() => oauth.pollForToken(
          deviceCode: any(named: 'deviceCode'),
          interval: any(named: 'interval'),
          timeout: any(named: 'timeout'),
        )).thenAnswer((_) => pollCompleter.future);

    await tester.pumpWidget(
        buildSimplePage(storage: storage, mockOauth: oauth));
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('onboarding.github_login')));
      // Let requestDeviceCode complete.
      await Future<void>.delayed(Duration.zero);
    });
    // Rebuild the widget tree to reflect state changes.
    await tester.pump();
    await tester.pump();

    // The user code should be displayed.
    expect(find.text('ABCD-1234'), findsOneWidget);
    verify(() => oauth.requestDeviceCode()).called(1);
  });

  testWidgets('successful polling saves token and routes to /onboarding/profile for incomplete profile',
      (tester) async {
    final storage = _StorageMock();
    final oauth = _OAuthMock();
    when(storage.githubToken).thenAnswer((_) async => null);
    when(() => storage.setGithubToken(any())).thenAnswer((_) async {});
    when(() => oauth.requestDeviceCode()).thenAnswer((_) async => _fakeDevice);
    when(() => oauth.pollForToken(
          deviceCode: any(named: 'deviceCode'),
          interval: any(named: 'interval'),
          timeout: any(named: 'timeout'),
        )).thenAnswer((_) async => 'ghu_test_token');

    await tester.pumpWidget(buildApp(
      storage: storage,
      mockOauth: oauth,
      returnUser: _userProfileIncomplete,
    ));
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('onboarding.github_login')));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    verify(() => storage.setGithubToken('ghu_test_token')).called(1);
    // Should have navigated to /onboarding/profile (profile incomplete)
    expect(find.text('ProfileCompletion'), findsOneWidget);
  });

  testWidgets('successful polling routes to /home for complete profile',
      (tester) async {
    final storage = _StorageMock();
    final oauth = _OAuthMock();
    when(storage.githubToken).thenAnswer((_) async => null);
    when(() => storage.setGithubToken(any())).thenAnswer((_) async {});
    when(() => oauth.requestDeviceCode()).thenAnswer((_) async => _fakeDevice);
    when(() => oauth.pollForToken(
          deviceCode: any(named: 'deviceCode'),
          interval: any(named: 'interval'),
          timeout: any(named: 'timeout'),
        )).thenAnswer((_) async => 'ghu_returning_token');

    await tester.pumpWidget(buildApp(
      storage: storage,
      mockOauth: oauth,
      returnUser: _userProfileComplete,
    ));
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('onboarding.github_login')));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    verify(() => storage.setGithubToken('ghu_returning_token')).called(1);
    // Should have navigated to /home (profile complete)
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('DeviceFlowDenied shows error message and Riprova button',
      (tester) async {
    final storage = _StorageMock();
    final oauth = _OAuthMock();
    when(storage.githubToken).thenAnswer((_) async => null);
    when(() => oauth.requestDeviceCode()).thenAnswer((_) async => _fakeDevice);
    when(() => oauth.pollForToken(
          deviceCode: any(named: 'deviceCode'),
          interval: any(named: 'interval'),
          timeout: any(named: 'timeout'),
        )).thenAnswer((_) async => throw const DeviceFlowDenied());

    await tester.pumpWidget(
        buildSimplePage(storage: storage, mockOauth: oauth));
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('onboarding.github_login')));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('annullato'), findsOneWidget);
    expect(find.byKey(const Key('onboarding.retry')), findsOneWidget);
  });

  testWidgets('copy button is present when code is displayed', (tester) async {
    final storage = _StorageMock();
    final oauth = _OAuthMock();
    when(storage.githubToken).thenAnswer((_) async => null);
    when(() => oauth.requestDeviceCode()).thenAnswer((_) async => _fakeDevice);
    final pollCompleter = Completer<String>();
    when(() => oauth.pollForToken(
          deviceCode: any(named: 'deviceCode'),
          interval: any(named: 'interval'),
          timeout: any(named: 'timeout'),
        )).thenAnswer((_) => pollCompleter.future);

    await tester.pumpWidget(
        buildSimplePage(storage: storage, mockOauth: oauth));
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('onboarding.github_login')));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
    await tester.pump();

    // The user_code and copy button should both be visible.
    expect(find.text('ABCD-1234'), findsOneWidget);
    expect(find.byKey(const Key('onboarding.copy_code')), findsOneWidget);
  });
}
