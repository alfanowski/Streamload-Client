// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MediaSummary _$MediaSummaryFromJson(Map<String, dynamic> json) {
  return _MediaSummary.fromJson(json);
}

/// @nodoc
mixin _$MediaSummary {
  @JsonKey(name: 'tmdb_id')
  int get tmdbId => throw _privateConstructorUsedError;
  @JsonKey(name: 'media_type')
  String get mediaType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int? get year => throw _privateConstructorUsedError;
  @JsonKey(name: 'poster_url')
  String? get posterUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'backdrop_url')
  String? get backdropUrl => throw _privateConstructorUsedError;

  /// Serializes this MediaSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MediaSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaSummaryCopyWith<MediaSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaSummaryCopyWith<$Res> {
  factory $MediaSummaryCopyWith(
          MediaSummary value, $Res Function(MediaSummary) then) =
      _$MediaSummaryCopyWithImpl<$Res, MediaSummary>;
  @useResult
  $Res call(
      {@JsonKey(name: 'tmdb_id') int tmdbId,
      @JsonKey(name: 'media_type') String mediaType,
      String title,
      int? year,
      @JsonKey(name: 'poster_url') String? posterUrl,
      @JsonKey(name: 'backdrop_url') String? backdropUrl});
}

/// @nodoc
class _$MediaSummaryCopyWithImpl<$Res, $Val extends MediaSummary>
    implements $MediaSummaryCopyWith<$Res> {
  _$MediaSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MediaSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmdbId = null,
    Object? mediaType = null,
    Object? title = null,
    Object? year = freezed,
    Object? posterUrl = freezed,
    Object? backdropUrl = freezed,
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
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      posterUrl: freezed == posterUrl
          ? _value.posterUrl
          : posterUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      backdropUrl: freezed == backdropUrl
          ? _value.backdropUrl
          : backdropUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MediaSummaryImplCopyWith<$Res>
    implements $MediaSummaryCopyWith<$Res> {
  factory _$$MediaSummaryImplCopyWith(
          _$MediaSummaryImpl value, $Res Function(_$MediaSummaryImpl) then) =
      __$$MediaSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'tmdb_id') int tmdbId,
      @JsonKey(name: 'media_type') String mediaType,
      String title,
      int? year,
      @JsonKey(name: 'poster_url') String? posterUrl,
      @JsonKey(name: 'backdrop_url') String? backdropUrl});
}

/// @nodoc
class __$$MediaSummaryImplCopyWithImpl<$Res>
    extends _$MediaSummaryCopyWithImpl<$Res, _$MediaSummaryImpl>
    implements _$$MediaSummaryImplCopyWith<$Res> {
  __$$MediaSummaryImplCopyWithImpl(
      _$MediaSummaryImpl _value, $Res Function(_$MediaSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of MediaSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmdbId = null,
    Object? mediaType = null,
    Object? title = null,
    Object? year = freezed,
    Object? posterUrl = freezed,
    Object? backdropUrl = freezed,
  }) {
    return _then(_$MediaSummaryImpl(
      tmdbId: null == tmdbId
          ? _value.tmdbId
          : tmdbId // ignore: cast_nullable_to_non_nullable
              as int,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      posterUrl: freezed == posterUrl
          ? _value.posterUrl
          : posterUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      backdropUrl: freezed == backdropUrl
          ? _value.backdropUrl
          : backdropUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaSummaryImpl implements _MediaSummary {
  const _$MediaSummaryImpl(
      {@JsonKey(name: 'tmdb_id') required this.tmdbId,
      @JsonKey(name: 'media_type') required this.mediaType,
      required this.title,
      this.year,
      @JsonKey(name: 'poster_url') this.posterUrl,
      @JsonKey(name: 'backdrop_url') this.backdropUrl});

  factory _$MediaSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'tmdb_id')
  final int tmdbId;
  @override
  @JsonKey(name: 'media_type')
  final String mediaType;
  @override
  final String title;
  @override
  final int? year;
  @override
  @JsonKey(name: 'poster_url')
  final String? posterUrl;
  @override
  @JsonKey(name: 'backdrop_url')
  final String? backdropUrl;

  @override
  String toString() {
    return 'MediaSummary(tmdbId: $tmdbId, mediaType: $mediaType, title: $title, year: $year, posterUrl: $posterUrl, backdropUrl: $backdropUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaSummaryImpl &&
            (identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.posterUrl, posterUrl) ||
                other.posterUrl == posterUrl) &&
            (identical(other.backdropUrl, backdropUrl) ||
                other.backdropUrl == backdropUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, tmdbId, mediaType, title, year, posterUrl, backdropUrl);

  /// Create a copy of MediaSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaSummaryImplCopyWith<_$MediaSummaryImpl> get copyWith =>
      __$$MediaSummaryImplCopyWithImpl<_$MediaSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaSummaryImplToJson(
      this,
    );
  }
}

abstract class _MediaSummary implements MediaSummary {
  const factory _MediaSummary(
          {@JsonKey(name: 'tmdb_id') required final int tmdbId,
          @JsonKey(name: 'media_type') required final String mediaType,
          required final String title,
          final int? year,
          @JsonKey(name: 'poster_url') final String? posterUrl,
          @JsonKey(name: 'backdrop_url') final String? backdropUrl}) =
      _$MediaSummaryImpl;

  factory _MediaSummary.fromJson(Map<String, dynamic> json) =
      _$MediaSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'tmdb_id')
  int get tmdbId;
  @override
  @JsonKey(name: 'media_type')
  String get mediaType;
  @override
  String get title;
  @override
  int? get year;
  @override
  @JsonKey(name: 'poster_url')
  String? get posterUrl;
  @override
  @JsonKey(name: 'backdrop_url')
  String? get backdropUrl;

  /// Create a copy of MediaSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaSummaryImplCopyWith<_$MediaSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
