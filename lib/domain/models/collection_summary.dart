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
    @JsonKey(name: 'media_type') required String mediaType,
    @Default(<MediaSummary>[]) List<MediaSummary> items,
  }) = _CollectionSummary;

  factory CollectionSummary.fromJson(Map<String, dynamic> json) =>
      _$CollectionSummaryFromJson(json);
}
