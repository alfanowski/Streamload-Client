// test/widgets/search/person_result_tile_test.dart
//
// PS-3 — PersonResultTile renders name + (Italian) department + knownFor,
// and tapping routes to /person/<id>.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:streamload_client/domain/models/search_results.dart';
import 'package:streamload_client/presentation/widgets/search/person_result_tile.dart';

void main() {
  testWidgets('renders name, Italian department label, and knownFor',
      (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: PersonResultTile(
          person: SearchPersonResult(
            tmdbId: 287,
            name: 'Brad Pitt',
            profileUrl: null,
            department: 'Acting',
            knownFor: ['World War Z', 'Fight Club'],
          ),
        ),
      ),
    ));
    expect(find.text('Brad Pitt'), findsOneWidget);
    expect(find.text('Interprete'), findsOneWidget);
    expect(find.text('World War Z · Fight Club'), findsOneWidget);
    // No photo → fallback avatar icon.
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('omits department line for an unknown department', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: PersonResultTile(
          person: SearchPersonResult(
            tmdbId: 1,
            name: 'Mystery Crew',
            department: 'Sound',
            knownFor: [],
          ),
        ),
      ),
    ));
    expect(find.text('Mystery Crew'), findsOneWidget);
    // 'Sound' is not in the Italian map → no department line, no empty node.
    expect(find.text('Sound'), findsNothing);
  });

  testWidgets('tap navigates to /person/<tmdbId>', (t) async {
    String? destination;
    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (_, __) => const Scaffold(
            body: PersonResultTile(
              person: SearchPersonResult(
                tmdbId: 287,
                name: 'Brad Pitt',
                department: 'Acting',
                knownFor: ['Fight Club'],
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/person/:tmdbId',
          builder: (_, state) {
            destination = '/person/${state.pathParameters['tmdbId']}';
            return const Scaffold(body: Text('person-page'));
          },
        ),
      ],
    );
    await t.pumpWidget(MaterialApp.router(routerConfig: router));
    await t.tap(find.byType(PersonResultTile));
    await t.pumpAndSettle();
    expect(destination, '/person/287');
    expect(find.text('person-page'), findsOneWidget);
  });
}
