// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SourceResponse _$SourceResponseFromJson(Map<String, dynamic> json) {
  return _SourceResponse.fromJson(json);
}

/// @nodoc
mixin _$SourceResponse {
  String get label => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;

  /// Serializes this SourceResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SourceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SourceResponseCopyWith<SourceResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SourceResponseCopyWith<$Res> {
  factory $SourceResponseCopyWith(
          SourceResponse value, $Res Function(SourceResponse) then) =
      _$SourceResponseCopyWithImpl<$Res, SourceResponse>;
  @useResult
  $Res call({String label, double score});
}

/// @nodoc
class _$SourceResponseCopyWithImpl<$Res, $Val extends SourceResponse>
    implements $SourceResponseCopyWith<$Res> {
  _$SourceResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SourceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? score = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SourceResponseImplCopyWith<$Res>
    implements $SourceResponseCopyWith<$Res> {
  factory _$$SourceResponseImplCopyWith(_$SourceResponseImpl value,
          $Res Function(_$SourceResponseImpl) then) =
      __$$SourceResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, double score});
}

/// @nodoc
class __$$SourceResponseImplCopyWithImpl<$Res>
    extends _$SourceResponseCopyWithImpl<$Res, _$SourceResponseImpl>
    implements _$$SourceResponseImplCopyWith<$Res> {
  __$$SourceResponseImplCopyWithImpl(
      _$SourceResponseImpl _value, $Res Function(_$SourceResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of SourceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? score = null,
  }) {
    return _then(_$SourceResponseImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SourceResponseImpl implements _SourceResponse {
  const _$SourceResponseImpl({required this.label, required this.score});

  factory _$SourceResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SourceResponseImplFromJson(json);

  @override
  final String label;
  @override
  final double score;

  @override
  String toString() {
    return 'SourceResponse(label: $label, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SourceResponseImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, score);

  /// Create a copy of SourceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SourceResponseImplCopyWith<_$SourceResponseImpl> get copyWith =>
      __$$SourceResponseImplCopyWithImpl<_$SourceResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SourceResponseImplToJson(
      this,
    );
  }
}

abstract class _SourceResponse implements SourceResponse {
  const factory _SourceResponse(
      {required final String label,
      required final double score}) = _$SourceResponseImpl;

  factory _SourceResponse.fromJson(Map<String, dynamic> json) =
      _$SourceResponseImpl.fromJson;

  @override
  String get label;
  @override
  double get score;

  /// Create a copy of SourceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SourceResponseImplCopyWith<_$SourceResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CatalogItemResponse _$CatalogItemResponseFromJson(Map<String, dynamic> json) {
  return _CatalogItemResponse.fromJson(json);
}

/// @nodoc
mixin _$CatalogItemResponse {
  @JsonKey(name: 'tmdb_id')
  int get tmdbId => throw _privateConstructorUsedError;
  @JsonKey(name: 'media_type')
  String get mediaType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_title')
  String? get originalTitle => throw _privateConstructorUsedError;
  int? get year => throw _privateConstructorUsedError;
  @JsonKey(name: 'poster_url')
  String? get posterUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'backdrop_url')
  String? get backdropUrl => throw _privateConstructorUsedError;
  String? get overview => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'runtime_minutes')
  int? get runtimeMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'seasons_count')
  int? get seasonsCount => throw _privateConstructorUsedError;
  List<String> get genres => throw _privateConstructorUsedError;
  List<SourceResponse> get sources => throw _privateConstructorUsedError;

  /// Serializes this CatalogItemResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogItemResponseCopyWith<CatalogItemResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogItemResponseCopyWith<$Res> {
  factory $CatalogItemResponseCopyWith(
          CatalogItemResponse value, $Res Function(CatalogItemResponse) then) =
      _$CatalogItemResponseCopyWithImpl<$Res, CatalogItemResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'tmdb_id') int tmdbId,
      @JsonKey(name: 'media_type') String mediaType,
      String title,
      @JsonKey(name: 'original_title') String? originalTitle,
      int? year,
      @JsonKey(name: 'poster_url') String? posterUrl,
      @JsonKey(name: 'backdrop_url') String? backdropUrl,
      String? overview,
      double? rating,
      @JsonKey(name: 'runtime_minutes') int? runtimeMinutes,
      @JsonKey(name: 'seasons_count') int? seasonsCount,
      List<String> genres,
      List<SourceResponse> sources});
}

/// @nodoc
class _$CatalogItemResponseCopyWithImpl<$Res, $Val extends CatalogItemResponse>
    implements $CatalogItemResponseCopyWith<$Res> {
  _$CatalogItemResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmdbId = null,
    Object? mediaType = null,
    Object? title = null,
    Object? originalTitle = freezed,
    Object? year = freezed,
    Object? posterUrl = freezed,
    Object? backdropUrl = freezed,
    Object? overview = freezed,
    Object? rating = freezed,
    Object? runtimeMinutes = freezed,
    Object? seasonsCount = freezed,
    Object? genres = null,
    Object? sources = null,
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
      originalTitle: freezed == originalTitle
          ? _value.originalTitle
          : originalTitle // ignore: cast_nullable_to_non_nullable
              as String?,
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
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      runtimeMinutes: freezed == runtimeMinutes
          ? _value.runtimeMinutes
          : runtimeMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      seasonsCount: freezed == seasonsCount
          ? _value.seasonsCount
          : seasonsCount // ignore: cast_nullable_to_non_nullable
              as int?,
      genres: null == genres
          ? _value.genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sources: null == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<SourceResponse>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CatalogItemResponseImplCopyWith<$Res>
    implements $CatalogItemResponseCopyWith<$Res> {
  factory _$$CatalogItemResponseImplCopyWith(_$CatalogItemResponseImpl value,
          $Res Function(_$CatalogItemResponseImpl) then) =
      __$$CatalogItemResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'tmdb_id') int tmdbId,
      @JsonKey(name: 'media_type') String mediaType,
      String title,
      @JsonKey(name: 'original_title') String? originalTitle,
      int? year,
      @JsonKey(name: 'poster_url') String? posterUrl,
      @JsonKey(name: 'backdrop_url') String? backdropUrl,
      String? overview,
      double? rating,
      @JsonKey(name: 'runtime_minutes') int? runtimeMinutes,
      @JsonKey(name: 'seasons_count') int? seasonsCount,
      List<String> genres,
      List<SourceResponse> sources});
}

/// @nodoc
class __$$CatalogItemResponseImplCopyWithImpl<$Res>
    extends _$CatalogItemResponseCopyWithImpl<$Res, _$CatalogItemResponseImpl>
    implements _$$CatalogItemResponseImplCopyWith<$Res> {
  __$$CatalogItemResponseImplCopyWithImpl(_$CatalogItemResponseImpl _value,
      $Res Function(_$CatalogItemResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of CatalogItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmdbId = null,
    Object? mediaType = null,
    Object? title = null,
    Object? originalTitle = freezed,
    Object? year = freezed,
    Object? posterUrl = freezed,
    Object? backdropUrl = freezed,
    Object? overview = freezed,
    Object? rating = freezed,
    Object? runtimeMinutes = freezed,
    Object? seasonsCount = freezed,
    Object? genres = null,
    Object? sources = null,
  }) {
    return _then(_$CatalogItemResponseImpl(
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
      originalTitle: freezed == originalTitle
          ? _value.originalTitle
          : originalTitle // ignore: cast_nullable_to_non_nullable
              as String?,
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
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      runtimeMinutes: freezed == runtimeMinutes
          ? _value.runtimeMinutes
          : runtimeMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      seasonsCount: freezed == seasonsCount
          ? _value.seasonsCount
          : seasonsCount // ignore: cast_nullable_to_non_nullable
              as int?,
      genres: null == genres
          ? _value._genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sources: null == sources
          ? _value._sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<SourceResponse>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogItemResponseImpl implements _CatalogItemResponse {
  const _$CatalogItemResponseImpl(
      {@JsonKey(name: 'tmdb_id') required this.tmdbId,
      @JsonKey(name: 'media_type') required this.mediaType,
      required this.title,
      @JsonKey(name: 'original_title') this.originalTitle,
      this.year,
      @JsonKey(name: 'poster_url') this.posterUrl,
      @JsonKey(name: 'backdrop_url') this.backdropUrl,
      this.overview,
      this.rating,
      @JsonKey(name: 'runtime_minutes') this.runtimeMinutes,
      @JsonKey(name: 'seasons_count') this.seasonsCount,
      final List<String> genres = const [],
      final List<SourceResponse> sources = const []})
      : _genres = genres,
        _sources = sources;

  factory _$CatalogItemResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogItemResponseImplFromJson(json);

  @override
  @JsonKey(name: 'tmdb_id')
  final int tmdbId;
  @override
  @JsonKey(name: 'media_type')
  final String mediaType;
  @override
  final String title;
  @override
  @JsonKey(name: 'original_title')
  final String? originalTitle;
  @override
  final int? year;
  @override
  @JsonKey(name: 'poster_url')
  final String? posterUrl;
  @override
  @JsonKey(name: 'backdrop_url')
  final String? backdropUrl;
  @override
  final String? overview;
  @override
  final double? rating;
  @override
  @JsonKey(name: 'runtime_minutes')
  final int? runtimeMinutes;
  @override
  @JsonKey(name: 'seasons_count')
  final int? seasonsCount;
  final List<String> _genres;
  @override
  @JsonKey()
  List<String> get genres {
    if (_genres is EqualUnmodifiableListView) return _genres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genres);
  }

  final List<SourceResponse> _sources;
  @override
  @JsonKey()
  List<SourceResponse> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  @override
  String toString() {
    return 'CatalogItemResponse(tmdbId: $tmdbId, mediaType: $mediaType, title: $title, originalTitle: $originalTitle, year: $year, posterUrl: $posterUrl, backdropUrl: $backdropUrl, overview: $overview, rating: $rating, runtimeMinutes: $runtimeMinutes, seasonsCount: $seasonsCount, genres: $genres, sources: $sources)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogItemResponseImpl &&
            (identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.originalTitle, originalTitle) ||
                other.originalTitle == originalTitle) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.posterUrl, posterUrl) ||
                other.posterUrl == posterUrl) &&
            (identical(other.backdropUrl, backdropUrl) ||
                other.backdropUrl == backdropUrl) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.runtimeMinutes, runtimeMinutes) ||
                other.runtimeMinutes == runtimeMinutes) &&
            (identical(other.seasonsCount, seasonsCount) ||
                other.seasonsCount == seasonsCount) &&
            const DeepCollectionEquality().equals(other._genres, _genres) &&
            const DeepCollectionEquality().equals(other._sources, _sources));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      tmdbId,
      mediaType,
      title,
      originalTitle,
      year,
      posterUrl,
      backdropUrl,
      overview,
      rating,
      runtimeMinutes,
      seasonsCount,
      const DeepCollectionEquality().hash(_genres),
      const DeepCollectionEquality().hash(_sources));

  /// Create a copy of CatalogItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogItemResponseImplCopyWith<_$CatalogItemResponseImpl> get copyWith =>
      __$$CatalogItemResponseImplCopyWithImpl<_$CatalogItemResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogItemResponseImplToJson(
      this,
    );
  }
}

abstract class _CatalogItemResponse implements CatalogItemResponse {
  const factory _CatalogItemResponse(
      {@JsonKey(name: 'tmdb_id') required final int tmdbId,
      @JsonKey(name: 'media_type') required final String mediaType,
      required final String title,
      @JsonKey(name: 'original_title') final String? originalTitle,
      final int? year,
      @JsonKey(name: 'poster_url') final String? posterUrl,
      @JsonKey(name: 'backdrop_url') final String? backdropUrl,
      final String? overview,
      final double? rating,
      @JsonKey(name: 'runtime_minutes') final int? runtimeMinutes,
      @JsonKey(name: 'seasons_count') final int? seasonsCount,
      final List<String> genres,
      final List<SourceResponse> sources}) = _$CatalogItemResponseImpl;

  factory _CatalogItemResponse.fromJson(Map<String, dynamic> json) =
      _$CatalogItemResponseImpl.fromJson;

  @override
  @JsonKey(name: 'tmdb_id')
  int get tmdbId;
  @override
  @JsonKey(name: 'media_type')
  String get mediaType;
  @override
  String get title;
  @override
  @JsonKey(name: 'original_title')
  String? get originalTitle;
  @override
  int? get year;
  @override
  @JsonKey(name: 'poster_url')
  String? get posterUrl;
  @override
  @JsonKey(name: 'backdrop_url')
  String? get backdropUrl;
  @override
  String? get overview;
  @override
  double? get rating;
  @override
  @JsonKey(name: 'runtime_minutes')
  int? get runtimeMinutes;
  @override
  @JsonKey(name: 'seasons_count')
  int? get seasonsCount;
  @override
  List<String> get genres;
  @override
  List<SourceResponse> get sources;

  /// Create a copy of CatalogItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogItemResponseImplCopyWith<_$CatalogItemResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
