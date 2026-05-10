// lib/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'presentation/pages/home_page.dart';
import 'presentation/pages/library_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/plugin_onboarding_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/plugins_page.dart';
import 'presentation/pages/search_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/title_page.dart';
import 'presentation/pages/watch_placeholder_page.dart';
import 'presentation/widgets/authenticated_shell.dart';
import 'state/auth_provider.dart';
import 'state/github_token_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final token = ref.read(githubTokenProvider).value;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register';
      final isOnboarding = loc == '/onboarding/github';

      if (auth is AuthLoading) return null;
      if (auth is AuthUnauthenticated || auth is AuthError) {
        return isAuthRoute ? null : '/login';
      }
      if (auth is AuthAuthenticated) {
        // Authenticated but no token yet → onboarding wizard.
        if ((token == null || token.isEmpty) && !isOnboarding) {
          return '/onboarding/github';
        }
        // Authenticated with token → leave login/register, send to home.
        if (isAuthRoute) return '/home';
        // Authenticated and at /onboarding/github but token now exists → home.
        if (isOnboarding && token != null && token.isNotEmpty) return '/home';
      }
      return null;
    },
    refreshListenable: _RouterRefreshNotifier(ref),
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(
        path: '/onboarding/github',
        builder: (_, __) => const PluginOnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AuthenticatedShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(path: '/library', builder: (_, __) => const LibraryPage()),
          GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/plugins', builder: (_, __) => const PluginsPage()),
          GoRoute(
            path: '/title/:tmdbId',
            builder: (ctx, state) => TitlePage(
              tmdbId: int.parse(state.pathParameters['tmdbId']!),
              mediaType: state.uri.queryParameters['media_type'] ?? 'movie',
            ),
          ),
          GoRoute(
            path: '/watch/:tmdbId',
            builder: (ctx, state) => WatchPlaceholderPage(
              tmdbId: int.parse(state.pathParameters['tmdbId']!),
              mediaType: state.uri.queryParameters['media_type'] ?? 'movie',
              season: int.tryParse(
                  state.uri.queryParameters['season'] ?? ''),
              episode: int.tryParse(
                  state.uri.queryParameters['episode'] ?? ''),
            ),
          ),
        ],
      ),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
    ref.listen<AsyncValue<String?>>(
      githubTokenProvider, (_, __) => notifyListeners(),
    );
  }
}
