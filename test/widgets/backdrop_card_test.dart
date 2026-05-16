// test/widgets/backdrop_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/cards/backdrop_card.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('renders title + subtitle text', (t) async {
    await t.pumpWidget(host(const BackdropCard(
      title: 'Sandokan',
      subtitle: 'S1 · E1 · 28 min',
    )));
    expect(find.text('Sandokan'), findsOneWidget);
    expect(find.text('S1 · E1 · 28 min'), findsOneWidget);
  });

  testWidgets('shows progress bar when fraction is set', (t) async {
    await t.pumpWidget(host(const BackdropCard(
      title: 'Sandokan',
      progressFraction: 0.42,
    )));
    expect(find.byType(FractionallySizedBox), findsOneWidget);
  });

  testWidgets('no progress bar when fraction is null', (t) async {
    await t.pumpWidget(host(const BackdropCard(title: 'Sandokan')));
    expect(find.byType(FractionallySizedBox), findsNothing);
  });

  testWidgets('tap fires callback', (t) async {
    var tapped = false;
    await t.pumpWidget(host(BackdropCard(
      title: 'Sandokan',
      onTap: () => tapped = true,
    )));
    await t.tap(find.byType(BackdropCard));
    expect(tapped, isTrue);
  });

  testWidgets('omits subtitle widget when subtitle is null', (t) async {
    await t.pumpWidget(host(const BackdropCard(title: 'Sandokan')));
    // Only one Text widget: the title.
    expect(find.byType(Text), findsOneWidget);
  });
}
