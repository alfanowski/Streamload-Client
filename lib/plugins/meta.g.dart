// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PluginMetaImpl _$$PluginMetaImplFromJson(Map<String, dynamic> json) =>
    _$PluginMetaImpl(
      shortName: json['short_name'] as String,
      displayName: json['display_name'] as String,
      version: json['version'] as String,
      apiVersion: (json['api_version'] as num).toInt(),
      capabilities: (json['capabilities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      minAppVersion: json['min_app_version'] as String?,
    );

Map<String, dynamic> _$$PluginMetaImplToJson(_$PluginMetaImpl instance) =>
    <String, dynamic>{
      'short_name': instance.shortName,
      'display_name': instance.displayName,
      'version': instance.version,
      'api_version': instance.apiVersion,
      'capabilities': instance.capabilities,
      'min_app_version': instance.minAppVersion,
    };
