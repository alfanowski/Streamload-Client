// test/widgets/text_cta_test.dart
//
// CM-4 (2026-05-17): TextCta is the typographic Cinema Magazine CTA.
// Verify the basics:
//   - renders leading + label + trailing arrow
//   - fires onTap when enabled + tapped
//   - busy state renders a spinner instead of leading + ignores taps
//   - disabled state dims the label + ignores taps
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/text_cta.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        home: MediaQuery(
          // Use a desktop-sized viewport so MouseRegion + interactive
          // logic doesn't branch into the mobile "always show underline"
          // path. The default test view is desktop-sized anyway.
          data: const MediaQueryData(size: Size(1280, 720)),
          child: Scaffold(body: Center(child: child)),
        ),
      );

  testWidgets('renders leading + label + trailing arrow', (t) async {
    await t.pumpWidget(host(const TextCta(
      label: 'Guarda',
      leading: '▶',
    )));
    expect(find.text('▶'), findsOneWidget);
    expect(find.text('Guarda →'), findsOneWidget);
  });

  testWidgets('fires onTap when enabled + tapped', (t) async {
    var taps = 0;
    await t.pumpWidget(host(TextCta(
      label: 'Guarda',
      onTap: () => taps++,
    )));
    await t.tap(find.text('Guarda →'));
    expect(taps, 1);
  });

  testWidgets('busy renders a spinner + ignores taps', (t) async {
    var taps = 0;
    await t.pumpWidget(host(TextCta(
      label: 'Guarda',
      busy: true,
      onTap: () => taps++,
    )));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await t.tap(find.byType(TextCta));
    expect(taps, 0);
  });

  testWidgets('disabled label is non-tappable', (t) async {
    var taps = 0;
    await t.pumpWidget(host(TextCta(
      label: 'Al momento non disponibile',
      enabled: false,
      // PlayCta wires unavailable with trailing:'' so the dim label
      // doesn't read as a destination — mirror that here.
      trailing: '',
      onTap: () => taps++,
    )));
    expect(find.text('Al momento non disponibile'), findsOneWidget);
    await t.tap(find.text('Al momento non disponibile'));
    expect(taps, 0);
  });

  testWidgets('empty trailing renders just the label', (t) async {
    await t.pumpWidget(host(const TextCta(
      label: 'Nella lista',
      leading: '✓',
      trailing: '',
    )));
    // No arrow appended.
    expect(find.text('Nella lista'), findsOneWidget);
    expect(find.text('Nella lista →'), findsNothing);
  });
}
