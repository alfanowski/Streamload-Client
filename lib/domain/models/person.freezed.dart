// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'person.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Person _$PersonFromJson(Map<String, dynamic> json) {
  return _Person.fromJson(json);
}

/// @nodoc
mixin _$Person {
  @JsonKey(name: 'tmdb_id')
  int get tmdbId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get biography => throw _privateConstructorUsedError;
  String? get birthday =>
      throw _privateConstructorUsedError; // ISO "YYYY-MM-DD"
  String? get deathday =>
      throw _privateConstructorUsedError; // ISO date or null
  @JsonKey(name: 'place_of_birth')
  String? get placeOfBirth => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_url')
  String? get profileUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'also_known_as')
  List<String> get alsoKnownAs => throw _privateConstructorUsedError;
  @JsonKey(name: 'known_for_department')
  String? get knownForDepartment => throw _privateConstructorUsedError;

  /// Serializes this Person to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonCopyWith<Person> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonCopyWith<$Res> {
  factory $PersonCopyWith(Person value, $Res Function(Person) then) =
      _$PersonCopyWithImpl<$Res, Person>;
  @useResult
  $Res call(
      {@JsonKey(name: 'tmdb_id') int tmdbId,
      String name,
      String? biography,
      String? birthday,
      String? deathday,
      @JsonKey(name: 'place_of_birth') String? placeOfBirth,
      @JsonKey(name: 'profile_url') String? profileUrl,
      @JsonKey(name: 'also_known_as') List<String> alsoKnownAs,
      @JsonKey(name: 'known_for_department') String? knownForDepartment});
}

/// @nodoc
class _$PersonCopyWithImpl<$Res, $Val extends Person>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmdbId = null,
    Object? name = null,
    Object? biography = freezed,
    Object? birthday = freezed,
    Object? deathday = freezed,
    Object? placeOfBirth = freezed,
    Object? profileUrl = freezed,
    Object? alsoKnownAs = null,
    Object? knownForDepartment = freezed,
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
      biography: freezed == biography
          ? _value.biography
          : biography // ignore: cast_nullable_to_non_nullable
              as String?,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String?,
      deathday: freezed == deathday
          ? _value.deathday
          : deathday // ignore: cast_nullable_to_non_nullable
              as String?,
      placeOfBirth: freezed == placeOfBirth
          ? _value.placeOfBirth
          : placeOfBirth // ignore: cast_nullable_to_non_nullable
              as String?,
      profileUrl: freezed == profileUrl
          ? _value.profileUrl
          : profileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      alsoKnownAs: null == alsoKnownAs
          ? _value.alsoKnownAs
          : alsoKnownAs // ignore: cast_nullable_to_non_nullable
              as List<String>,
      knownForDepartment: freezed == knownForDepartment
          ? _value.knownForDepartment
          : knownForDepartment // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonImplCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$$PersonImplCopyWith(
          _$PersonImpl value, $Res Function(_$PersonImpl) then) =
      __$$PersonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'tmdb_id') int tmdbId,
      String name,
      String? biography,
      String? birthday,
      String? deathday,
      @JsonKey(name: 'place_of_birth') String? placeOfBirth,
      @JsonKey(name: 'profile_url') String? profileUrl,
      @JsonKey(name: 'also_known_as') List<String> alsoKnownAs,
      @JsonKey(name: 'known_for_department') String? knownForDepartment});
}

/// @nodoc
class __$$PersonImplCopyWithImpl<$Res>
    extends _$PersonCopyWithImpl<$Res, _$PersonImpl>
    implements _$$PersonImplCopyWith<$Res> {
  __$$PersonImplCopyWithImpl(
      _$PersonImpl _value, $Res Function(_$PersonImpl) _then)
      : super(_value, _then);

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmdbId = null,
    Object? name = null,
    Object? biography = freezed,
    Object? birthday = freezed,
    Object? deathday = freezed,
    Object? placeOfBirth = freezed,
    Object? profileUrl = freezed,
    Object? alsoKnownAs = null,
    Object? knownForDepartment = freezed,
  }) {
    return _then(_$PersonImpl(
      tmdbId: null == tmdbId
          ? _value.tmdbId
          : tmdbId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      biography: freezed == biography
          ? _value.biography
          : biography // ignore: cast_nullable_to_non_nullable
              as String?,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String?,
      deathday: freezed == deathday
          ? _value.deathday
          : deathday // ignore: cast_nullable_to_non_nullable
              as String?,
      placeOfBirth: freezed == placeOfBirth
          ? _value.placeOfBirth
          : placeOfBirth // ignore: cast_nullable_to_non_nullable
              as String?,
      profileUrl: freezed == profileUrl
          ? _value.profileUrl
          : profileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      alsoKnownAs: null == alsoKnownAs
          ? _value._alsoKnownAs
          : alsoKnownAs // ignore: cast_nullable_to_non_nullable
              as List<String>,
      knownForDepartment: freezed == knownForDepartment
          ? _value.knownForDepartment
          : knownForDepartment // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonImpl implements _Person {
  const _$PersonImpl(
      {@JsonKey(name: 'tmdb_id') required this.tmdbId,
      required this.name,
      this.biography,
      this.birthday,
      this.deathday,
      @JsonKey(name: 'place_of_birth') this.placeOfBirth,
      @JsonKey(name: 'profile_url') this.profileUrl,
      @JsonKey(name: 'also_known_as')
      final List<String> alsoKnownAs = const <String>[],
      @JsonKey(name: 'known_for_department') this.knownForDepartment})
      : _alsoKnownAs = alsoKnownAs;

  factory _$PersonImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonImplFromJson(json);

  @override
  @JsonKey(name: 'tmdb_id')
  final int tmdbId;
  @override
  final String name;
  @override
  final String? biography;
  @override
  final String? birthday;
// ISO "YYYY-MM-DD"
  @override
  final String? deathday;
// ISO date or null
  @override
  @JsonKey(name: 'place_of_birth')
  final String? placeOfBirth;
  @override
  @JsonKey(name: 'profile_url')
  final String? profileUrl;
  final List<String> _alsoKnownAs;
  @override
  @JsonKey(name: 'also_known_as')
  List<String> get alsoKnownAs {
    if (_alsoKnownAs is EqualUnmodifiableListView) return _alsoKnownAs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alsoKnownAs);
  }

  @override
  @JsonKey(name: 'known_for_department')
  final String? knownForDepartment;

  @override
  String toString() {
    return 'Person(tmdbId: $tmdbId, name: $name, biography: $biography, birthday: $birthday, deathday: $deathday, placeOfBirth: $placeOfBirth, profileUrl: $profileUrl, alsoKnownAs: $alsoKnownAs, knownForDepartment: $knownForDepartment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonImpl &&
            (identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.biography, biography) ||
                other.biography == biography) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            (identical(other.deathday, deathday) ||
                other.deathday == deathday) &&
            (identical(other.placeOfBirth, placeOfBirth) ||
                other.placeOfBirth == placeOfBirth) &&
            (identical(other.profileUrl, profileUrl) ||
                other.profileUrl == profileUrl) &&
            const DeepCollectionEquality()
                .equals(other._alsoKnownAs, _alsoKnownAs) &&
            (identical(other.knownForDepartment, knownForDepartment) ||
                other.knownForDepartment == knownForDepartment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      tmdbId,
      name,
      biography,
      birthday,
      deathday,
      placeOfBirth,
      profileUrl,
      const DeepCollectionEquality().hash(_alsoKnownAs),
      knownForDepartment);

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      __$$PersonImplCopyWithImpl<_$PersonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonImplToJson(
      this,
    );
  }
}

abstract class _Person implements Person {
  const factory _Person(
      {@JsonKey(name: 'tmdb_id') required final int tmdbId,
      required final String name,
      final String? biography,
      final String? birthday,
      final String? deathday,
      @JsonKey(name: 'place_of_birth') final String? placeOfBirth,
      @JsonKey(name: 'profile_url') final String? profileUrl,
      @JsonKey(name: 'also_known_as') final List<String> alsoKnownAs,
      @JsonKey(name: 'known_for_department')
      final String? knownForDepartment}) = _$PersonImpl;

  factory _Person.fromJson(Map<String, dynamic> json) = _$PersonImpl.fromJson;

  @override
  @JsonKey(name: 'tmdb_id')
  int get tmdbId;
  @override
  String get name;
  @override
  String? get biography;
  @override
  String? get birthday; // ISO "YYYY-MM-DD"
  @override
  String? get deathday; // ISO date or null
  @override
  @JsonKey(name: 'place_of_birth')
  String? get placeOfBirth;
  @override
  @JsonKey(name: 'profile_url')
  String? get profileUrl;
  @override
  @JsonKey(name: 'also_known_as')
  List<String> get alsoKnownAs;
  @override
  @JsonKey(name: 'known_for_department')
  String? get knownForDepartment;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
