// lib/domain/models/catalog_item.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_item.freezed.dart';
part 'catalog_item.g.dart';

@freezed
class SourceResponse with _$SourceResponse {
  const factory SourceResponse({
    required String label,
    required double score,
  }) = _SourceResponse;

  factory SourceResponse.fromJson(Map<String, dynamic> json) =>
      _$SourceResponseFromJson(json);
}

@freezed
class CatalogItemResponse with _$CatalogItemResponse {
  const factory CatalogItemResponse({
    @JsonKey(name: 'tmdb_id') required int tmdbId,
    @JsonKey(name: 'media_type') required String mediaType,
    required String title,
    @JsonKey(name: 'original_title') String? originalTitle,
    int? year,
    @JsonKey(name: 'poster_url') String? posterUrl,
    @JsonKey(name: 'backdrop_url') String? backdropUrl,
    String? overview,
    double? rating,
    @JsonKey(name: 'runtime_minutes') int? runtimeMinutes,
    @JsonKey(name: 'seasons_count') int? seasonsCount,
    @Default([]) List<String> genres,
    @Default([]) List<SourceResponse> sources,
  }) = _CatalogItemResponse;

  factory CatalogItemResponse.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemResponseFromJson(json);
}
