// lib/domain/models/collection_summary.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_summary.dart';

part 'collection_summary.freezed.dart';
part 'collection_summary.g.dart';

@freezed
class CollectionSummary with _$CollectionSummary {
  const factory CollectionSummary({
    required String id,
    required String title,
    // Mixed-type collections (e.g. "Trending today") have null media_type.
    @JsonKey(name: 'media_type') String? mediaType,
    @Default(<MediaSummary>[]) List<MediaSummary> items,
  }) = _CollectionSummary;

  factory CollectionSummary.fromJson(Map<String, dynamic> json) =>
      _$CollectionSummaryFromJson(json);
}
