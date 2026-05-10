// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continue_watching_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContinueWatchingItemImpl _$$ContinueWatchingItemImplFromJson(
        Map<String, dynamic> json) =>
    _$ContinueWatchingItemImpl(
      tmdbId: (json['tmdb_id'] as num).toInt(),
      mediaType: json['media_type'] as String,
      title: json['title'] as String,
      posterUrl: json['poster_url'] as String?,
      seasonNumber: (json['season_number'] as num?)?.toInt(),
      episodeNumber: (json['episode_number'] as num?)?.toInt(),
      positionSeconds: (json['position_seconds'] as num).toInt(),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
    );

Map<String, dynamic> _$$ContinueWatchingItemImplToJson(
        _$ContinueWatchingItemImpl instance) =>
    <String, dynamic>{
      'tmdb_id': instance.tmdbId,
      'media_type': instance.mediaType,
      'title': instance.title,
      'poster_url': instance.posterUrl,
      'season_number': instance.seasonNumber,
      'episode_number': instance.episodeNumber,
      'position_seconds': instance.positionSeconds,
      'duration_seconds': instance.durationSeconds,
    };
