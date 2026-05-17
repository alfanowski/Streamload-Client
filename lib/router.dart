// lib/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'presentation/pages/home_page.dart';
import 'presentation/pages/library_page.dart';
import 'presentation/pages/plugin_onboarding_page.dart';
import 'presentation/pages/profile_completion_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/search_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/title_page.dart';
import 'presentation/pages/watch_page.dart';
import 'presentation/widgets/app_shell.dart';
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
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          _fadeRoute('/home', (_, __) => const HomePage()),
          // /film, /serie, /anime route to HomePage with a filter param
          // (sub-plan 8, Phase D5). HomePage narrows its row composition
          // to the matching subset; the filter chips below the hero let
          // the user switch without leaving Home.
          _fadeRoute('/film', (_, __) => const HomePage(filter: 'movie')),
          _fadeRoute('/serie', (_, __) => const HomePage(filter: 'tv')),
          _fadeRoute('/anime', (_, __) => const HomePage(filter: 'anime')),
          _fadeRoute('/list', (_, __) => const LibraryPage()),
          _fadeRoute('/library', (_, __) => const LibraryPage()),
          _fadeRoute('/search', (_, state) => SearchPage(
                initialQuery: state.uri.queryParameters['q'] ?? '',
              )),
          _fadeRoute('/profile', (_, __) => const ProfilePage()),
          _fadeRoute('/settings', (_, __) => const SettingsPage()),
          _fadeRoute('/title/:tmdbId', (ctx, state) => TitlePage(
                tmdbId: int.parse(state.pathParameters['tmdbId']!),
                mediaType: state.uri.queryParameters['media_type'] ?? 'movie',
              )),
          _fadeRoute('/watch/:tmdbId', (ctx, state) => WatchPage(
                request: PlaybackRequest(
                  tmdbId: int.parse(state.pathParameters['tmdbId']!),
                  mediaType:
                      state.uri.queryParameters['media_type'] ?? 'movie',
                  season: int.tryParse(
                      state.uri.queryParameters['season'] ?? ''),
                  episode: int.tryParse(
                      state.uri.queryParameters['episode'] ?? ''),
                ),
              )),
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

/// 2026-05-17 (CM-2): the Pass 2F "depth" combined fade + scale was
/// reverted to a pure 250 ms ease-out fade. The scale-up felt like a
/// cheap reveal effect against the editorial pivot — pages should just
/// settle into place without theatrics.
GoRoute _fadeRoute(
    String path, Widget Function(BuildContext, GoRouterState) builder) {
  return GoRoute(
    path: path,
    pageBuilder: (ctx, state) => CustomTransitionPage<void>(
      key: state.pageKey,
      child: builder(ctx, state),
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    ),
  );
}
