// test/widgets/play_cta_test.dart
//
// 2026-05-17 (CM-4): PlayCta is now a typographic TextCta wrapper. The
// pill shape + AnimatedContainer + ▶ glyph are gone. Tests find by
// label text and assert the underline + tap behaviour through TextCta.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/play_cta.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('checking state renders a spinner', (t) async {
    await t.pumpWidget(host(const PlayCta(state: PlayCtaState.checking)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('play state renders "Guarda →" and fires onTap', (t) async {
    var tapped = false;
    await t.pumpWidget(host(PlayCta(
      state: PlayCtaState.play,
      label: 'Guarda',
      onTap: () => tapped = true,
    )));
    expect(find.text('Guarda →'), findsOneWidget);
    await t.tap(find.text('Guarda →'));
    expect(tapped, isTrue);
  });

  testWidgets('play state uses custom label', (t) async {
    await t.pumpWidget(host(const PlayCta(
      state: PlayCtaState.play,
      label: 'Riprendi',
    )));
    expect(find.text('Riprendi →'), findsOneWidget);
  });

  testWidgets('unavailable state shows IT copy and is non-tappable', (t) async {
    var tapped = false;
    await t.pumpWidget(host(PlayCta(
      state: PlayCtaState.unavailable,
      onTap: () => tapped = true,
    )));
    expect(find.text('Al momento non disponibile'), findsOneWidget);
    await t.tap(find.text('Al momento non disponibile'));
    expect(tapped, isFalse);
  });
}
