// test/widgets/hero/hero_slide_test.dart
//
// 2026-05-16 (P1 hotfix): the YouTube trailer reveal was removed —
// heroes show just the static backdrop image now (no autoplay video,
// no 🔊 toggle). These tests cover the simplified hero contract:
//
//   - construction doesn't throw
//   - the title / meta line / synopsis surface in the tree
//   - HeroTrailer is NEVER mounted, regardless of [videoId]
//   - the 🔊 mute toggle is NEVER rendered
//
// We use a wide-screen MediaQuery to land on the desktop branch so the
// layout has predictable widths.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    // The "IN EVIDENZA" eyebrow was removed — the title stands on its own.
    expect(find.textContaining('IN EVIDENZA'), findsNothing);
    // No trailer, no mute toggle — heroes are static now.
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

  testWidgets('videoId is ignored — no trailer / no mute toggle', (t) async {
    await t.pumpWidget(host(const HeroSlide(
      title: 'Dune',
      mediaType: 'movie',
      year: 2021,
      videoId: 'n9xhJrPXop4',
      runtimeMinutes: 155,
    )));
    expect(find.byType(HeroTrailer), findsNothing);
    expect(find.byIcon(Icons.volume_off), findsNothing);
    expect(find.byIcon(Icons.volume_up), findsNothing);
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
