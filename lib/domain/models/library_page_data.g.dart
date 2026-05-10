// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_page_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LibraryPageDataImpl _$$LibraryPageDataImplFromJson(
        Map<String, dynamic> json) =>
    _$LibraryPageDataImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => MediaSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$LibraryPageDataImplToJson(
        _$LibraryPageDataImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'page': instance.page,
      'per_page': instance.perPage,
      'total': instance.total,
    };
