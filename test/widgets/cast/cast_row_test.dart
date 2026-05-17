// test/widgets/cast/cast_row_test.dart
//
// Pass 3 CAST-3 — CastRow renders the "Cast" header + a horizontal list
// of CastCards. Loading shows circular skeletons; empty hides the row.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/cast/cast_card.dart';
import 'package:streamload_client/presentation/widgets/cast/cast_row.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox(width: 1200, child: child),
        ),
      );

  testWidgets('renders header and one card per cast member', (t) async {
    await t.pumpWidget(host(const CastRow(
      members: [
        CastCardData(tmdbId: 1, name: 'Actor A', character: 'Hero'),
        CastCardData(tmdbId: 2, name: 'Actor B', character: 'Villain'),
        CastCardData(tmdbId: 3, name: 'Actor C', character: 'Friend'),
      ],
    )));
    await t.pumpAndSettle();
    expect(find.text('Cast'), findsOneWidget);
    expect(find.byType(CastCard), findsNWidgets(3));
    expect(find.text('Actor A'), findsOneWidget);
    expect(find.text('Hero'), findsOneWidget);
  });

  testWidgets('renders nothing when members list is empty and not loading',
      (t) async {
    await t.pumpWidget(host(const CastRow(members: [])));
    expect(find.text('Cast'), findsNothing);
    expect(find.byType(CastCard), findsNothing);
  });

  testWidgets('renders circular skeletons while loading', (t) async {
    await t.pumpWidget(host(const CastRow(
      members: [],
      isLoading: true,
    )));
    await t.pump();
    // Header still shows so the row reserves space.
    expect(find.text('Cast'), findsOneWidget);
    expect(find.byType(CastCard), findsNothing);
    // Skeleton uses a Container with shape: BoxShape.circle — count
    // those instead of poking at private widgets.
    final circles = find.byWidgetPredicate((w) {
      if (w is Container) {
        final dec = w.decoration;
        return dec is BoxDecoration && dec.shape == BoxShape.circle;
      }
      return false;
    });
    expect(circles, findsWidgets);
  });
}
