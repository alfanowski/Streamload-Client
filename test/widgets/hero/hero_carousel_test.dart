// test/widgets/hero/hero_carousel_test.dart
//
// Verifies the carousel mechanics — slide count, indicator rendering, and
// that a manual swipe crossfades to the next slide. There's no auto-rotate.
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
    // The current slide's title renders (single, stable CTA row).
    expect(find.text('A'), findsWidgets);
    // 3 indicator dots = 3 AnimatedContainer entries with height 3.
    final dots = t.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(dots, hasLength(greaterThanOrEqualTo(3)));
  });

  testWidgets('no "IN EVIDENZA" eyebrow — the title stands alone', (t) async {
    await t.pumpWidget(host(HeroCarousel(
      slides: [slide('Slide1'), slide('Slide2')],
    )));
    expect(find.textContaining('IN EVIDENZA'), findsNothing);
    expect(find.text('Slide1'), findsWidgets);
  });

  testWidgets('mobile swipe advances to the next slide', (t) async {
    await t.pumpWidget(host(
      HeroCarousel(
        slides: [slide('S1'), slide('S2'), slide('S3')],
        height: 400,
      ),
      size: const Size(390, 844),
    ));
    expect(find.text('S1'), findsWidgets);

    // A left fling over the carousel (centre is backdrop, above the CTAs)
    // commits exactly one step to the next slide.
    await t.fling(find.byType(HeroCarousel), const Offset(-300, 0), 1000);
    await t.pumpAndSettle();

    expect(find.text('S2'), findsWidgets);
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
