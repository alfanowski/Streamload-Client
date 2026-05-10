// lib/domain/models/continue_watching_item.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'continue_watching_item.freezed.dart';
part 'continue_watching_item.g.dart';

@freezed
class ContinueWatchingItem with _$ContinueWatchingItem {
  const factory ContinueWatchingItem({
    @JsonKey(name: 'tmdb_id') required int tmdbId,
    @JsonKey(name: 'media_type') required String mediaType,
    required String title,
    @JsonKey(name: 'poster_url') String? posterUrl,
    @JsonKey(name: 'season_number') int? seasonNumber,
    @JsonKey(name: 'episode_number') int? episodeNumber,
    @JsonKey(name: 'position_seconds') required int positionSeconds,
    @JsonKey(name: 'duration_seconds') required int durationSeconds,
  }) = _ContinueWatchingItem;

  factory ContinueWatchingItem.fromJson(Map<String, dynamic> json) =>
      _$ContinueWatchingItemFromJson(json);
}
