// test/widgets/title/title_hero_test.dart
//
// Title page hero — Phase E1 + F3 of sub-plan 8. Verifies:
//
//   - renders title + meta line + share / list CTAs
//   - movie title primary CTA reads "▶ Guarda"
//   - tv title primary CTA reads "▶ Guarda S1 E1" when no progress yet
//   - tv title primary CTA reads "▶ Riprendi" when continue-watching has
//     a record for this title
//   - tapping the share circle copies the deep link to the clipboard
//   - (F3) Guarda CTA shows the spinner state while the probe is loading
//   - (F3) Guarda CTA flips to "Al momento non disponibile" when the
//     probe returns false (or errors out)
//   - (F3) tapping Guarda navigates to /watch/<tmdbId> with the right
//     query string (media_type + season/episode for TV)
//
// 2026-05-16 (P1 hotfix): the trailer is no longer rendered, so we
// don't override titleTrailerProvider anymore.
//
// 2026-05-17 (CM-2 / CM-4): the share affordance became a typographic
// "↗ Condividi" TextCta (no Icon), and the "＋ La mia lista" / "✓
// Nella lista" toggle became a TextCta with separate leading + label
// Texts. Tests now find by label text instead of by Icon.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/domain/models/catalog_item.dart';
import 'package:streamload_client/presentation/widgets/play_cta.dart';
import 'package:streamload_client/presentation/widgets/title/title_hero.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/availability_provider.dart';
import 'package:streamload_client/state/continue_watching_provider.dart';
import 'package:streamload_client/domain/models/continue_watching_item.dart';

class _FavApiMock extends Mock implements FavoritesApi {}

void main() {
  Widget host(
    Widget child, {
    List<Override> extra = const [],
    Size size = const Size(1280, 720),
  }) {
    final fav = _FavApiMock();
    when(fav.list).thenAnswer((_) async => <Map<String, dynamic>>[]);
    return ProviderScope(
      overrides: [
        favoritesApiProvider.overrideWith((_) async => fav),
        // Default: no progress, no trailer, availability=true (renders the
        // play CTA). Tests that exercise checking / unavailable override
        // availabilityProvider explicitly via `extra`.
        continueWatchingProvider
            .overrideWith((_) async => <ContinueWatchingItem>[]),
        availabilityProvider.overrideWith((_, __) async => true),
        ...extra,
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SizedBox(
              width: size.width,
              height: size.height * 0.6,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  const movieItem = CatalogItemResponse(
    tmdbId: 27205,
    mediaType: 'movie',
    title: 'Inception',
    year: 2010,
    runtimeMinutes: 148,
    rating: 8.4,
    overview: 'A thief who steals corporate secrets through dreams.',
  );

  const tvItem = CatalogItemResponse(
    tmdbId: 1396,
    mediaType: 'tv',
    title: 'Breaking Bad',
    year: 2008,
    rating: 9.5,
    seasonsCount: 5,
    overview: 'A chemistry teacher turns to making meth.',
  );

  testWidgets('renders title + Guarda CTA for movie', (t) async {
    await t.pumpWidget(host(TitleHero(item: movieItem, onShare: () {})));
    await t.pumpAndSettle();
    expect(find.text('Inception'), findsOneWidget);
    // CM-4: PlayCta is now a typographic TextCta wrapper — "Guarda →".
    // La mia lista and Condividi are also TextCtas with "label →" form.
    expect(find.text('Guarda →'), findsOneWidget);
    expect(find.text('La mia lista →'), findsOneWidget);
    // No trailer overridden → no 🔊 toggle.
    expect(find.byIcon(Icons.volume_off), findsNothing);
  });

  testWidgets('tv title shows Guarda S1 E1 when no progress', (t) async {
    await t.pumpWidget(host(TitleHero(item: tvItem, onShare: () {})));
    await t.pumpAndSettle();
    expect(find.text('Guarda S1 E1 →'), findsOneWidget);
  });

  testWidgets('tv title shows Riprendi when continue-watching has it',
      (t) async {
    await t.pumpWidget(host(
      TitleHero(item: tvItem, onShare: () {}),
      extra: [
        continueWatchingProvider.overrideWith((_) async => [
              const ContinueWatchingItem(
                tmdbId: 1396,
                mediaType: 'tv',
                title: 'Breaking Bad',
                seasonNumber: 2,
                episodeNumber: 3,
                positionSeconds: 600,
                durationSeconds: 2700,
              ),
            ]),
      ],
    ));
    await t.pumpAndSettle();
    expect(find.text('Riprendi →'), findsOneWidget);
  });

  testWidgets('share icon copies deep link to clipboard', (t) async {
    final messenger = TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger;
    String? copied;
    messenger.setMockMethodCallHandler(SystemChannels.platform,
        (call) async {
      if (call.method == 'Clipboard.setData') {
        final args = call.arguments as Map<dynamic, dynamic>;
        copied = args['text'] as String?;
      }
      return null;
    });

    var sharedCount = 0;
    await t.pumpWidget(host(TitleHero(
      item: movieItem,
      onShare: () {
        sharedCount += 1;
        Clipboard.setData(const ClipboardData(
          text: 'streamload://title/27205?media_type=movie',
        ));
      },
    )));
    await t.pumpAndSettle();
    // CM-4: share is the typographic "↗ Condividi" TextCta, not an Icon.
    await t.tap(find.text('Condividi →'));
    await t.pumpAndSettle();
    expect(sharedCount, 1);
    expect(copied, 'streamload://title/27205?media_type=movie');

    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('toggle La mia lista flips to ✓ Nella lista', (t) async {
    final fav = _FavApiMock();
    when(fav.list).thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => fav.add(27205, 'movie')).thenAnswer((_) async {});
    await t.pumpWidget(host(
      TitleHero(item: movieItem, onShare: () {}),
      extra: [favoritesApiProvider.overrideWith((_) async => fav)],
    ));
    await t.pumpAndSettle();
    // CM-4: leading + label render as separate Texts; the trailing arrow
    // hangs off the label until the item is added (no arrow on the
    // "Nella lista" state — it reads as a state, not a destination).
    expect(find.text('La mia lista →'), findsOneWidget);
    await t.tap(find.text('La mia lista →'));
    await t.pumpAndSettle();
    expect(find.text('Nella lista'), findsOneWidget);
    verify(() => fav.add(27205, 'movie')).called(1);
  });

  // ────────────────────────────────────────────────────────────────────
  // F3 — Guarda CTA wired to availabilityProvider
  //
  // The Guarda pill should now mirror the probe's three states. The
  // host() helper above overrides availabilityProvider to true by
  // default; these tests override it explicitly to exercise the other
  // branches.
  // ────────────────────────────────────────────────────────────────────

  testWidgets('Guarda CTA shows spinner while availability is loading',
      (t) async {
    // A Future that never completes → provider stays loading forever.
    await t.pumpWidget(host(
      TitleHero(item: movieItem, onShare: () {}),
      extra: [
        availabilityProvider.overrideWith(
          (_, __) => Completer<bool>().future,
        ),
      ],
    ));
    // Single pump so we don't await the never-completing future.
    await t.pump();

    final cta = t.widget<PlayCta>(find.byType(PlayCta));
    expect(cta.state, PlayCtaState.checking);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Guarda →'), findsNothing);
    expect(find.text('Al momento non disponibile'), findsNothing);
  });

  testWidgets('Guarda CTA shows Play state with label when available',
      (t) async {
    await t.pumpWidget(host(TitleHero(item: movieItem, onShare: () {})));
    await t.pumpAndSettle();

    final cta = t.widget<PlayCta>(find.byType(PlayCta));
    expect(cta.state, PlayCtaState.play);
    expect(cta.label, 'Guarda');
    expect(cta.onTap, isNotNull);
    expect(find.text('Guarda →'), findsOneWidget);
    expect(find.text('Al momento non disponibile'), findsNothing);
  });

  testWidgets(
      'Guarda CTA renders Unavailable when probe returns false (non-tappable)',
      (t) async {
    await t.pumpWidget(host(
      TitleHero(item: movieItem, onShare: () {}),
      extra: [
        availabilityProvider.overrideWith((_, __) async => false),
      ],
    ));
    await t.pumpAndSettle();

    final cta = t.widget<PlayCta>(find.byType(PlayCta));
    expect(cta.state, PlayCtaState.unavailable);
    expect(find.text('Al momento non disponibile'), findsOneWidget);
    expect(find.text('Guarda →'), findsNothing);

    // CM-4 unavailable TextCta has no onTap wired — tapping should not
    // throw and should not trigger navigation (no /watch route in host).
    await t.tap(find.text('Al momento non disponibile'));
    await t.pumpAndSettle();
    expect(find.text('Al momento non disponibile'), findsOneWidget);
  });

  testWidgets('Guarda CTA renders Unavailable when probe errors', (t) async {
    await t.pumpWidget(host(
      TitleHero(item: movieItem, onShare: () {}),
      extra: [
        availabilityProvider.overrideWith(
          (_, __) => Future<bool>.error(StateError('boom')),
        ),
      ],
    ));
    await t.pumpAndSettle();

    final cta = t.widget<PlayCta>(find.byType(PlayCta));
    expect(cta.state, PlayCtaState.unavailable);
    expect(find.text('Al momento non disponibile'), findsOneWidget);
  });

  testWidgets(
      'tapping Guarda navigates to /watch/<id> with media_type+season+episode '
      'query (TV)', (t) async {
    String? landedOn;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => TitleHero(item: tvItem, onShare: () {}),
        ),
        GoRoute(
          path: '/watch/:tmdbId',
          builder: (_, state) {
            landedOn = '/watch/${state.pathParameters['tmdbId']}'
                '?${state.uri.query}';
            return const Scaffold(body: Text('WATCH_PAGE'));
          },
        ),
      ],
    );

    final fav = _FavApiMock();
    when(fav.list).thenAnswer((_) async => <Map<String, dynamic>>[]);
    await t.pumpWidget(ProviderScope(
      overrides: [
        favoritesApiProvider.overrideWith((_) async => fav),
        continueWatchingProvider
            .overrideWith((_) async => <ContinueWatchingItem>[]),
        availabilityProvider.overrideWith((_, __) async => true),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await t.pumpAndSettle();

    expect(find.text('Guarda S1 E1 →'), findsOneWidget);
    await t.tap(find.text('Guarda S1 E1 →'));
    await t.pumpAndSettle();
    expect(find.text('WATCH_PAGE'), findsOneWidget);
    expect(landedOn, '/watch/1396?media_type=tv&season=1&episode=1');
  });
}
