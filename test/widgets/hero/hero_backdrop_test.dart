// test/widgets/hero/hero_backdrop_test.dart
//
// 2026-05-16 (P1 hotfix): HeroBackdrop now renders just the backdrop
// image + bottom gradient — the trailer + mute toggle were removed.
// videoId / showMuteToggle / muteToggleAlignment / muteToggleMargin
// params stay for source compat but are ignored. These tests pin the
// new contract.
//
// We deliberately wrap the widget in a fixed-size SizedBox + Stack so
// HeroBackdrop's StackFit.expand has a finite bounding box to render
// into (without a parent box it would error in tests).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('videoId is ignored: still no trailer or mute toggle',
      (t) async {
    await t.pumpWidget(host(
      const HeroBackdrop(backdropUrl: null, videoId: 'abc'),
    ));
    expect(find.byType(HeroTrailer), findsNothing);
    expect(find.byIcon(Icons.volume_off), findsNothing);
    expect(find.byIcon(Icons.volume_up), findsNothing);
  });

  testWidgets('showMuteToggle:false is a no-op (toggle already gone)',
      (t) async {
    await t.pumpWidget(host(
      const HeroBackdrop(
        backdropUrl: null,
        videoId: 'abc',
        showMuteToggle: false,
      ),
    ));
    expect(find.byType(HeroTrailer), findsNothing);
    expect(find.byIcon(Icons.volume_off), findsNothing);
  });
}
