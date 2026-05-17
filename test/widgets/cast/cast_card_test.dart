// test/widgets/cast/cast_card_test.dart
//
// Pass 3 CAST-3 — CastCard renders an actor's portrait + name + role,
// and tapping it navigates to /person/<id>.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:streamload_client/presentation/widgets/cast/cast_card.dart';

void main() {
  testWidgets('renders the actor name and character role', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CastCard(
            data: CastCardData(
              tmdbId: 287,
              name: 'Brad Pitt',
              character: 'Cliff Booth',
              profileUrl: null,
            ),
          ),
        ),
      ),
    ));
    expect(find.text('Brad Pitt'), findsOneWidget);
    expect(find.text('Cliff Booth'), findsOneWidget);
  });

  testWidgets('renders portrait fallback when profileUrl is null',
      (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CastCard(
            data: CastCardData(
              tmdbId: 1,
              name: 'No Photo',
              character: 'Self',
              profileUrl: null,
            ),
          ),
        ),
      ),
    ));
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('omits character line when null', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CastCard(
          data: CastCardData(
            tmdbId: 1,
            name: 'Director Only',
            character: null,
            profileUrl: null,
          ),
        ),
      ),
    ));
    expect(find.text('Director Only'), findsOneWidget);
    // No empty subtitle text node.
    expect(find.text(''), findsNothing);
  });

  testWidgets('tap navigates to /person/<tmdbId>', (t) async {
    String? destination;
    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (_, __) => const Scaffold(
            body: CastCard(
              data: CastCardData(
                tmdbId: 287,
                name: 'Brad Pitt',
                character: 'Self',
                profileUrl: null,
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
    await t.tap(find.byType(CastCard));
    await t.pumpAndSettle();
    expect(destination, '/person/287');
    expect(find.text('person-page'), findsOneWidget);
  });
}
