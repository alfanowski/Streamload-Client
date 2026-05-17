// lib/domain/models/person.dart
//
// Pass 3 CAST-2 — bio + identity fields for an actor / director's
// dedicated page. Mirrors the backend's PersonResponse 1:1.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'person.freezed.dart';
part 'person.g.dart';

@freezed
class Person with _$Person {
  const factory Person({
    @JsonKey(name: 'tmdb_id') required int tmdbId,
    required String name,
    String? biography,
    String? birthday,            // ISO "YYYY-MM-DD"
    String? deathday,            // ISO date or null
    @JsonKey(name: 'place_of_birth') String? placeOfBirth,
    @JsonKey(name: 'profile_url') String? profileUrl,
    @JsonKey(name: 'also_known_as')
    @Default(<String>[]) List<String> alsoKnownAs,
    @JsonKey(name: 'known_for_department') String? knownForDepartment,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) =>
      _$PersonFromJson(json);
}
