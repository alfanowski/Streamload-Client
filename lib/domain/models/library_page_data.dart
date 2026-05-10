// lib/domain/models/library_page_data.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_summary.dart';

part 'library_page_data.freezed.dart';
part 'library_page_data.g.dart';

@freezed
class LibraryPageData with _$LibraryPageData {
  const factory LibraryPageData({
    required List<MediaSummary> items,
    required int page,
    @JsonKey(name: 'per_page') required int perPage,
    required int total,
  }) = _LibraryPageData;

  factory LibraryPageData.fromJson(Map<String, dynamic> json) =>
      _$LibraryPageDataFromJson(json);
}
