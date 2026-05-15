// lib/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'presentation/pages/home_page.dart';
import 'presentation/pages/library_page.dart';
import 'presentation/pages/plugin_onboarding_page.dart';
import 'presentation/pages/profile_completion_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/plugins_page.dart';
import 'presentation/pages/search_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/title_page.dart';
import 'presentation/pages/watch_page.dart';
import 'presentation/widgets/authenticated_shell.dart';
import 'domain/models/playback_request.dart';
import 'state/auth_provider.dart';
import 'state/github_token_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding/github',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final token = ref.read(githubTokenProvider).value;
      final loc = state.matchedLocation;
      final isOnboardingGithub = loc == '/onboarding/github';
      final isOnboardingProfile = loc == '/onboarding/profile';

      // No token at all → must do GitHub login first.
      if (token == null || token.isEmpty) {
        return isOnboardingGithub ? null : '/onboarding/github';
      }

      // Have token but no backend session yet → onboarding/github will
      // call loginWithGithub on submit; once authenticated this fires again.
      if (auth is! AuthAuthenticated) {
        if (auth is AuthLoading) return null;
        // AuthError or Unauthenticated with a token present — let
        // /onboarding/github surface the issue and the user can retry.
        return isOnboardingGithub ? null : '/onboarding/github';
      }

      // Authenticated. Check profile.
      if (!auth.user.profileComplete) {
        return isOnboardingProfile ? null : '/onboarding/profile';
      }

      // Fully ready — bounce out of onboarding pages.
      if (isOnboardingGithub || isOnboardingProfile) return '/home';
      return null;
    },
    refreshListenable: _RouterRefreshNotifier(ref),
    routes: [
      GoRoute(
        path: '/onboarding/github',
        builder: (_, __) => const PluginOnboardingPage(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        builder: (_, __) => const ProfileCompletionPage(),
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
            builder: (ctx, state) => WatchPage(
              request: PlaybackRequest(
                tmdbId: int.parse(state.pathParameters['tmdbId']!),
                mediaType:
                    state.uri.queryParameters['media_type'] ?? 'movie',
                season: int.tryParse(
                    state.uri.queryParameters['season'] ?? ''),
                episode: int.tryParse(
                    state.uri.queryParameters['episode'] ?? ''),
              ),
              // TEMP DIAGNOSTIC — toggle to false once we confirm whether
              // playback failures are in our proxy chain or in media_kit.
              debugBypassProxy: true,
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
      githubTokenProvider,
      (_, __) => notifyListeners(),
    );
  }
}
