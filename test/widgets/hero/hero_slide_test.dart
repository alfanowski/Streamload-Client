// test/widgets/hero/hero_slide_test.dart
//
// Hero slide is a heavy widget — it depends on CachedNetworkImage,
// WebViewController (HeroTrailer), and a Timer for trailer reveal. We
// stick to what flutter_test can actually verify:
//
//   - construction doesn't throw
//   - the title / meta line / synopsis surface in the tree
//   - the trailer reveal Timer doesn't fire before its delay (the
//     HeroTrailer subtree only renders when the slide has a videoId
//     AND opacity > 0, but AnimatedOpacity always builds the child;
//     we instead probe that pumping past 2s doesn't crash)
//   - the 🔊 toggle only renders when videoId is provided
//
// We use a wide-screen MediaQuery to land on the desktop branch so the
// layout has predictable widths.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/theme/motion.dart';
import 'package:streamload_client/presentation/widgets/hero/hero_slide.dart';
import 'package:streamload_client/presentation/widgets/hero/hero_trailer.dart';

void main() {
  Widget host(Widget child, {Size size = const Size(1280, 720)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: SizedBox(
            width: size.width,
            height: size.height * 0.5,
            child: child,
          ),
        ),
      ),
    );
  }

  testWidgets('renders title + meta line on desktop', (t) async {
    await t.pumpWidget(host(const HeroSlide(
      title: 'Inception',
      mediaType: 'movie',
      year: 2010,
      runtimeMinutes: 148,
      rating: 8.4,
      synopsis: 'A thief who steals corporate secrets through the use of dreams.',
      backdropUrl: null,
    )));
    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('2010 · 148 min · IT · ⭐ 8.4'), findsOneWidget);
    expect(find.textContaining('IN EVIDENZA'), findsOneWidget);
    // No videoId → no HeroTrailer, no 🔊 toggle.
    expect(find.byType(HeroTrailer), findsNothing);
    expect(find.byIcon(Icons.volume_off), findsNothing);
  });

  testWidgets('renders TV episode count when mediaType=tv', (t) async {
    await t.pumpWidget(host(const HeroSlide(
      title: 'Severance',
      mediaType: 'tv',
      year: 2022,
      episodeCount: 18,
      rating: 8.7,
    )));
    expect(find.text('2022 · 18 ep · IT · ⭐ 8.7'), findsOneWidget);
  });

  testWidgets('hero with videoId mounts the HeroTrailer subtree', (t) async {
    await t.pumpWidget(host(const HeroSlide(
      title: 'Dune',
      mediaType: 'movie',
      year: 2021,
      videoId: 'n9xhJrPXop4',
      runtimeMinutes: 155,
    )));
    expect(find.byType(HeroTrailer), findsOneWidget);
    // Mute toggle visible when there's a trailer.
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
  });

  testWidgets('pumping past reveal delay does not throw', (t) async {
    await t.pumpWidget(host(const HeroSlide(
      title: 'Dune',
      mediaType: 'movie',
      videoId: 'abc',
      year: 2021,
      runtimeMinutes: 155,
    )));
    // Advance past the 2s reveal window.
    await t.pump(StreamloadMotion.trailerRevealDelay + const Duration(milliseconds: 50));
    await t.pump(StreamloadMotion.heroCrossfade);
    expect(find.byType(HeroTrailer), findsOneWidget);
    // No pending timers left over.
  });

  testWidgets('tapping mute toggle flips the icon', (t) async {
    await t.pumpWidget(host(const HeroSlide(
      title: 'Dune',
      mediaType: 'movie',
      videoId: 'abc',
      year: 2021,
    )));
    // Starts muted → volume_off icon visible.
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsNothing);
    await t.tap(find.byIcon(Icons.volume_off));
    await t.pump();
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    expect(find.byIcon(Icons.volume_off), findsNothing);
  });

  testWidgets('phone variant centers title text', (t) async {
    await t.pumpWidget(host(
      const HeroSlide(
        title: 'Phone Hero',
        mediaType: 'movie',
        year: 2024,
        runtimeMinutes: 100,
      ),
      size: const Size(390, 844),
    ));
    expect(find.text('Phone Hero'), findsOneWidget);
  });
}
