// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PlaybackRequest {
  int get tmdbId => throw _privateConstructorUsedError;
  String get mediaType => throw _privateConstructorUsedError;
  int? get season => throw _privateConstructorUsedError;
  int? get episode => throw _privateConstructorUsedError;

  /// Create a copy of PlaybackRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaybackRequestCopyWith<PlaybackRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaybackRequestCopyWith<$Res> {
  factory $PlaybackRequestCopyWith(
          PlaybackRequest value, $Res Function(PlaybackRequest) then) =
      _$PlaybackRequestCopyWithImpl<$Res, PlaybackRequest>;
  @useResult
  $Res call({int tmdbId, String mediaType, int? season, int? episode});
}

/// @nodoc
class _$PlaybackRequestCopyWithImpl<$Res, $Val extends PlaybackRequest>
    implements $PlaybackRequestCopyWith<$Res> {
  _$PlaybackRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaybackRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmdbId = null,
    Object? mediaType = null,
    Object? season = freezed,
    Object? episode = freezed,
  }) {
    return _then(_value.copyWith(
      tmdbId: null == tmdbId
          ? _value.tmdbId
          : tmdbId // ignore: cast_nullable_to_non_nullable
              as int,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as int?,
      episode: freezed == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaybackRequestImplCopyWith<$Res>
    implements $PlaybackRequestCopyWith<$Res> {
  factory _$$PlaybackRequestImplCopyWith(_$PlaybackRequestImpl value,
          $Res Function(_$PlaybackRequestImpl) then) =
      __$$PlaybackRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int tmdbId, String mediaType, int? season, int? episode});
}

/// @nodoc
class __$$PlaybackRequestImplCopyWithImpl<$Res>
    extends _$PlaybackRequestCopyWithImpl<$Res, _$PlaybackRequestImpl>
    implements _$$PlaybackRequestImplCopyWith<$Res> {
  __$$PlaybackRequestImplCopyWithImpl(
      _$PlaybackRequestImpl _value, $Res Function(_$PlaybackRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaybackRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmdbId = null,
    Object? mediaType = null,
    Object? season = freezed,
    Object? episode = freezed,
  }) {
    return _then(_$PlaybackRequestImpl(
      tmdbId: null == tmdbId
          ? _value.tmdbId
          : tmdbId // ignore: cast_nullable_to_non_nullable
              as int,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as int?,
      episode: freezed == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$PlaybackRequestImpl implements _PlaybackRequest {
  const _$PlaybackRequestImpl(
      {required this.tmdbId,
      required this.mediaType,
      this.season,
      this.episode});

  @override
  final int tmdbId;
  @override
  final String mediaType;
  @override
  final int? season;
  @override
  final int? episode;

  @override
  String toString() {
    return 'PlaybackRequest(tmdbId: $tmdbId, mediaType: $mediaType, season: $season, episode: $episode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaybackRequestImpl &&
            (identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.episode, episode) || other.episode == episode));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, tmdbId, mediaType, season, episode);

  /// Create a copy of PlaybackRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaybackRequestImplCopyWith<_$PlaybackRequestImpl> get copyWith =>
      __$$PlaybackRequestImplCopyWithImpl<_$PlaybackRequestImpl>(
          this, _$identity);
}

abstract class _PlaybackRequest implements PlaybackRequest {
  const factory _PlaybackRequest(
      {required final int tmdbId,
      required final String mediaType,
      final int? season,
      final int? episode}) = _$PlaybackRequestImpl;

  @override
  int get tmdbId;
  @override
  String get mediaType;
  @override
  int? get season;
  @override
  int? get episode;

  /// Create a copy of PlaybackRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaybackRequestImplCopyWith<_$PlaybackRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
