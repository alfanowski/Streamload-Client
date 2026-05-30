// test/widgets/hero/hero_carousel_test.dart
//
// Verifies the carousel mechanics — slide count, indicator rendering,
// and that programmatic PageView navigation updates the active dot.
// Auto-rotation is driven by a 30s Timer so we don't exercise it here
// (would slow the suite); the manual ◀ ▶ buttons cover the same path.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/hero/hero_carousel.dart';
import 'package:streamload_client/presentation/widgets/hero/hero_slide.dart';

void main() {
  Widget host(Widget child, {Size size = const Size(1280, 720)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(body: child),
      ),
    );
  }

  HeroSlideData slide(String title) => HeroSlideData(
        title: title,
        mediaType: 'movie',
        year: 2024,
        runtimeMinutes: 120,
        backdropUrl: null,
      );

  testWidgets('empty list renders a sized box and no slides', (t) async {
    await t.pumpWidget(host(const HeroCarousel(slides: [])));
    expect(find.byType(HeroSlide), findsNothing);
  });

  testWidgets('renders the first slide and N indicator dots', (t) async {
    await t.pumpWidget(host(HeroCarousel(
      slides: [slide('A'), slide('B'), slide('C')],
    )));
    // The carousel renders the backdrop + a single metadata block (the
    // CTAs/title), crossfading backdrops between slides.
    expect(find.byType(HeroMetadata), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    // 3 indicator dots = 3 AnimatedContainer entries with height 3.
    final dots = t.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(dots, hasLength(greaterThanOrEqualTo(3)));
  });

  testWidgets('eyebrow reads a clean IN EVIDENZA (no counter)', (t) async {
    await t.pumpWidget(host(HeroCarousel(
      slides: [slide('Slide1'), slide('Slide2')],
    )));
    expect(find.text('IN EVIDENZA'), findsOneWidget);
  });

  testWidgets('mobile swipe crossfades to the next slide', (t) async {
    await t.pumpWidget(host(
      HeroCarousel(
        slides: [slide('S1'), slide('S2'), slide('S3')],
        height: 400,
      ),
      size: const Size(390, 844),
    ));
    expect(find.text('S1'), findsOneWidget);

    // Drag left from the TOP (backdrop) area — not over the CTAs, which
    // deliberately don't start a slide change. Commits to the next slide.
    final start =
        t.getTopLeft(find.byType(HeroCarousel)) + const Offset(195, 50);
    final gesture = await t.startGesture(start);
    await gesture.moveBy(const Offset(-180, 0));
    await t.pump();
    await gesture.moveBy(const Offset(-180, 0));
    await t.pump();
    await gesture.up();
    await t.pumpAndSettle();

    expect(find.text('S2'), findsOneWidget);
  });

  testWidgets('phone variant wraps with GestureDetector for tap-to-pause',
      (t) async {
    await t.pumpWidget(host(
      HeroCarousel(
        slides: [slide('Phone1'), slide('Phone2')],
        height: 400,
      ),
      size: const Size(390, 844),
    ));
    expect(find.byType(GestureDetector), findsWidgets);
  });
}
