// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_results.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SearchPersonResult _$SearchPersonResultFromJson(Map<String, dynamic> json) {
  return _SearchPersonResult.fromJson(json);
}

/// @nodoc
mixin _$SearchPersonResult {
  @JsonKey(name: 'tmdb_id')
  int get tmdbId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_url')
  String? get profileUrl => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  @JsonKey(name: 'known_for')
  List<String> get knownFor => throw _privateConstructorUsedError;

  /// Serializes this SearchPersonResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchPersonResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchPersonResultCopyWith<SearchPersonResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchPersonResultCopyWith<$Res> {
  factory $SearchPersonResultCopyWith(
          SearchPersonResult value, $Res Function(SearchPersonResult) then) =
      _$SearchPersonResultCopyWithImpl<$Res, SearchPersonResult>;
  @useResult
  $Res call(
      {@JsonKey(name: 'tmdb_id') int tmdbId,
      String name,
      @JsonKey(name: 'profile_url') String? profileUrl,
      String? department,
      @JsonKey(name: 'known_for') List<String> knownFor});
}

/// @nodoc
class _$SearchPersonResultCopyWithImpl<$Res, $Val extends SearchPersonResult>
    implements $SearchPersonResultCopyWith<$Res> {
  _$SearchPersonResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchPersonResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmdbId = null,
    Object? name = null,
    Object? profileUrl = freezed,
    Object? department = freezed,
    Object? knownFor = null,
  }) {
    return _then(_value.copyWith(
      tmdbId: null == tmdbId
          ? _value.tmdbId
          : tmdbId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      profileUrl: freezed == profileUrl
          ? _value.profileUrl
          : profileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      knownFor: null == knownFor
          ? _value.knownFor
          : knownFor // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchPersonResultImplCopyWith<$Res>
    implements $SearchPersonResultCopyWith<$Res> {
  factory _$$SearchPersonResultImplCopyWith(_$SearchPersonResultImpl value,
          $Res Function(_$SearchPersonResultImpl) then) =
      __$$SearchPersonResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'tmdb_id') int tmdbId,
      String name,
      @JsonKey(name: 'profile_url') String? profileUrl,
      String? department,
      @JsonKey(name: 'known_for') List<String> knownFor});
}

/// @nodoc
class __$$SearchPersonResultImplCopyWithImpl<$Res>
    extends _$SearchPersonResultCopyWithImpl<$Res, _$SearchPersonResultImpl>
    implements _$$SearchPersonResultImplCopyWith<$Res> {
  __$$SearchPersonResultImplCopyWithImpl(_$SearchPersonResultImpl _value,
      $Res Function(_$SearchPersonResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchPersonResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmdbId = null,
    Object? name = null,
    Object? profileUrl = freezed,
    Object? department = freezed,
    Object? knownFor = null,
  }) {
    return _then(_$SearchPersonResultImpl(
      tmdbId: null == tmdbId
          ? _value.tmdbId
          : tmdbId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      profileUrl: freezed == profileUrl
          ? _value.profileUrl
          : profileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      knownFor: null == knownFor
          ? _value._knownFor
          : knownFor // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchPersonResultImpl implements _SearchPersonResult {
  const _$SearchPersonResultImpl(
      {@JsonKey(name: 'tmdb_id') required this.tmdbId,
      required this.name,
      @JsonKey(name: 'profile_url') this.profileUrl,
      this.department,
      @JsonKey(name: 'known_for')
      final List<String> knownFor = const <String>[]})
      : _knownFor = knownFor;

  factory _$SearchPersonResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchPersonResultImplFromJson(json);

  @override
  @JsonKey(name: 'tmdb_id')
  final int tmdbId;
  @override
  final String name;
  @override
  @JsonKey(name: 'profile_url')
  final String? profileUrl;
  @override
  final String? department;
  final List<String> _knownFor;
  @override
  @JsonKey(name: 'known_for')
  List<String> get knownFor {
    if (_knownFor is EqualUnmodifiableListView) return _knownFor;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_knownFor);
  }

  @override
  String toString() {
    return 'SearchPersonResult(tmdbId: $tmdbId, name: $name, profileUrl: $profileUrl, department: $department, knownFor: $knownFor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchPersonResultImpl &&
            (identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.profileUrl, profileUrl) ||
                other.profileUrl == profileUrl) &&
            (identical(other.department, department) ||
                other.department == department) &&
            const DeepCollectionEquality().equals(other._knownFor, _knownFor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tmdbId, name, profileUrl,
      department, const DeepCollectionEquality().hash(_knownFor));

  /// Create a copy of SearchPersonResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchPersonResultImplCopyWith<_$SearchPersonResultImpl> get copyWith =>
      __$$SearchPersonResultImplCopyWithImpl<_$SearchPersonResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchPersonResultImplToJson(
      this,
    );
  }
}

abstract class _SearchPersonResult implements SearchPersonResult {
  const factory _SearchPersonResult(
          {@JsonKey(name: 'tmdb_id') required final int tmdbId,
          required final String name,
          @JsonKey(name: 'profile_url') final String? profileUrl,
          final String? department,
          @JsonKey(name: 'known_for') final List<String> knownFor}) =
      _$SearchPersonResultImpl;

  factory _SearchPersonResult.fromJson(Map<String, dynamic> json) =
      _$SearchPersonResultImpl.fromJson;

  @override
  @JsonKey(name: 'tmdb_id')
  int get tmdbId;
  @override
  String get name;
  @override
  @JsonKey(name: 'profile_url')
  String? get profileUrl;
  @override
  String? get department;
  @override
  @JsonKey(name: 'known_for')
  List<String> get knownFor;

  /// Create a copy of SearchPersonResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchPersonResultImplCopyWith<_$SearchPersonResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchResults {
  List<MediaSummary> get titles => throw _privateConstructorUsedError;
  List<SearchPersonResult> get people => throw _privateConstructorUsedError;

  /// Create a copy of SearchResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResultsCopyWith<SearchResults> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResultsCopyWith<$Res> {
  factory $SearchResultsCopyWith(
          SearchResults value, $Res Function(SearchResults) then) =
      _$SearchResultsCopyWithImpl<$Res, SearchResults>;
  @useResult
  $Res call({List<MediaSummary> titles, List<SearchPersonResult> people});
}

/// @nodoc
class _$SearchResultsCopyWithImpl<$Res, $Val extends SearchResults>
    implements $SearchResultsCopyWith<$Res> {
  _$SearchResultsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? titles = null,
    Object? people = null,
  }) {
    return _then(_value.copyWith(
      titles: null == titles
          ? _value.titles
          : titles // ignore: cast_nullable_to_non_nullable
              as List<MediaSummary>,
      people: null == people
          ? _value.people
          : people // ignore: cast_nullable_to_non_nullable
              as List<SearchPersonResult>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchResultsImplCopyWith<$Res>
    implements $SearchResultsCopyWith<$Res> {
  factory _$$SearchResultsImplCopyWith(
          _$SearchResultsImpl value, $Res Function(_$SearchResultsImpl) then) =
      __$$SearchResultsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MediaSummary> titles, List<SearchPersonResult> people});
}

/// @nodoc
class __$$SearchResultsImplCopyWithImpl<$Res>
    extends _$SearchResultsCopyWithImpl<$Res, _$SearchResultsImpl>
    implements _$$SearchResultsImplCopyWith<$Res> {
  __$$SearchResultsImplCopyWithImpl(
      _$SearchResultsImpl _value, $Res Function(_$SearchResultsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? titles = null,
    Object? people = null,
  }) {
    return _then(_$SearchResultsImpl(
      titles: null == titles
          ? _value._titles
          : titles // ignore: cast_nullable_to_non_nullable
              as List<MediaSummary>,
      people: null == people
          ? _value._people
          : people // ignore: cast_nullable_to_non_nullable
              as List<SearchPersonResult>,
    ));
  }
}

/// @nodoc

class _$SearchResultsImpl implements _SearchResults {
  const _$SearchResultsImpl(
      {final List<MediaSummary> titles = const <MediaSummary>[],
      final List<SearchPersonResult> people = const <SearchPersonResult>[]})
      : _titles = titles,
        _people = people;

  final List<MediaSummary> _titles;
  @override
  @JsonKey()
  List<MediaSummary> get titles {
    if (_titles is EqualUnmodifiableListView) return _titles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_titles);
  }

  final List<SearchPersonResult> _people;
  @override
  @JsonKey()
  List<SearchPersonResult> get people {
    if (_people is EqualUnmodifiableListView) return _people;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_people);
  }

  @override
  String toString() {
    return 'SearchResults(titles: $titles, people: $people)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultsImpl &&
            const DeepCollectionEquality().equals(other._titles, _titles) &&
            const DeepCollectionEquality().equals(other._people, _people));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_titles),
      const DeepCollectionEquality().hash(_people));

  /// Create a copy of SearchResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResultsImplCopyWith<_$SearchResultsImpl> get copyWith =>
      __$$SearchResultsImplCopyWithImpl<_$SearchResultsImpl>(this, _$identity);
}

abstract class _SearchResults implements SearchResults {
  const factory _SearchResults(
      {final List<MediaSummary> titles,
      final List<SearchPersonResult> people}) = _$SearchResultsImpl;

  @override
  List<MediaSummary> get titles;
  @override
  List<SearchPersonResult> get people;

  /// Create a copy of SearchResults
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResultsImplCopyWith<_$SearchResultsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
