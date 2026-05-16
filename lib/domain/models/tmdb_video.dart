// lib/domain/models/tmdb_video.dart
//
// One TMDB ``videos`` entry, scoped to what the v3 hero trailer cares about.
// The backend already filters to ``site == "YouTube"`` so the client only
// ever has to pick the best entry by ``type`` / ``official`` and feed
// ``key`` into the YouTube IFrame Player API.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tmdb_video.freezed.dart';
part 'tmdb_video.g.dart';

@freezed
class TmdbVideo with _$TmdbVideo {
  const factory TmdbVideo({
    /// YouTube video id (the ``v=`` query parameter on watch URLs).
    required String key,

    /// Always ``"YouTube"`` in v3 — the backend strips other sites — but we
    /// keep the field for forward-compat in case we later allow Vimeo embeds.
    required String site,

    /// ``"Trailer" | "Teaser" | "Clip" | "Featurette" | ...`` — driven by TMDB.
    required String type,

    /// ``true`` for studio-published trailers. Preferred when picking which
    /// video to autoplay in the hero.
    required bool official,

    /// Free-text human label ("Official Trailer", "Teaser #2", etc).
    String? name,
  }) = _TmdbVideo;

  factory TmdbVideo.fromJson(Map<String, dynamic> j) => _$TmdbVideoFromJson(j);
}
