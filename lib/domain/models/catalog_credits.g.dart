// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_credits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CatalogCreditPersonImpl _$$CatalogCreditPersonImplFromJson(
        Map<String, dynamic> json) =>
    _$CatalogCreditPersonImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      character: json['character'] as String?,
      job: json['job'] as String?,
      profileUrl: json['profile_url'] as String?,
      order: (json['order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CatalogCreditPersonImplToJson(
        _$CatalogCreditPersonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'character': instance.character,
      'job': instance.job,
      'profile_url': instance.profileUrl,
      'order': instance.order,
    };

_$CatalogCreditsImpl _$$CatalogCreditsImplFromJson(Map<String, dynamic> json) =>
    _$CatalogCreditsImpl(
      cast: (json['cast'] as List<dynamic>?)
              ?.map((e) =>
                  CatalogCreditPerson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CatalogCreditPerson>[],
      crew: (json['crew'] as List<dynamic>?)
              ?.map((e) =>
                  CatalogCreditPerson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CatalogCreditPerson>[],
    );

Map<String, dynamic> _$$CatalogCreditsImplToJson(
        _$CatalogCreditsImpl instance) =>
    <String, dynamic>{
      'cast': instance.cast,
      'crew': instance.crew,
    };
