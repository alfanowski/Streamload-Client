// test/widgets/player_controls_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/player/engine.dart';
import 'package:streamload_client/presentation/widgets/player_controls.dart';
import 'package:streamload_client/state/player_engine_provider.dart';

class _EngineMock extends Mock implements PlayerEngine {}

void main() {
  testWidgets('shows play icon when not playing, tap calls play()',
      (tester) async {
    final engine = _EngineMock();
    final positionCtrl = StreamController<Duration>.broadcast();
    final durationCtrl = StreamController<Duration>.broadcast();
    final playingCtrl = StreamController<bool>.broadcast();
    when(() => engine.positionStream).thenAnswer((_) => positionCtrl.stream);
    when(() => engine.durationStream).thenAnswer((_) => durationCtrl.stream);
    when(() => engine.playingStream).thenAnswer((_) => playingCtrl.stream);
    when(engine.play).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [playerEngineProvider.overrideWith((_) => engine)],
      child: const MaterialApp(
        home: Scaffold(body: PlayerControls()),
      ),
    ));
    playingCtrl.add(false);
    durationCtrl.add(const Duration(seconds: 60));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    await tester.tap(find.byIcon(Icons.play_arrow));
    verify(engine.play).called(1);

    await positionCtrl.close();
    await durationCtrl.close();
    await playingCtrl.close();
  });
}
