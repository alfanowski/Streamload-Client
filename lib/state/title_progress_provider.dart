// lib/state/title_progress_provider.dart
//
// The platform's MEMORY of what you've watched, per title. Drives the title
// page's per-episode watch bars + "already watched" ticks (and the resume
// details). Backed by GET /api/progress/title/{tmdb_id}.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client_provider.dart';
import 'home_rows_provider.dart' show TmdbKey;

/// One episode's (or a movie's) saved watch state.
class EpisodeWatch {
  const EpisodeWatch({
    required this.seasonNumber,
    required this.episodeNumber,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.completed,
  });

  final int seasonNumber;
  final int episodeNumber;
  final int positionSeconds;
  final int durationSeconds;
  final bool completed;

  /// 0..1 watched fraction (1.0 when completed even if duration is unknown).
  double get fraction {
    if (completed) return 1;
    if (durationSeconds <= 0) return 0;
    return (positionSeconds / durationSeconds).clamp(0.0, 1.0);
  }

  /// Minutes left to watch (null when unknown / finished).
  int? get minutesRemaining {
    if (durationSeconds <= 0) return null;
    final left = durationSeconds - positionSeconds;
    if (left <= 0) return null;
    return (left / 60).ceil();
  }
}

/// All saved watch state for a title, keyed by (season, episode).
class TitleProgress {
  const TitleProgress(this._byKey);
  final Map<int, EpisodeWatch> _byKey;

  static int _k(int season, int episode) => season * 100000 + episode;

  /// Watch state for a TV episode, or null if never watched.
  EpisodeWatch? episode(int season, int episode) => _byKey[_k(season, episode)];

  /// Watch state for a movie (stored under season/episode 0).
  EpisodeWatch? get movie => _byKey[_k(0, 0)];

  bool get isEmpty => _byKey.isEmpty;
}

final titleProgressProvider =
    FutureProvider.autoDispose.family<TitleProgress, TmdbKey>((ref, key) async {
  final api = await ref.watch(progressApiProvider.future);
  final raw = await api.titleProgress(key.tmdbId, key.mediaType);
  final map = <int, EpisodeWatch>{};
  for (final r in raw) {
    final season = (r['season_number'] as num?)?.toInt() ?? 0;
    final episode = (r['episode_number'] as num?)?.toInt() ?? 0;
    map[TitleProgress._k(season, episode)] = EpisodeWatch(
      seasonNumber: season,
      episodeNumber: episode,
      positionSeconds: (r['position_seconds'] as num?)?.toInt() ?? 0,
      durationSeconds: (r['duration_seconds'] as num?)?.toInt() ?? 0,
      completed: r['completed'] == true,
    );
  }
  return TitleProgress(map);
});
