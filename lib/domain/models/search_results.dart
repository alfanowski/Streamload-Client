// lib/domain/models/search_results.dart
//
// Typed search payload. PS-2 — /api/search now returns BOTH title matches
// and people (actors / directors). `SearchResults` aggregates the two so a
// single search round-trip can render an actor-first results view.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_summary.dart';

part 'search_results.freezed.dart';
part 'search_results.g.dart';

/// A person match from /api/search — actor, director, writer, producer.
/// `knownFor` carries up to 3 of their most famous title names (pulled
/// inline from TMDB's multi-search payload, no extra round-trip).
@freezed
class SearchPersonResult with _$SearchPersonResult {
  const factory SearchPersonResult({
    @JsonKey(name: 'tmdb_id') required int tmdbId,
    required String name,
    @JsonKey(name: 'profile_url') String? profileUrl,
    String? department,
    @JsonKey(name: 'known_for') @Default(<String>[]) List<String> knownFor,
  }) = _SearchPersonResult;

  factory SearchPersonResult.fromJson(Map<String, dynamic> json) =>
      _$SearchPersonResultFromJson(json);
}

/// Aggregate search response: title matches plus people. Either list may
/// be empty.
@freezed
class SearchResults with _$SearchResults {
  const factory SearchResults({
    @Default(<MediaSummary>[]) List<MediaSummary> titles,
    @Default(<SearchPersonResult>[]) List<SearchPersonResult> people,
  }) = _SearchResults;
}
