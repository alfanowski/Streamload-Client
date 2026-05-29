// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_results.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchPersonResultImpl _$$SearchPersonResultImplFromJson(
        Map<String, dynamic> json) =>
    _$SearchPersonResultImpl(
      tmdbId: (json['tmdb_id'] as num).toInt(),
      name: json['name'] as String,
      profileUrl: json['profile_url'] as String?,
      department: json['department'] as String?,
      knownFor: (json['known_for'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$SearchPersonResultImplToJson(
        _$SearchPersonResultImpl instance) =>
    <String, dynamic>{
      'tmdb_id': instance.tmdbId,
      'name': instance.name,
      'profile_url': instance.profileUrl,
      'department': instance.department,
      'known_for': instance.knownFor,
    };
