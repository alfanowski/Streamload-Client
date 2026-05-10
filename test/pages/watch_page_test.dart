// test/pages/watch_page_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/progress_api.dart';
import 'package:streamload_client/domain/models/playback_request.dart';
import 'package:streamload_client/domain/play_title.dart';
import 'package:streamload_client/player/engine.dart';
import 'package:streamload_client/presentation/pages/watch_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/play_controller_provider.dart';
import 'package:streamload_client/state/player_engine_provider.dart';

class _ControllerMock extends Mock implements PlayController {}

class _EngineMock extends Mock implements PlayerEngine {}

class _ProgressApiMock extends Mock implements ProgressApi {}

/// Returns engine + progress mocks pre-stubbed for the happy path (play succeeds,
/// tracker subscribes to streams, no actual POSTs expected in these tests).
({_EngineMock engine, _ProgressApiMock progressApi}) _happyMocks() {
  final engine = _EngineMock();
  final progressApi = _ProgressApiMock();

  when(() => engine.open(any(), headers: any(named: 'headers'))).thenReturn(null);
  when(engine.play).thenAnswer((_) async {});
  when(engine.pause).thenAnswer((_) async {});
  when(() => engine.positionStream)
      .thenAnswer((_) => const Stream.empty());
  when(() => engine.durationStream)
      .thenAnswer((_) => const Stream.empty());

  // progress api may be called (but we don't assert it in lifecycle tests).
  when(
    () => progressApi.post(
      tmdbId: any(named: 'tmdbId'),
      mediaType: any(named: 'mediaType'),
      seasonNumber: any(named: 'seasonNumber'),
      episodeNumber: any(named: 'episodeNumber'),
      positionSeconds: any(named: 'positionSeconds'),
      durationSeconds: any(named: 'durationSeconds'),
    ),
  ).thenAnswer((_) async => {});

  return (engine: engine, progressApi: progressApi);
}

void main() {
  setUpAll(() {
    registerFallbackValue(const Duration());
  });

  testWidgets('on mount calls startMovie + engine.open + play', (tester) async {
    final controller = _ControllerMock();
    final (:engine, :progressApi) = _happyMocks();

    when(() => controller.startMovie(tmdbId: 42))
        .thenAnswer((_) async => 'http://127.0.0.1:9999/master/abc.m3u8');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        playControllerProvider.overrideWith((_) async => controller),
        playerEngineProvider.overrideWith((_) => engine),
        progressApiProvider.overrideWith((_) async => progressApi),
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
    verify(
      () => engine.open(
        'http://127.0.0.1:9999/master/abc.m3u8',
        headers: const {},
      ),
    ).called(1);
    verify(engine.play).called(1);
  });

  testWidgets('startEpisode used for TV requests', (tester) async {
    final controller = _ControllerMock();
    final (:engine, :progressApi) = _happyMocks();

    when(() => controller.startEpisode(tmdbId: 1, season: 1, episode: 1))
        .thenAnswer((_) async => 'http://127.0.0.1:9999/master/xyz.m3u8');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        playControllerProvider.overrideWith((_) async => controller),
        playerEngineProvider.overrideWith((_) => engine),
        progressApiProvider.overrideWith((_) async => progressApi),
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
        // progressApiProvider not needed — error is thrown before we reach it.
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
