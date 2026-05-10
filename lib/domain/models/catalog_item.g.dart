// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SourceResponseImpl _$$SourceResponseImplFromJson(Map<String, dynamic> json) =>
    _$SourceResponseImpl(
      label: json['label'] as String,
      score: (json['score'] as num).toDouble(),
    );

Map<String, dynamic> _$$SourceResponseImplToJson(
        _$SourceResponseImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'score': instance.score,
    };

_$CatalogItemResponseImpl _$$CatalogItemResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CatalogItemResponseImpl(
      tmdbId: (json['tmdb_id'] as num).toInt(),
      mediaType: json['media_type'] as String,
      title: json['title'] as String,
      originalTitle: json['original_title'] as String?,
      year: (json['year'] as num?)?.toInt(),
      posterUrl: json['poster_url'] as String?,
      backdropUrl: json['backdrop_url'] as String?,
      overview: json['overview'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt(),
      seasonsCount: (json['seasons_count'] as num?)?.toInt(),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => SourceResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CatalogItemResponseImplToJson(
        _$CatalogItemResponseImpl instance) =>
    <String, dynamic>{
      'tmdb_id': instance.tmdbId,
      'media_type': instance.mediaType,
      'title': instance.title,
      'original_title': instance.originalTitle,
      'year': instance.year,
      'poster_url': instance.posterUrl,
      'backdrop_url': instance.backdropUrl,
      'overview': instance.overview,
      'rating': instance.rating,
      'runtime_minutes': instance.runtimeMinutes,
      'seasons_count': instance.seasonsCount,
      'genres': instance.genres,
      'sources': instance.sources,
    };
