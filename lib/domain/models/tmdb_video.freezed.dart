// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tmdb_video.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TmdbVideo _$TmdbVideoFromJson(Map<String, dynamic> json) {
  return _TmdbVideo.fromJson(json);
}

/// @nodoc
mixin _$TmdbVideo {
  /// YouTube video id (the ``v=`` query parameter on watch URLs).
  String get key => throw _privateConstructorUsedError;

  /// Always ``"YouTube"`` in v3 — the backend strips other sites — but we
  /// keep the field for forward-compat in case we later allow Vimeo embeds.
  String get site => throw _privateConstructorUsedError;

  /// ``"Trailer" | "Teaser" | "Clip" | "Featurette" | ...`` — driven by TMDB.
  String get type => throw _privateConstructorUsedError;

  /// ``true`` for studio-published trailers. Preferred when picking which
  /// video to autoplay in the hero.
  bool get official => throw _privateConstructorUsedError;

  /// Free-text human label ("Official Trailer", "Teaser #2", etc).
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this TmdbVideo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TmdbVideo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TmdbVideoCopyWith<TmdbVideo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TmdbVideoCopyWith<$Res> {
  factory $TmdbVideoCopyWith(TmdbVideo value, $Res Function(TmdbVideo) then) =
      _$TmdbVideoCopyWithImpl<$Res, TmdbVideo>;
  @useResult
  $Res call(
      {String key, String site, String type, bool official, String? name});
}

/// @nodoc
class _$TmdbVideoCopyWithImpl<$Res, $Val extends TmdbVideo>
    implements $TmdbVideoCopyWith<$Res> {
  _$TmdbVideoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TmdbVideo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? site = null,
    Object? type = null,
    Object? official = null,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      site: null == site
          ? _value.site
          : site // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      official: null == official
          ? _value.official
          : official // ignore: cast_nullable_to_non_nullable
              as bool,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TmdbVideoImplCopyWith<$Res>
    implements $TmdbVideoCopyWith<$Res> {
  factory _$$TmdbVideoImplCopyWith(
          _$TmdbVideoImpl value, $Res Function(_$TmdbVideoImpl) then) =
      __$$TmdbVideoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String key, String site, String type, bool official, String? name});
}

/// @nodoc
class __$$TmdbVideoImplCopyWithImpl<$Res>
    extends _$TmdbVideoCopyWithImpl<$Res, _$TmdbVideoImpl>
    implements _$$TmdbVideoImplCopyWith<$Res> {
  __$$TmdbVideoImplCopyWithImpl(
      _$TmdbVideoImpl _value, $Res Function(_$TmdbVideoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TmdbVideo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? site = null,
    Object? type = null,
    Object? official = null,
    Object? name = freezed,
  }) {
    return _then(_$TmdbVideoImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      site: null == site
          ? _value.site
          : site // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      official: null == official
          ? _value.official
          : official // ignore: cast_nullable_to_non_nullable
              as bool,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TmdbVideoImpl implements _TmdbVideo {
  const _$TmdbVideoImpl(
      {required this.key,
      required this.site,
      required this.type,
      required this.official,
      this.name});

  factory _$TmdbVideoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TmdbVideoImplFromJson(json);

  /// YouTube video id (the ``v=`` query parameter on watch URLs).
  @override
  final String key;

  /// Always ``"YouTube"`` in v3 — the backend strips other sites — but we
  /// keep the field for forward-compat in case we later allow Vimeo embeds.
  @override
  final String site;

  /// ``"Trailer" | "Teaser" | "Clip" | "Featurette" | ...`` — driven by TMDB.
  @override
  final String type;

  /// ``true`` for studio-published trailers. Preferred when picking which
  /// video to autoplay in the hero.
  @override
  final bool official;

  /// Free-text human label ("Official Trailer", "Teaser #2", etc).
  @override
  final String? name;

  @override
  String toString() {
    return 'TmdbVideo(key: $key, site: $site, type: $type, official: $official, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TmdbVideoImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.site, site) || other.site == site) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.official, official) ||
                other.official == official) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, site, type, official, name);

  /// Create a copy of TmdbVideo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TmdbVideoImplCopyWith<_$TmdbVideoImpl> get copyWith =>
      __$$TmdbVideoImplCopyWithImpl<_$TmdbVideoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TmdbVideoImplToJson(
      this,
    );
  }
}

abstract class _TmdbVideo implements TmdbVideo {
  const factory _TmdbVideo(
      {required final String key,
      required final String site,
      required final String type,
      required final bool official,
      final String? name}) = _$TmdbVideoImpl;

  factory _TmdbVideo.fromJson(Map<String, dynamic> json) =
      _$TmdbVideoImpl.fromJson;

  /// YouTube video id (the ``v=`` query parameter on watch URLs).
  @override
  String get key;

  /// Always ``"YouTube"`` in v3 — the backend strips other sites — but we
  /// keep the field for forward-compat in case we later allow Vimeo embeds.
  @override
  String get site;

  /// ``"Trailer" | "Teaser" | "Clip" | "Featurette" | ...`` — driven by TMDB.
  @override
  String get type;

  /// ``true`` for studio-published trailers. Preferred when picking which
  /// video to autoplay in the hero.
  @override
  bool get official;

  /// Free-text human label ("Official Trailer", "Teaser #2", etc).
  @override
  String? get name;

  /// Create a copy of TmdbVideo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TmdbVideoImplCopyWith<_$TmdbVideoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
