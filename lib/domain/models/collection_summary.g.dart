// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CollectionSummaryImpl _$$CollectionSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$CollectionSummaryImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      mediaType: json['media_type'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MediaSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MediaSummary>[],
    );

Map<String, dynamic> _$$CollectionSummaryImplToJson(
        _$CollectionSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'media_type': instance.mediaType,
      'items': instance.items,
    };
