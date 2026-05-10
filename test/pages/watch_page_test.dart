// test/pages/watch_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/domain/models/playback_request.dart';
import 'package:streamload_client/domain/play_title.dart';
import 'package:streamload_client/player/engine.dart';
import 'package:streamload_client/presentation/pages/watch_page.dart';
import 'package:streamload_client/state/play_controller_provider.dart';
import 'package:streamload_client/state/player_engine_provider.dart';

class _ControllerMock extends Mock implements PlayController {}

class _EngineMock extends Mock implements PlayerEngine {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Duration());
  });

  testWidgets('on mount calls startMovie + engine.open + play', (tester) async {
    final controller = _ControllerMock();
    final engine = _EngineMock();
    when(() => controller.startMovie(tmdbId: 42))
        .thenAnswer((_) async => 'http://127.0.0.1:9999/master/abc.m3u8');
    when(() => engine.open(any(), headers: any(named: 'headers')))
        .thenAnswer((_) {});
    when(engine.play).thenAnswer((_) async {});
    when(engine.pause).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [
        playControllerProvider.overrideWith((_) async => controller),
        playerEngineProvider.overrideWith((_) => engine),
      ],
      child: MaterialApp(
        home: WatchPage(
          request: const PlaybackRequest(tmdbId: 42, mediaType: 'movie'),
          videoBuilder: (_) => const SizedBox.shrink(),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    verify(() => controller.startMovie(tmdbId: 42)).called(1);
    verify(() => engine.open(
          'http://127.0.0.1:9999/master/abc.m3u8',
          headers: const {},
        )).called(1);
    verify(engine.play).called(1);
  });

  testWidgets('startEpisode used for TV requests', (tester) async {
    final controller = _ControllerMock();
    final engine = _EngineMock();
    when(() => controller.startEpisode(tmdbId: 1, season: 1, episode: 1))
        .thenAnswer((_) async => 'http://127.0.0.1:9999/master/xyz.m3u8');
    when(() => engine.open(any(), headers: any(named: 'headers')))
        .thenAnswer((_) {});
    when(engine.play).thenAnswer((_) async {});
    when(engine.pause).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [
        playControllerProvider.overrideWith((_) async => controller),
        playerEngineProvider.overrideWith((_) => engine),
      ],
      child: MaterialApp(
        home: WatchPage(
          request: const PlaybackRequest(
            tmdbId: 1,
            mediaType: 'tv',
            season: 1,
            episode: 1,
          ),
          videoBuilder: (_) => const SizedBox.shrink(),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    verify(() => controller.startEpisode(tmdbId: 1, season: 1, episode: 1))
        .called(1);
  });

  testWidgets('error state shown when startMovie throws', (tester) async {
    final controller = _ControllerMock();
    final engine = _EngineMock();
    when(() => controller.startMovie(tmdbId: 1))
        .thenThrow(StateError('no plugin available'));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        playControllerProvider.overrideWith((_) async => controller),
        playerEngineProvider.overrideWith((_) => engine),
      ],
      child: MaterialApp(
        home: WatchPage(
          request: const PlaybackRequest(tmdbId: 1, mediaType: 'movie'),
          videoBuilder: (_) => const SizedBox.shrink(),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('no plugin available'), findsOneWidget);
  });
}
