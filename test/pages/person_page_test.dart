// test/pages/person_page_test.dart
//
// Pass 3 CAST-5 — PersonPage editorial layout. Bio + identity in a
// magazine hero, filmography PosterRow under it. Loading shows a
// skeleton; error shows an inline Riprova.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/domain/models/person.dart';
import 'package:streamload_client/presentation/pages/person_page.dart';
import 'package:streamload_client/presentation/widgets/poster_card.dart';
import 'package:streamload_client/state/person_provider.dart';

enum _State { data, loading, error }

class _Setup {
  _Setup({
    this.person,
    this.personState = _State.data,
    this.credits = const <MediaSummary>[],
    this.creditsState = _State.data,
  });
  final Person? person;
  final _State personState;
  final List<MediaSummary> credits;
  final _State creditsState;
}

Widget _host({required _Setup setup}) {
  return ProviderScope(
    overrides: [
      personProvider.overrideWith((ref, id) {
        switch (setup.personState) {
          case _State.data:
            return Future<Person>.value(setup.person!);
          case _State.loading:
            return Completer<Person>().future;
          case _State.error:
            return Future<Person>.error(Exception('boom'));
        }
      }),
      personCreditsProvider.overrideWith((ref, id) {
        switch (setup.creditsState) {
          case _State.data:
            return Future<List<MediaSummary>>.value(setup.credits);
          case _State.loading:
            return Completer<List<MediaSummary>>().future;
          case _State.error:
            return Future<List<MediaSummary>>.error(Exception('boom'));
        }
      }),
    ],
    child: const MaterialApp(home: PersonPage(tmdbId: 287)),
  );
}

/// Per-test viewport setup helper. Default 1400x1400 — wide enough for
/// the desktop hero (380 portrait + 40 gap + identity) and tall enough
/// that the entire ListView lays out without scrolling.
Future<void> _setupViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('renders editorial hero + bio + filmography on success',
      (tester) async {
    await _setupViewport(tester);
    await tester.pumpWidget(_host(
      setup: _Setup(
        person: const Person(
          tmdbId: 287,
          name: 'Brad Pitt',
          biography: 'Actor and producer from Oklahoma.',
          birthday: '1963-12-18',
          placeOfBirth: 'Shawnee, Oklahoma, USA',
          knownForDepartment: 'Acting',
        ),
        credits: const [
          MediaSummary(
            tmdbId: 1, mediaType: 'movie',
            title: 'Once Upon a Time', year: 2019,
          ),
          MediaSummary(
            tmdbId: 2, mediaType: 'movie',
            title: 'Fight Club', year: 1999,
          ),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Brad Pitt'), findsOneWidget);
    expect(find.text('INTERPRETE'), findsOneWidget);
    expect(find.text('Actor and producer from Oklahoma.'), findsOneWidget);
    expect(find.text('Filmografia'), findsOneWidget);
    // Rows are covers-only now (no title under the poster) — assert the two
    // filmography cards render by type.
    expect(find.byType(PosterCard), findsNWidgets(2));
  });

  testWidgets('hides biography block when biography is empty', (tester) async {
    await tester.pumpWidget(_host(
      setup: _Setup(
        person: const Person(
          tmdbId: 1,
          name: 'Anonymous',
        ),
        credits: const [
          MediaSummary(tmdbId: 5, mediaType: 'movie', title: 'A Film'),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Anonymous'), findsOneWidget);
    // No empty body text node should slip in.
    expect(find.text(''), findsNothing);
    // Filmography still renders (covers-only — assert by card type).
    expect(find.byType(PosterCard), findsOneWidget);
  });

  testWidgets('shows empty-state copy when no filmography', (tester) async {
    await tester.pumpWidget(_host(
      setup: _Setup(
        person: const Person(tmdbId: 1, name: 'Newcomer'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Nessun titolo disponibile'), findsOneWidget);
  });

  testWidgets('renders loading skeleton while person resolves',
      (tester) async {
    await _setupViewport(tester);
    await tester.pumpWidget(_host(
      setup: _Setup(personState: _State.loading, creditsState: _State.loading),
    ));
    await tester.pump();
    expect(find.byKey(const Key('person-page-skeleton')), findsOneWidget);
  });

  testWidgets('shows error + Riprova button on error', (tester) async {
    await tester.pumpWidget(_host(
      setup: _Setup(personState: _State.error),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Riprova'), findsOneWidget);
  });

  testWidgets('formats Italian birth line with full date + place',
      (tester) async {
    await _setupViewport(tester);
    await tester.pumpWidget(_host(
      setup: _Setup(
        person: const Person(
          tmdbId: 1,
          name: 'Test',
          birthday: '1989-03-19',
          placeOfBirth: 'Roma, Italia',
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('19 marzo 1989 · Roma, Italia'), findsOneWidget);
  });

  testWidgets('formats year-only birth line when day/month missing',
      (tester) async {
    await _setupViewport(tester);
    await tester.pumpWidget(_host(
      setup: _Setup(
        person: const Person(
          tmdbId: 1,
          name: 'Test',
          birthday: '1989',
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('n. 1989'), findsOneWidget);
  });

  testWidgets('appends † deathday when present', (tester) async {
    await tester.pumpWidget(_host(
      setup: _Setup(
        person: const Person(
          tmdbId: 1,
          name: 'Test',
          birthday: '1934-05-31',
          deathday: '2023-08-04',
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('† 2023'), findsOneWidget);
  });

  testWidgets('maps known_for_department to Italian eyebrow label',
      (tester) async {
    await _setupViewport(tester);
    await tester.pumpWidget(_host(
      setup: _Setup(
        person: const Person(
          tmdbId: 1,
          name: 'Director',
          knownForDepartment: 'Directing',
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('REGIA'), findsOneWidget);
  });

  testWidgets('Writing → SCENEGGIATURA', (tester) async {
    await _setupViewport(tester);
    await tester.pumpWidget(_host(
      setup: _Setup(
        person: const Person(
          tmdbId: 2,
          name: 'Writer',
          knownForDepartment: 'Writing',
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('SCENEGGIATURA'), findsOneWidget);
  });

  testWidgets('Production → PRODUZIONE', (tester) async {
    await _setupViewport(tester);
    await tester.pumpWidget(_host(
      setup: _Setup(
        person: const Person(
          tmdbId: 3,
          name: 'Producer',
          knownForDepartment: 'Production',
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('PRODUZIONE'), findsOneWidget);
  });
}
