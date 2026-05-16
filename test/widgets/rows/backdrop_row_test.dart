// test/widgets/rows/backdrop_row_test.dart
//
// BackdropRow renders title + N BackdropCards, surfaces the progress
// fraction on cards that have one, and fires the per-item onTap.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:streamload_client/presentation/widgets/cards/backdrop_card.dart';
import 'package:streamload_client/presentation/widgets/rows/backdrop_row.dart';

void main() {
  Future<void> pumpRow(WidgetTester t, Widget child) async {
    await t.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => Scaffold(body: child)),
        GoRoute(
          path: '/library',
          builder: (_, __) => const Scaffold(body: Text('LibraryPage')),
        ),
      ],
    );
    await t.pumpWidget(ProviderScope(
      child: MaterialApp.router(routerConfig: router),
    ));
    await t.pump();
  }

  testWidgets('renders title + N BackdropCards', (t) async {
    await pumpRow(
      t,
      const BackdropRow(
        title: 'Continua a guardare',
        items: [
          BackdropRowItem(title: 'A'),
          BackdropRowItem(title: 'B'),
          BackdropRowItem(title: 'C'),
        ],
      ),
    );
    expect(find.text('Continua a guardare'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byType(BackdropCard), findsNWidgets(3));
  });

  testWidgets('progress fraction propagates to the card', (t) async {
    await pumpRow(
      t,
      const BackdropRow(
        title: 'Progress',
        items: [
          BackdropRowItem(title: 'A', progressFraction: 0.42),
          BackdropRowItem(title: 'B'), // no progress
        ],
      ),
    );
    // Both cards are BackdropCard; the first one has progressFraction.
    final cards = t.widgetList<BackdropCard>(find.byType(BackdropCard)).toList();
    expect(cards.length, 2);
    expect(cards[0].progressFraction, closeTo(0.42, 1e-6));
    expect(cards[1].progressFraction, isNull);
  });

  testWidgets('onTap on a card fires its callback', (t) async {
    var tapped = false;
    await pumpRow(
      t,
      BackdropRow(
        title: 'X',
        items: [
          BackdropRowItem(title: 'Only', onTap: () => tapped = true),
        ],
      ),
    );
    await t.tap(find.byType(BackdropCard).first);
    await t.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('"Vedi tutti" link present when seeAllTo set', (t) async {
    await pumpRow(
      t,
      const BackdropRow(
        title: 'Visti di recente',
        items: [BackdropRowItem(title: 'A')],
        seeAllTo: '/library',
      ),
    );
    expect(find.text('Vedi tutti →'), findsOneWidget);
  });

  testWidgets('loading + empty renders placeholders', (t) async {
    await pumpRow(
      t,
      const BackdropRow(
        title: 'Loading',
        items: [],
        isLoading: true,
        placeholderCount: 3,
      ),
    );
    expect(find.byType(BackdropCard), findsNothing);
    expect(find.text('Loading'), findsOneWidget);
  });
}
