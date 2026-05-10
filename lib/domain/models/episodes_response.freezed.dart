// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episodes_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EpisodesResponse _$EpisodesResponseFromJson(Map<String, dynamic> json) {
  return _EpisodesResponse.fromJson(json);
}

/// @nodoc
mixin _$EpisodesResponse {
  List<SeasonInfo> get seasons => throw _privateConstructorUsedError;

  /// Serializes this EpisodesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EpisodesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EpisodesResponseCopyWith<EpisodesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodesResponseCopyWith<$Res> {
  factory $EpisodesResponseCopyWith(
          EpisodesResponse value, $Res Function(EpisodesResponse) then) =
      _$EpisodesResponseCopyWithImpl<$Res, EpisodesResponse>;
  @useResult
  $Res call({List<SeasonInfo> seasons});
}

/// @nodoc
class _$EpisodesResponseCopyWithImpl<$Res, $Val extends EpisodesResponse>
    implements $EpisodesResponseCopyWith<$Res> {
  _$EpisodesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EpisodesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seasons = null,
  }) {
    return _then(_value.copyWith(
      seasons: null == seasons
          ? _value.seasons
          : seasons // ignore: cast_nullable_to_non_nullable
              as List<SeasonInfo>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EpisodesResponseImplCopyWith<$Res>
    implements $EpisodesResponseCopyWith<$Res> {
  factory _$$EpisodesResponseImplCopyWith(_$EpisodesResponseImpl value,
          $Res Function(_$EpisodesResponseImpl) then) =
      __$$EpisodesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<SeasonInfo> seasons});
}

/// @nodoc
class __$$EpisodesResponseImplCopyWithImpl<$Res>
    extends _$EpisodesResponseCopyWithImpl<$Res, _$EpisodesResponseImpl>
    implements _$$EpisodesResponseImplCopyWith<$Res> {
  __$$EpisodesResponseImplCopyWithImpl(_$EpisodesResponseImpl _value,
      $Res Function(_$EpisodesResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of EpisodesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seasons = null,
  }) {
    return _then(_$EpisodesResponseImpl(
      seasons: null == seasons
          ? _value._seasons
          : seasons // ignore: cast_nullable_to_non_nullable
              as List<SeasonInfo>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EpisodesResponseImpl implements _EpisodesResponse {
  const _$EpisodesResponseImpl(
      {final List<SeasonInfo> seasons = const <SeasonInfo>[]})
      : _seasons = seasons;

  factory _$EpisodesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$EpisodesResponseImplFromJson(json);

  final List<SeasonInfo> _seasons;
  @override
  @JsonKey()
  List<SeasonInfo> get seasons {
    if (_seasons is EqualUnmodifiableListView) return _seasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasons);
  }

  @override
  String toString() {
    return 'EpisodesResponse(seasons: $seasons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodesResponseImpl &&
            const DeepCollectionEquality().equals(other._seasons, _seasons));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_seasons));

  /// Create a copy of EpisodesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodesResponseImplCopyWith<_$EpisodesResponseImpl> get copyWith =>
      __$$EpisodesResponseImplCopyWithImpl<_$EpisodesResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EpisodesResponseImplToJson(
      this,
    );
  }
}

abstract class _EpisodesResponse implements EpisodesResponse {
  const factory _EpisodesResponse({final List<SeasonInfo> seasons}) =
      _$EpisodesResponseImpl;

  factory _EpisodesResponse.fromJson(Map<String, dynamic> json) =
      _$EpisodesResponseImpl.fromJson;

  @override
  List<SeasonInfo> get seasons;

  /// Create a copy of EpisodesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EpisodesResponseImplCopyWith<_$EpisodesResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SeasonInfo _$SeasonInfoFromJson(Map<String, dynamic> json) {
  return _SeasonInfo.fromJson(json);
}

/// @nodoc
mixin _$SeasonInfo {
  int get number => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  List<EpisodeInfo> get episodes => throw _privateConstructorUsedError;

  /// Serializes this SeasonInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SeasonInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeasonInfoCopyWith<SeasonInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonInfoCopyWith<$Res> {
  factory $SeasonInfoCopyWith(
          SeasonInfo value, $Res Function(SeasonInfo) then) =
      _$SeasonInfoCopyWithImpl<$Res, SeasonInfo>;
  @useResult
  $Res call({int number, String? name, List<EpisodeInfo> episodes});
}

/// @nodoc
class _$SeasonInfoCopyWithImpl<$Res, $Val extends SeasonInfo>
    implements $SeasonInfoCopyWith<$Res> {
  _$SeasonInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeasonInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? number = null,
    Object? name = freezed,
    Object? episodes = null,
  }) {
    return _then(_value.copyWith(
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<EpisodeInfo>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeasonInfoImplCopyWith<$Res>
    implements $SeasonInfoCopyWith<$Res> {
  factory _$$SeasonInfoImplCopyWith(
          _$SeasonInfoImpl value, $Res Function(_$SeasonInfoImpl) then) =
      __$$SeasonInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int number, String? name, List<EpisodeInfo> episodes});
}

/// @nodoc
class __$$SeasonInfoImplCopyWithImpl<$Res>
    extends _$SeasonInfoCopyWithImpl<$Res, _$SeasonInfoImpl>
    implements _$$SeasonInfoImplCopyWith<$Res> {
  __$$SeasonInfoImplCopyWithImpl(
      _$SeasonInfoImpl _value, $Res Function(_$SeasonInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeasonInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? number = null,
    Object? name = freezed,
    Object? episodes = null,
  }) {
    return _then(_$SeasonInfoImpl(
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<EpisodeInfo>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonInfoImpl implements _SeasonInfo {
  const _$SeasonInfoImpl(
      {required this.number,
      this.name,
      final List<EpisodeInfo> episodes = const <EpisodeInfo>[]})
      : _episodes = episodes;

  factory _$SeasonInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonInfoImplFromJson(json);

  @override
  final int number;
  @override
  final String? name;
  final List<EpisodeInfo> _episodes;
  @override
  @JsonKey()
  List<EpisodeInfo> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  @override
  String toString() {
    return 'SeasonInfo(number: $number, name: $name, episodes: $episodes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonInfoImpl &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, number, name,
      const DeepCollectionEquality().hash(_episodes));

  /// Create a copy of SeasonInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonInfoImplCopyWith<_$SeasonInfoImpl> get copyWith =>
      __$$SeasonInfoImplCopyWithImpl<_$SeasonInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonInfoImplToJson(
      this,
    );
  }
}

abstract class _SeasonInfo implements SeasonInfo {
  const factory _SeasonInfo(
      {required final int number,
      final String? name,
      final List<EpisodeInfo> episodes}) = _$SeasonInfoImpl;

  factory _SeasonInfo.fromJson(Map<String, dynamic> json) =
      _$SeasonInfoImpl.fromJson;

  @override
  int get number;
  @override
  String? get name;
  @override
  List<EpisodeInfo> get episodes;

  /// Create a copy of SeasonInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeasonInfoImplCopyWith<_$SeasonInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EpisodeInfo _$EpisodeInfoFromJson(Map<String, dynamic> json) {
  return _EpisodeInfo.fromJson(json);
}

/// @nodoc
mixin _$EpisodeInfo {
  int get season => throw _privateConstructorUsedError;
  int get episode => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get overview => throw _privateConstructorUsedError;
  @JsonKey(name: 'still_url')
  String? get stillUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'runtime_minutes')
  int? get runtimeMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'air_date')
  String? get airDate => throw _privateConstructorUsedError;

  /// Serializes this EpisodeInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EpisodeInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EpisodeInfoCopyWith<EpisodeInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodeInfoCopyWith<$Res> {
  factory $EpisodeInfoCopyWith(
          EpisodeInfo value, $Res Function(EpisodeInfo) then) =
      _$EpisodeInfoCopyWithImpl<$Res, EpisodeInfo>;
  @useResult
  $Res call(
      {int season,
      int episode,
      String title,
      String? overview,
      @JsonKey(name: 'still_url') String? stillUrl,
      @JsonKey(name: 'runtime_minutes') int? runtimeMinutes,
      @JsonKey(name: 'air_date') String? airDate});
}

/// @nodoc
class _$EpisodeInfoCopyWithImpl<$Res, $Val extends EpisodeInfo>
    implements $EpisodeInfoCopyWith<$Res> {
  _$EpisodeInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EpisodeInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? season = null,
    Object? episode = null,
    Object? title = null,
    Object? overview = freezed,
    Object? stillUrl = freezed,
    Object? runtimeMinutes = freezed,
    Object? airDate = freezed,
  }) {
    return _then(_value.copyWith(
      season: null == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as int,
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      stillUrl: freezed == stillUrl
          ? _value.stillUrl
          : stillUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      runtimeMinutes: freezed == runtimeMinutes
          ? _value.runtimeMinutes
          : runtimeMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      airDate: freezed == airDate
          ? _value.airDate
          : airDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EpisodeInfoImplCopyWith<$Res>
    implements $EpisodeInfoCopyWith<$Res> {
  factory _$$EpisodeInfoImplCopyWith(
          _$EpisodeInfoImpl value, $Res Function(_$EpisodeInfoImpl) then) =
      __$$EpisodeInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int season,
      int episode,
      String title,
      String? overview,
      @JsonKey(name: 'still_url') String? stillUrl,
      @JsonKey(name: 'runtime_minutes') int? runtimeMinutes,
      @JsonKey(name: 'air_date') String? airDate});
}

/// @nodoc
class __$$EpisodeInfoImplCopyWithImpl<$Res>
    extends _$EpisodeInfoCopyWithImpl<$Res, _$EpisodeInfoImpl>
    implements _$$EpisodeInfoImplCopyWith<$Res> {
  __$$EpisodeInfoImplCopyWithImpl(
      _$EpisodeInfoImpl _value, $Res Function(_$EpisodeInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of EpisodeInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? season = null,
    Object? episode = null,
    Object? title = null,
    Object? overview = freezed,
    Object? stillUrl = freezed,
    Object? runtimeMinutes = freezed,
    Object? airDate = freezed,
  }) {
    return _then(_$EpisodeInfoImpl(
      season: null == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as int,
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      stillUrl: freezed == stillUrl
          ? _value.stillUrl
          : stillUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      runtimeMinutes: freezed == runtimeMinutes
          ? _value.runtimeMinutes
          : runtimeMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      airDate: freezed == airDate
          ? _value.airDate
          : airDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EpisodeInfoImpl implements _EpisodeInfo {
  const _$EpisodeInfoImpl(
      {required this.season,
      required this.episode,
      required this.title,
      this.overview,
      @JsonKey(name: 'still_url') this.stillUrl,
      @JsonKey(name: 'runtime_minutes') this.runtimeMinutes,
      @JsonKey(name: 'air_date') this.airDate});

  factory _$EpisodeInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EpisodeInfoImplFromJson(json);

  @override
  final int season;
  @override
  final int episode;
  @override
  final String title;
  @override
  final String? overview;
  @override
  @JsonKey(name: 'still_url')
  final String? stillUrl;
  @override
  @JsonKey(name: 'runtime_minutes')
  final int? runtimeMinutes;
  @override
  @JsonKey(name: 'air_date')
  final String? airDate;

  @override
  String toString() {
    return 'EpisodeInfo(season: $season, episode: $episode, title: $title, overview: $overview, stillUrl: $stillUrl, runtimeMinutes: $runtimeMinutes, airDate: $airDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeInfoImpl &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.episode, episode) || other.episode == episode) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.stillUrl, stillUrl) ||
                other.stillUrl == stillUrl) &&
            (identical(other.runtimeMinutes, runtimeMinutes) ||
                other.runtimeMinutes == runtimeMinutes) &&
            (identical(other.airDate, airDate) || other.airDate == airDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, season, episode, title, overview,
      stillUrl, runtimeMinutes, airDate);

  /// Create a copy of EpisodeInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeInfoImplCopyWith<_$EpisodeInfoImpl> get copyWith =>
      __$$EpisodeInfoImplCopyWithImpl<_$EpisodeInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EpisodeInfoImplToJson(
      this,
    );
  }
}

abstract class _EpisodeInfo implements EpisodeInfo {
  const factory _EpisodeInfo(
      {required final int season,
      required final int episode,
      required final String title,
      final String? overview,
      @JsonKey(name: 'still_url') final String? stillUrl,
      @JsonKey(name: 'runtime_minutes') final int? runtimeMinutes,
      @JsonKey(name: 'air_date') final String? airDate}) = _$EpisodeInfoImpl;

  factory _EpisodeInfo.fromJson(Map<String, dynamic> json) =
      _$EpisodeInfoImpl.fromJson;

  @override
  int get season;
  @override
  int get episode;
  @override
  String get title;
  @override
  String? get overview;
  @override
  @JsonKey(name: 'still_url')
  String? get stillUrl;
  @override
  @JsonKey(name: 'runtime_minutes')
  int? get runtimeMinutes;
  @override
  @JsonKey(name: 'air_date')
  String? get airDate;

  /// Create a copy of EpisodeInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EpisodeInfoImplCopyWith<_$EpisodeInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
