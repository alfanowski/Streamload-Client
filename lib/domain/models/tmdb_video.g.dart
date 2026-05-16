// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TmdbVideoImpl _$$TmdbVideoImplFromJson(Map<String, dynamic> json) =>
    _$TmdbVideoImpl(
      key: json['key'] as String,
      site: json['site'] as String,
      type: json['type'] as String,
      official: json['official'] as bool,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$TmdbVideoImplToJson(_$TmdbVideoImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'site': instance.site,
      'type': instance.type,
      'official': instance.official,
      'name': instance.name,
    };
