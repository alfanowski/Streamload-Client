// test/state/progress_tracker_test.dart
import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/progress_api.dart';
import 'package:streamload_client/state/progress_tracker.dart';

class _ProgressApiMock extends Mock implements ProgressApi {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Duration());
  });

  test('emits POST /progress every 5 seconds while position advances', () {
    fakeAsync((async) {
      final api = _ProgressApiMock();
      when(
        () => api.post(
          tmdbId: any(named: 'tmdbId'),
          mediaType: any(named: 'mediaType'),
          seasonNumber: any(named: 'seasonNumber'),
          episodeNumber: any(named: 'episodeNumber'),
          positionSeconds: any(named: 'positionSeconds'),
          durationSeconds: any(named: 'durationSeconds'),
        ),
      ).thenAnswer((_) async => {});

      final positionCtrl = StreamController<Duration>.broadcast();
      final durationCtrl = StreamController<Duration>.broadcast();

      final tracker = ProgressTracker(
        api: api,
        tmdbId: 1,
        mediaType: 'movie',
        positionStream: positionCtrl.stream,
        durationStream: durationCtrl.stream,
        flushInterval: const Duration(seconds: 5),
      );
      tracker.start();

      // Emit duration AFTER start() so the subscription is active.
      durationCtrl.add(const Duration(seconds: 600));
      positionCtrl.add(const Duration(seconds: 10));
      async.elapse(const Duration(seconds: 6));
      verify(
        () => api.post(
          tmdbId: 1,
          mediaType: 'movie',
          seasonNumber: null,
          episodeNumber: null,
          positionSeconds: 10,
          durationSeconds: 600,
        ),
      ).called(1);

      positionCtrl.add(const Duration(seconds: 30));
      async.elapse(const Duration(seconds: 6));
      verify(
        () => api.post(
          tmdbId: 1,
          mediaType: 'movie',
          seasonNumber: null,
          episodeNumber: null,
          positionSeconds: 30,
          durationSeconds: 600,
        ),
      ).called(1);

      tracker.stop();
    });
  });

  test('does not flush when position is unchanged since last flush', () {
    fakeAsync((async) {
      final api = _ProgressApiMock();
      when(
        () => api.post(
          tmdbId: any(named: 'tmdbId'),
          mediaType: any(named: 'mediaType'),
          seasonNumber: any(named: 'seasonNumber'),
          episodeNumber: any(named: 'episodeNumber'),
          positionSeconds: any(named: 'positionSeconds'),
          durationSeconds: any(named: 'durationSeconds'),
        ),
      ).thenAnswer((_) async => {});

      final positionCtrl = StreamController<Duration>.broadcast();
      final durationCtrl = StreamController<Duration>.broadcast();

      final tracker = ProgressTracker(
        api: api,
        tmdbId: 1,
        mediaType: 'movie',
        positionStream: positionCtrl.stream,
        durationStream: durationCtrl.stream,
        flushInterval: const Duration(seconds: 5),
      );
      tracker.start();

      durationCtrl.add(const Duration(seconds: 600));
      positionCtrl.add(const Duration(seconds: 10));
      async.elapse(const Duration(seconds: 6)); // 1 flush
      async.elapse(const Duration(seconds: 6)); // no new position → no flush

      verify(
        () => api.post(
          tmdbId: any(named: 'tmdbId'),
          mediaType: any(named: 'mediaType'),
          seasonNumber: any(named: 'seasonNumber'),
          episodeNumber: any(named: 'episodeNumber'),
          positionSeconds: any(named: 'positionSeconds'),
          durationSeconds: any(named: 'durationSeconds'),
        ),
      ).called(1);

      tracker.stop();
    });
  });

  test('does not flush when duration is zero', () {
    fakeAsync((async) {
      final api = _ProgressApiMock();

      final positionCtrl = StreamController<Duration>.broadcast();
      final durationCtrl = StreamController<Duration>.broadcast();
      // Do NOT emit a duration — it stays at zero.

      final tracker = ProgressTracker(
        api: api,
        tmdbId: 1,
        mediaType: 'movie',
        positionStream: positionCtrl.stream,
        durationStream: durationCtrl.stream,
        flushInterval: const Duration(seconds: 5),
      );
      tracker.start();

      positionCtrl.add(const Duration(seconds: 10));
      async.elapse(const Duration(seconds: 6));

      verifyNever(
        () => api.post(
          tmdbId: any(named: 'tmdbId'),
          mediaType: any(named: 'mediaType'),
          seasonNumber: any(named: 'seasonNumber'),
          episodeNumber: any(named: 'episodeNumber'),
          positionSeconds: any(named: 'positionSeconds'),
          durationSeconds: any(named: 'durationSeconds'),
        ),
      );

      tracker.stop();
    });
  });

  test('passes seasonNumber and episodeNumber for TV content', () {
    fakeAsync((async) {
      final api = _ProgressApiMock();
      when(
        () => api.post(
          tmdbId: any(named: 'tmdbId'),
          mediaType: any(named: 'mediaType'),
          seasonNumber: any(named: 'seasonNumber'),
          episodeNumber: any(named: 'episodeNumber'),
          positionSeconds: any(named: 'positionSeconds'),
          durationSeconds: any(named: 'durationSeconds'),
        ),
      ).thenAnswer((_) async => {});

      final positionCtrl = StreamController<Duration>.broadcast();
      final durationCtrl = StreamController<Duration>.broadcast();

      final tracker = ProgressTracker(
        api: api,
        tmdbId: 1396,
        mediaType: 'tv',
        seasonNumber: 1,
        episodeNumber: 1,
        positionStream: positionCtrl.stream,
        durationStream: durationCtrl.stream,
        flushInterval: const Duration(seconds: 5),
      );
      tracker.start();

      durationCtrl.add(const Duration(minutes: 45));
      positionCtrl.add(const Duration(seconds: 60));
      async.elapse(const Duration(seconds: 6));

      verify(
        () => api.post(
          tmdbId: 1396,
          mediaType: 'tv',
          seasonNumber: 1,
          episodeNumber: 1,
          positionSeconds: 60,
          durationSeconds: 2700,
        ),
      ).called(1);

      tracker.stop();
    });
  });
}
