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
      number: (json['season_number'] as num).toInt(),
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => EpisodeInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EpisodeInfo>[],
    );

Map<String, dynamic> _$$SeasonInfoImplToJson(_$SeasonInfoImpl instance) =>
    <String, dynamic>{
      'season_number': instance.number,
      'episodes': instance.episodes,
    };

_$EpisodeInfoImpl _$$EpisodeInfoImplFromJson(Map<String, dynamic> json) =>
    _$EpisodeInfoImpl(
      episode: (json['episode_number'] as num).toInt(),
      title: json['title'] as String?,
      overview: json['overview'] as String?,
      stillUrl: json['still_url'] as String?,
      runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt(),
      airDate: json['air_date'] as String?,
    );

Map<String, dynamic> _$$EpisodeInfoImplToJson(_$EpisodeInfoImpl instance) =>
    <String, dynamic>{
      'episode_number': instance.episode,
      'title': instance.title,
      'overview': instance.overview,
      'still_url': instance.stillUrl,
      'runtime_minutes': instance.runtimeMinutes,
      'air_date': instance.airDate,
    };
