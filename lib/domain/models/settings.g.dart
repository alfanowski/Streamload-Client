// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsModelImpl _$$UserSettingsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$UserSettingsModelImpl(
      audioPrefLang: json['audio_pref_lang'] as String? ?? 'ita',
      subsPrefLang: json['subs_pref_lang'] as String? ?? 'ita',
      qualityCapHeight: (json['quality_cap_height'] as num?)?.toInt(),
      autoplayNextEpisode: json['autoplay_next_episode'] as bool? ?? true,
      skipIntro: json['skip_intro'] as bool? ?? true,
      theme: json['theme'] as String? ?? 'auto',
      locale: json['locale'] as String? ?? 'it-IT',
    );

Map<String, dynamic> _$$UserSettingsModelImplToJson(
        _$UserSettingsModelImpl instance) =>
    <String, dynamic>{
      'audio_pref_lang': instance.audioPrefLang,
      'subs_pref_lang': instance.subsPrefLang,
      'quality_cap_height': instance.qualityCapHeight,
      'autoplay_next_episode': instance.autoplayNextEpisode,
      'skip_intro': instance.skipIntro,
      'theme': instance.theme,
      'locale': instance.locale,
    };
