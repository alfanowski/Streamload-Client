// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episodes_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EpisodesResponseImpl _$$EpisodesResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$EpisodesResponseImpl(
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((e) => SeasonInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SeasonInfo>[],
    );

Map<String, dynamic> _$$EpisodesResponseImplToJson(
        _$EpisodesResponseImpl instance) =>
    <String, dynamic>{
      'seasons': instance.seasons,
    };

_$SeasonInfoImpl _$$SeasonInfoImplFromJson(Map<String, dynamic> json) =>
    _$SeasonInfoImpl(
      number: (json['number'] as num).toInt(),
      name: json['name'] as String?,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => EpisodeInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EpisodeInfo>[],
    );

Map<String, dynamic> _$$SeasonInfoImplToJson(_$SeasonInfoImpl instance) =>
    <String, dynamic>{
      'number': instance.number,
      'name': instance.name,
      'episodes': instance.episodes,
    };

_$EpisodeInfoImpl _$$EpisodeInfoImplFromJson(Map<String, dynamic> json) =>
    _$EpisodeInfoImpl(
      season: (json['season'] as num).toInt(),
      episode: (json['episode'] as num).toInt(),
      title: json['title'] as String,
      overview: json['overview'] as String?,
      stillUrl: json['still_url'] as String?,
      runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt(),
      airDate: json['air_date'] as String?,
    );

Map<String, dynamic> _$$EpisodeInfoImplToJson(_$EpisodeInfoImpl instance) =>
    <String, dynamic>{
      'season': instance.season,
      'episode': instance.episode,
      'title': instance.title,
      'overview': instance.overview,
      'still_url': instance.stillUrl,
      'runtime_minutes': instance.runtimeMinutes,
      'air_date': instance.airDate,
    };
