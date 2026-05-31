// test/pages/cast_navigation_e2e_test.dart
//
// Pass 3 CAST-6 — end-to-end navigation loop:
//   CastCard (on a host) → tap → /person/:tmdbId
//   PersonPage's PosterRow → tap card → /title/:tmdbId
// Uses a tiny GoRouter so we exercise route registration without
// pulling in the full app router (which gates on auth state).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/domain/models/person.dart';
import 'package:streamload_client/presentation/pages/person_page.dart';
import 'package:streamload_client/presentation/widgets/cast/cast_card.dart';
import 'package:streamload_client/presentation/widgets/poster_card.dart';
import 'package:streamload_client/state/person_provider.dart';

void main() {
  testWidgets('CastCard tap → PersonPage → PosterRow tap → title route',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? landedTitlePath;

    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (_, __) => const Scaffold(
            body: Center(
              child: CastCard(
                data: CastCardData(
                  tmdbId: 287,
                  name: 'Brad Pitt',
                  character: 'Cliff Booth',
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/person/:tmdbId',
          builder: (_, state) => PersonPage(
            tmdbId: int.parse(state.pathParameters['tmdbId']!),
          ),
        ),
        GoRoute(
          path: '/title/:tmdbId',
          builder: (_, state) {
            final mt = state.uri.queryParameters['media_type'] ?? 'movie';
            landedTitlePath =
                '/title/${state.pathParameters['tmdbId']}?media_type=$mt';
            return const Scaffold(body: Text('title-page-stub'));
          },
        ),
      ],
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        personProvider.overrideWith((ref, id) async {
          return const Person(
            tmdbId: 287,
            name: 'Brad Pitt',
            biography: 'Actor.',
            knownForDepartment: 'Acting',
          );
        }),
        personCreditsProvider.overrideWith((ref, id) async {
          return const [
            MediaSummary(
              tmdbId: 9999,
              mediaType: 'movie',
              title: 'Once Upon a Time',
              year: 2019,
            ),
          ];
        }),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();

    // Step 1: tap the CastCard.
    expect(find.byType(CastCard), findsOneWidget);
    await tester.tap(find.byType(CastCard));
    await tester.pumpAndSettle();

    // Step 2: we're on the PersonPage — Brad Pitt + Filmografia visible.
    // Filmography is a covers-only grid now (no title text under the poster),
    // so assert the card is present by type rather than by title text.
    expect(find.text('Brad Pitt'), findsOneWidget);
    expect(find.text('Filmografia'), findsOneWidget);
    expect(find.byType(PosterCard), findsWidgets);

    // Step 3: scroll the filmography card into view (the hero is tall), then
    // tap it — fires the grid's onTap → /title/<id>?media_type=<mt>.
    await tester.scrollUntilVisible(
      find.byType(PosterCard).first,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byType(PosterCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PosterCard).first);
    await tester.pumpAndSettle();

    expect(landedTitlePath, '/title/9999?media_type=movie');
    expect(find.text('title-page-stub'), findsOneWidget);
  });
}
