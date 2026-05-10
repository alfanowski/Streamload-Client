// lib/state/progress_tracker.dart
import 'dart:async';

import '../data/remote/endpoints/progress_api.dart';

/// Listens to position + duration streams from the player and POSTs
/// to /api/progress every [flushInterval] while playback is advancing.
///
/// Flush is skipped when:
/// - The position has not advanced since the last flush
///   (`_lastSeen == _lastFlushed`).
/// - Duration is unknown / zero (`_duration <= zero`).
///
/// Network errors are swallowed — the next tick retries automatically.
class ProgressTracker {
  ProgressTracker({
    required this.api,
    required this.tmdbId,
    required this.mediaType,
    required this.positionStream,
    required this.durationStream,
    this.seasonNumber,
    this.episodeNumber,
    this.flushInterval = const Duration(seconds: 5),
  });

  final ProgressApi api;
  final int tmdbId;
  final String mediaType;
  final int? seasonNumber;
  final int? episodeNumber;
  final Stream<Duration> positionStream;
  final Stream<Duration> durationStream;
  final Duration flushInterval;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  Timer? _flushTimer;

  Duration _lastSeen = Duration.zero;
  // Sentinel: -1s ensures the first flush is not suppressed even if position
  // happens to be zero at flush time.
  Duration _lastFlushed = const Duration(seconds: -1);
  Duration _duration = Duration.zero;

  void start() {
    _posSub = positionStream.listen((d) => _lastSeen = d);
    _durSub = durationStream.listen((d) => _duration = d);
    _flushTimer = Timer.periodic(flushInterval, (_) => _flush());
  }

  Future<void> _flush() async {
    if (_lastSeen == _lastFlushed) return;
    if (_duration <= Duration.zero) return;
    final pos = _lastSeen;
    final dur = _duration;
    try {
      await api.post(
        tmdbId: tmdbId,
        mediaType: mediaType,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        positionSeconds: pos.inSeconds,
        durationSeconds: dur.inSeconds,
      );
      _lastFlushed = pos;
    } catch (_) {
      // Swallow — next tick retries.
    }
  }

  void stop() {
    _flushTimer?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    // Best-effort final flush (fire-and-forget).
    _flush();
  }
}
