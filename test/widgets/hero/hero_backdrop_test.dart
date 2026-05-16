// test/widgets/hero/hero_backdrop_test.dart
//
// HeroBackdrop is the shared backdrop+trailer+gradient+mute stack used
// by HeroSlide (home carousel) and the Title page hero. We verify:
//
//   - no trailer / no toggle when videoId is null
//   - trailer mounted + 🔊 toggle visible when videoId is set
//   - mute toggle flips icons on tap
//   - pumping past the reveal delay does not throw / leaves no
//     pending timers
//
// We deliberately wrap the widget in a fixed-size SizedBox + Stack so
// HeroBackdrop's StackFit.expand has a finite bounding box to render
// into (without a parent box it would error in tests).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/theme/motion.dart';
import 'package:streamload_client/presentation/widgets/hero/hero_backdrop.dart';
import 'package:streamload_client/presentation/widgets/hero/hero_trailer.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: Stack(children: [child]),
          ),
        ),
      );

  testWidgets('null videoId: no trailer + no mute toggle', (t) async {
    await t.pumpWidget(host(const HeroBackdrop(backdropUrl: null)));
    expect(find.byType(HeroTrailer), findsNothing);
    expect(find.byIcon(Icons.volume_off), findsNothing);
    expect(find.byIcon(Icons.volume_up), findsNothing);
  });

  testWidgets('with videoId: trailer mounted + mute toggle visible',
      (t) async {
    await t.pumpWidget(host(
      const HeroBackdrop(backdropUrl: null, videoId: 'abc'),
    ));
    expect(find.byType(HeroTrailer), findsOneWidget);
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
  });

  testWidgets('tapping mute toggle flips icon', (t) async {
    await t.pumpWidget(host(
      const HeroBackdrop(backdropUrl: null, videoId: 'abc'),
    ));
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
    await t.tap(find.byIcon(Icons.volume_off));
    await t.pump();
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    expect(find.byIcon(Icons.volume_off), findsNothing);
  });

  testWidgets('pumping past reveal delay does not throw', (t) async {
    await t.pumpWidget(host(
      const HeroBackdrop(backdropUrl: null, videoId: 'abc'),
    ));
    await t.pump(
      StreamloadMotion.trailerRevealDelay + const Duration(milliseconds: 50),
    );
    await t.pump(StreamloadMotion.heroCrossfade);
    expect(find.byType(HeroTrailer), findsOneWidget);
  });

  testWidgets('showMuteToggle:false hides the toggle even with videoId',
      (t) async {
    await t.pumpWidget(host(
      const HeroBackdrop(
        backdropUrl: null,
        videoId: 'abc',
        showMuteToggle: false,
      ),
    ));
    expect(find.byType(HeroTrailer), findsOneWidget);
    expect(find.byIcon(Icons.volume_off), findsNothing);
  });
}
