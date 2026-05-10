// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MediaSummaryImpl _$$MediaSummaryImplFromJson(Map<String, dynamic> json) =>
    _$MediaSummaryImpl(
      tmdbId: (json['tmdb_id'] as num).toInt(),
      mediaType: json['media_type'] as String,
      title: json['title'] as String,
      year: (json['year'] as num?)?.toInt(),
      posterUrl: json['poster_url'] as String?,
      backdropUrl: json['backdrop_url'] as String?,
    );

Map<String, dynamic> _$$MediaSummaryImplToJson(_$MediaSummaryImpl instance) =>
    <String, dynamic>{
      'tmdb_id': instance.tmdbId,
      'media_type': instance.mediaType,
      'title': instance.title,
      'year': instance.year,
      'poster_url': instance.posterUrl,
      'backdrop_url': instance.backdropUrl,
    };
