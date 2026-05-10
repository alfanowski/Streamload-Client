// lib/domain/models/settings.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
class UserSettingsModel with _$UserSettingsModel {
  const factory UserSettingsModel({
    @JsonKey(name: 'audio_pref_lang') @Default('ita') String audioPrefLang,
    @JsonKey(name: 'subs_pref_lang') @Default('ita') String subsPrefLang,
    @JsonKey(name: 'quality_cap_height') int? qualityCapHeight,
    @JsonKey(name: 'autoplay_next_episode') @Default(true) bool autoplayNextEpisode,
    @JsonKey(name: 'skip_intro') @Default(true) bool skipIntro,
    @Default('auto') String theme,
    @Default('it-IT') String locale,
  }) = _UserSettingsModel;

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsModelFromJson(json);
}
