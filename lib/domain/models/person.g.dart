// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PersonImpl _$$PersonImplFromJson(Map<String, dynamic> json) => _$PersonImpl(
      tmdbId: (json['tmdb_id'] as num).toInt(),
      name: json['name'] as String,
      biography: json['biography'] as String?,
      birthday: json['birthday'] as String?,
      deathday: json['deathday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      profileUrl: json['profile_url'] as String?,
      alsoKnownAs: (json['also_known_as'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      knownForDepartment: json['known_for_department'] as String?,
    );

Map<String, dynamic> _$$PersonImplToJson(_$PersonImpl instance) =>
    <String, dynamic>{
      'tmdb_id': instance.tmdbId,
      'name': instance.name,
      'biography': instance.biography,
      'birthday': instance.birthday,
      'deathday': instance.deathday,
      'place_of_birth': instance.placeOfBirth,
      'profile_url': instance.profileUrl,
      'also_known_as': instance.alsoKnownAs,
      'known_for_department': instance.knownForDepartment,
    };
