// lib/domain/models/media_summary.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_summary.freezed.dart';
part 'media_summary.g.dart';

@freezed
class MediaSummary with _$MediaSummary {
  const factory MediaSummary({
    @JsonKey(name: 'tmdb_id') required int tmdbId,
    @JsonKey(name: 'media_type') required String mediaType,
    required String title,
    int? year,
    @JsonKey(name: 'poster_url') String? posterUrl,
    @JsonKey(name: 'backdrop_url') String? backdropUrl,
  }) = _MediaSummary;

  factory MediaSummary.fromJson(Map<String, dynamic> json) =>
      _$MediaSummaryFromJson(json);
}
