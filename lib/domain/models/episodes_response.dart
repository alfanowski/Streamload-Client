// lib/domain/models/episodes_response.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'episodes_response.freezed.dart';
part 'episodes_response.g.dart';

@freezed
class EpisodesResponse with _$EpisodesResponse {
  const factory EpisodesResponse({
    @Default(<SeasonInfo>[]) List<SeasonInfo> seasons,
  }) = _EpisodesResponse;

  factory EpisodesResponse.fromJson(Map<String, dynamic> json) =>
      _$EpisodesResponseFromJson(json);
}

@freezed
class SeasonInfo with _$SeasonInfo {
  const factory SeasonInfo({
    @JsonKey(name: 'season_number') required int number,
    @Default(<EpisodeInfo>[]) List<EpisodeInfo> episodes,
  }) = _SeasonInfo;

  factory SeasonInfo.fromJson(Map<String, dynamic> json) =>
      _$SeasonInfoFromJson(json);
}

@freezed
class EpisodeInfo with _$EpisodeInfo {
  const factory EpisodeInfo({
    // Backend keys: episode_number is required; title is nullable.
    // The season number isn't repeated per episode — derive from the parent
    // SeasonInfo when constructing watch URLs.
    @JsonKey(name: 'episode_number') required int episode,
    String? title,
    String? overview,
    @JsonKey(name: 'still_url') String? stillUrl,
    @JsonKey(name: 'runtime_minutes') int? runtimeMinutes,
    @JsonKey(name: 'air_date') String? airDate,
  }) = _EpisodeInfo;

  factory EpisodeInfo.fromJson(Map<String, dynamic> json) =>
      _$EpisodeInfoFromJson(json);
}
