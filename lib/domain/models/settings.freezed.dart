// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserSettingsModel _$UserSettingsModelFromJson(Map<String, dynamic> json) {
  return _UserSettingsModel.fromJson(json);
}

/// @nodoc
mixin _$UserSettingsModel {
  @JsonKey(name: 'audio_pref_lang')
  String get audioPrefLang => throw _privateConstructorUsedError;
  @JsonKey(name: 'subs_pref_lang')
  String get subsPrefLang => throw _privateConstructorUsedError;
  @JsonKey(name: 'quality_cap_height')
  int? get qualityCapHeight => throw _privateConstructorUsedError;
  @JsonKey(name: 'autoplay_next_episode')
  bool get autoplayNextEpisode => throw _privateConstructorUsedError;
  @JsonKey(name: 'skip_intro')
  bool get skipIntro => throw _privateConstructorUsedError;
  String get theme => throw _privateConstructorUsedError;
  String get locale => throw _privateConstructorUsedError;

  /// Serializes this UserSettingsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSettingsModelCopyWith<UserSettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsModelCopyWith<$Res> {
  factory $UserSettingsModelCopyWith(
          UserSettingsModel value, $Res Function(UserSettingsModel) then) =
      _$UserSettingsModelCopyWithImpl<$Res, UserSettingsModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'audio_pref_lang') String audioPrefLang,
      @JsonKey(name: 'subs_pref_lang') String subsPrefLang,
      @JsonKey(name: 'quality_cap_height') int? qualityCapHeight,
      @JsonKey(name: 'autoplay_next_episode') bool autoplayNextEpisode,
      @JsonKey(name: 'skip_intro') bool skipIntro,
      String theme,
      String locale});
}

/// @nodoc
class _$UserSettingsModelCopyWithImpl<$Res, $Val extends UserSettingsModel>
    implements $UserSettingsModelCopyWith<$Res> {
  _$UserSettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audioPrefLang = null,
    Object? subsPrefLang = null,
    Object? qualityCapHeight = freezed,
    Object? autoplayNextEpisode = null,
    Object? skipIntro = null,
    Object? theme = null,
    Object? locale = null,
  }) {
    return _then(_value.copyWith(
      audioPrefLang: null == audioPrefLang
          ? _value.audioPrefLang
          : audioPrefLang // ignore: cast_nullable_to_non_nullable
              as String,
      subsPrefLang: null == subsPrefLang
          ? _value.subsPrefLang
          : subsPrefLang // ignore: cast_nullable_to_non_nullable
              as String,
      qualityCapHeight: freezed == qualityCapHeight
          ? _value.qualityCapHeight
          : qualityCapHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      autoplayNextEpisode: null == autoplayNextEpisode
          ? _value.autoplayNextEpisode
          : autoplayNextEpisode // ignore: cast_nullable_to_non_nullable
              as bool,
      skipIntro: null == skipIntro
          ? _value.skipIntro
          : skipIntro // ignore: cast_nullable_to_non_nullable
              as bool,
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserSettingsModelImplCopyWith<$Res>
    implements $UserSettingsModelCopyWith<$Res> {
  factory _$$UserSettingsModelImplCopyWith(_$UserSettingsModelImpl value,
          $Res Function(_$UserSettingsModelImpl) then) =
      __$$UserSettingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'audio_pref_lang') String audioPrefLang,
      @JsonKey(name: 'subs_pref_lang') String subsPrefLang,
      @JsonKey(name: 'quality_cap_height') int? qualityCapHeight,
      @JsonKey(name: 'autoplay_next_episode') bool autoplayNextEpisode,
      @JsonKey(name: 'skip_intro') bool skipIntro,
      String theme,
      String locale});
}

/// @nodoc
class __$$UserSettingsModelImplCopyWithImpl<$Res>
    extends _$UserSettingsModelCopyWithImpl<$Res, _$UserSettingsModelImpl>
    implements _$$UserSettingsModelImplCopyWith<$Res> {
  __$$UserSettingsModelImplCopyWithImpl(_$UserSettingsModelImpl _value,
      $Res Function(_$UserSettingsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audioPrefLang = null,
    Object? subsPrefLang = null,
    Object? qualityCapHeight = freezed,
    Object? autoplayNextEpisode = null,
    Object? skipIntro = null,
    Object? theme = null,
    Object? locale = null,
  }) {
    return _then(_$UserSettingsModelImpl(
      audioPrefLang: null == audioPrefLang
          ? _value.audioPrefLang
          : audioPrefLang // ignore: cast_nullable_to_non_nullable
              as String,
      subsPrefLang: null == subsPrefLang
          ? _value.subsPrefLang
          : subsPrefLang // ignore: cast_nullable_to_non_nullable
              as String,
      qualityCapHeight: freezed == qualityCapHeight
          ? _value.qualityCapHeight
          : qualityCapHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      autoplayNextEpisode: null == autoplayNextEpisode
          ? _value.autoplayNextEpisode
          : autoplayNextEpisode // ignore: cast_nullable_to_non_nullable
              as bool,
      skipIntro: null == skipIntro
          ? _value.skipIntro
          : skipIntro // ignore: cast_nullable_to_non_nullable
              as bool,
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsModelImpl implements _UserSettingsModel {
  const _$UserSettingsModelImpl(
      {@JsonKey(name: 'audio_pref_lang') this.audioPrefLang = 'ita',
      @JsonKey(name: 'subs_pref_lang') this.subsPrefLang = 'ita',
      @JsonKey(name: 'quality_cap_height') this.qualityCapHeight,
      @JsonKey(name: 'autoplay_next_episode') this.autoplayNextEpisode = true,
      @JsonKey(name: 'skip_intro') this.skipIntro = true,
      this.theme = 'auto',
      this.locale = 'it-IT'});

  factory _$UserSettingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSettingsModelImplFromJson(json);

  @override
  @JsonKey(name: 'audio_pref_lang')
  final String audioPrefLang;
  @override
  @JsonKey(name: 'subs_pref_lang')
  final String subsPrefLang;
  @override
  @JsonKey(name: 'quality_cap_height')
  final int? qualityCapHeight;
  @override
  @JsonKey(name: 'autoplay_next_episode')
  final bool autoplayNextEpisode;
  @override
  @JsonKey(name: 'skip_intro')
  final bool skipIntro;
  @override
  @JsonKey()
  final String theme;
  @override
  @JsonKey()
  final String locale;

  @override
  String toString() {
    return 'UserSettingsModel(audioPrefLang: $audioPrefLang, subsPrefLang: $subsPrefLang, qualityCapHeight: $qualityCapHeight, autoplayNextEpisode: $autoplayNextEpisode, skipIntro: $skipIntro, theme: $theme, locale: $locale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsModelImpl &&
            (identical(other.audioPrefLang, audioPrefLang) ||
                other.audioPrefLang == audioPrefLang) &&
            (identical(other.subsPrefLang, subsPrefLang) ||
                other.subsPrefLang == subsPrefLang) &&
            (identical(other.qualityCapHeight, qualityCapHeight) ||
                other.qualityCapHeight == qualityCapHeight) &&
            (identical(other.autoplayNextEpisode, autoplayNextEpisode) ||
                other.autoplayNextEpisode == autoplayNextEpisode) &&
            (identical(other.skipIntro, skipIntro) ||
                other.skipIntro == skipIntro) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.locale, locale) || other.locale == locale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, audioPrefLang, subsPrefLang,
      qualityCapHeight, autoplayNextEpisode, skipIntro, theme, locale);

  /// Create a copy of UserSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsModelImplCopyWith<_$UserSettingsModelImpl> get copyWith =>
      __$$UserSettingsModelImplCopyWithImpl<_$UserSettingsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSettingsModelImplToJson(
      this,
    );
  }
}

abstract class _UserSettingsModel implements UserSettingsModel {
  const factory _UserSettingsModel(
      {@JsonKey(name: 'audio_pref_lang') final String audioPrefLang,
      @JsonKey(name: 'subs_pref_lang') final String subsPrefLang,
      @JsonKey(name: 'quality_cap_height') final int? qualityCapHeight,
      @JsonKey(name: 'autoplay_next_episode') final bool autoplayNextEpisode,
      @JsonKey(name: 'skip_intro') final bool skipIntro,
      final String theme,
      final String locale}) = _$UserSettingsModelImpl;

  factory _UserSettingsModel.fromJson(Map<String, dynamic> json) =
      _$UserSettingsModelImpl.fromJson;

  @override
  @JsonKey(name: 'audio_pref_lang')
  String get audioPrefLang;
  @override
  @JsonKey(name: 'subs_pref_lang')
  String get subsPrefLang;
  @override
  @JsonKey(name: 'quality_cap_height')
  int? get qualityCapHeight;
  @override
  @JsonKey(name: 'autoplay_next_episode')
  bool get autoplayNextEpisode;
  @override
  @JsonKey(name: 'skip_intro')
  bool get skipIntro;
  @override
  String get theme;
  @override
  String get locale;

  /// Create a copy of UserSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSettingsModelImplCopyWith<_$UserSettingsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
