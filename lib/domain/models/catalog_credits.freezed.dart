// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_credits.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CatalogCreditPerson _$CatalogCreditPersonFromJson(Map<String, dynamic> json) {
  return _CatalogCreditPerson.fromJson(json);
}

/// @nodoc
mixin _$CatalogCreditPerson {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get character => throw _privateConstructorUsedError;
  String? get job => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_url')
  String? get profileUrl => throw _privateConstructorUsedError;
  int? get order => throw _privateConstructorUsedError;

  /// Serializes this CatalogCreditPerson to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogCreditPerson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogCreditPersonCopyWith<CatalogCreditPerson> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogCreditPersonCopyWith<$Res> {
  factory $CatalogCreditPersonCopyWith(
          CatalogCreditPerson value, $Res Function(CatalogCreditPerson) then) =
      _$CatalogCreditPersonCopyWithImpl<$Res, CatalogCreditPerson>;
  @useResult
  $Res call(
      {int id,
      String name,
      String? character,
      String? job,
      @JsonKey(name: 'profile_url') String? profileUrl,
      int? order});
}

/// @nodoc
class _$CatalogCreditPersonCopyWithImpl<$Res, $Val extends CatalogCreditPerson>
    implements $CatalogCreditPersonCopyWith<$Res> {
  _$CatalogCreditPersonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogCreditPerson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? character = freezed,
    Object? job = freezed,
    Object? profileUrl = freezed,
    Object? order = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      character: freezed == character
          ? _value.character
          : character // ignore: cast_nullable_to_non_nullable
              as String?,
      job: freezed == job
          ? _value.job
          : job // ignore: cast_nullable_to_non_nullable
              as String?,
      profileUrl: freezed == profileUrl
          ? _value.profileUrl
          : profileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CatalogCreditPersonImplCopyWith<$Res>
    implements $CatalogCreditPersonCopyWith<$Res> {
  factory _$$CatalogCreditPersonImplCopyWith(_$CatalogCreditPersonImpl value,
          $Res Function(_$CatalogCreditPersonImpl) then) =
      __$$CatalogCreditPersonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? character,
      String? job,
      @JsonKey(name: 'profile_url') String? profileUrl,
      int? order});
}

/// @nodoc
class __$$CatalogCreditPersonImplCopyWithImpl<$Res>
    extends _$CatalogCreditPersonCopyWithImpl<$Res, _$CatalogCreditPersonImpl>
    implements _$$CatalogCreditPersonImplCopyWith<$Res> {
  __$$CatalogCreditPersonImplCopyWithImpl(_$CatalogCreditPersonImpl _value,
      $Res Function(_$CatalogCreditPersonImpl) _then)
      : super(_value, _then);

  /// Create a copy of CatalogCreditPerson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? character = freezed,
    Object? job = freezed,
    Object? profileUrl = freezed,
    Object? order = freezed,
  }) {
    return _then(_$CatalogCreditPersonImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      character: freezed == character
          ? _value.character
          : character // ignore: cast_nullable_to_non_nullable
              as String?,
      job: freezed == job
          ? _value.job
          : job // ignore: cast_nullable_to_non_nullable
              as String?,
      profileUrl: freezed == profileUrl
          ? _value.profileUrl
          : profileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogCreditPersonImpl implements _CatalogCreditPerson {
  const _$CatalogCreditPersonImpl(
      {required this.id,
      required this.name,
      this.character,
      this.job,
      @JsonKey(name: 'profile_url') this.profileUrl,
      this.order});

  factory _$CatalogCreditPersonImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogCreditPersonImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? character;
  @override
  final String? job;
  @override
  @JsonKey(name: 'profile_url')
  final String? profileUrl;
  @override
  final int? order;

  @override
  String toString() {
    return 'CatalogCreditPerson(id: $id, name: $name, character: $character, job: $job, profileUrl: $profileUrl, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogCreditPersonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.character, character) ||
                other.character == character) &&
            (identical(other.job, job) || other.job == job) &&
            (identical(other.profileUrl, profileUrl) ||
                other.profileUrl == profileUrl) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, character, job, profileUrl, order);

  /// Create a copy of CatalogCreditPerson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogCreditPersonImplCopyWith<_$CatalogCreditPersonImpl> get copyWith =>
      __$$CatalogCreditPersonImplCopyWithImpl<_$CatalogCreditPersonImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogCreditPersonImplToJson(
      this,
    );
  }
}

abstract class _CatalogCreditPerson implements CatalogCreditPerson {
  const factory _CatalogCreditPerson(
      {required final int id,
      required final String name,
      final String? character,
      final String? job,
      @JsonKey(name: 'profile_url') final String? profileUrl,
      final int? order}) = _$CatalogCreditPersonImpl;

  factory _CatalogCreditPerson.fromJson(Map<String, dynamic> json) =
      _$CatalogCreditPersonImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get character;
  @override
  String? get job;
  @override
  @JsonKey(name: 'profile_url')
  String? get profileUrl;
  @override
  int? get order;

  /// Create a copy of CatalogCreditPerson
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogCreditPersonImplCopyWith<_$CatalogCreditPersonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CatalogCredits _$CatalogCreditsFromJson(Map<String, dynamic> json) {
  return _CatalogCredits.fromJson(json);
}

/// @nodoc
mixin _$CatalogCredits {
  List<CatalogCreditPerson> get cast => throw _privateConstructorUsedError;
  List<CatalogCreditPerson> get crew => throw _privateConstructorUsedError;

  /// Serializes this CatalogCredits to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogCredits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogCreditsCopyWith<CatalogCredits> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogCreditsCopyWith<$Res> {
  factory $CatalogCreditsCopyWith(
          CatalogCredits value, $Res Function(CatalogCredits) then) =
      _$CatalogCreditsCopyWithImpl<$Res, CatalogCredits>;
  @useResult
  $Res call({List<CatalogCreditPerson> cast, List<CatalogCreditPerson> crew});
}

/// @nodoc
class _$CatalogCreditsCopyWithImpl<$Res, $Val extends CatalogCredits>
    implements $CatalogCreditsCopyWith<$Res> {
  _$CatalogCreditsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogCredits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cast = null,
    Object? crew = null,
  }) {
    return _then(_value.copyWith(
      cast: null == cast
          ? _value.cast
          : cast // ignore: cast_nullable_to_non_nullable
              as List<CatalogCreditPerson>,
      crew: null == crew
          ? _value.crew
          : crew // ignore: cast_nullable_to_non_nullable
              as List<CatalogCreditPerson>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CatalogCreditsImplCopyWith<$Res>
    implements $CatalogCreditsCopyWith<$Res> {
  factory _$$CatalogCreditsImplCopyWith(_$CatalogCreditsImpl value,
          $Res Function(_$CatalogCreditsImpl) then) =
      __$$CatalogCreditsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CatalogCreditPerson> cast, List<CatalogCreditPerson> crew});
}

/// @nodoc
class __$$CatalogCreditsImplCopyWithImpl<$Res>
    extends _$CatalogCreditsCopyWithImpl<$Res, _$CatalogCreditsImpl>
    implements _$$CatalogCreditsImplCopyWith<$Res> {
  __$$CatalogCreditsImplCopyWithImpl(
      _$CatalogCreditsImpl _value, $Res Function(_$CatalogCreditsImpl) _then)
      : super(_value, _then);

  /// Create a copy of CatalogCredits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cast = null,
    Object? crew = null,
  }) {
    return _then(_$CatalogCreditsImpl(
      cast: null == cast
          ? _value._cast
          : cast // ignore: cast_nullable_to_non_nullable
              as List<CatalogCreditPerson>,
      crew: null == crew
          ? _value._crew
          : crew // ignore: cast_nullable_to_non_nullable
              as List<CatalogCreditPerson>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogCreditsImpl implements _CatalogCredits {
  const _$CatalogCreditsImpl(
      {final List<CatalogCreditPerson> cast = const <CatalogCreditPerson>[],
      final List<CatalogCreditPerson> crew = const <CatalogCreditPerson>[]})
      : _cast = cast,
        _crew = crew;

  factory _$CatalogCreditsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogCreditsImplFromJson(json);

  final List<CatalogCreditPerson> _cast;
  @override
  @JsonKey()
  List<CatalogCreditPerson> get cast {
    if (_cast is EqualUnmodifiableListView) return _cast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cast);
  }

  final List<CatalogCreditPerson> _crew;
  @override
  @JsonKey()
  List<CatalogCreditPerson> get crew {
    if (_crew is EqualUnmodifiableListView) return _crew;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_crew);
  }

  @override
  String toString() {
    return 'CatalogCredits(cast: $cast, crew: $crew)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogCreditsImpl &&
            const DeepCollectionEquality().equals(other._cast, _cast) &&
            const DeepCollectionEquality().equals(other._crew, _crew));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_cast),
      const DeepCollectionEquality().hash(_crew));

  /// Create a copy of CatalogCredits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogCreditsImplCopyWith<_$CatalogCreditsImpl> get copyWith =>
      __$$CatalogCreditsImplCopyWithImpl<_$CatalogCreditsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogCreditsImplToJson(
      this,
    );
  }
}

abstract class _CatalogCredits implements CatalogCredits {
  const factory _CatalogCredits(
      {final List<CatalogCreditPerson> cast,
      final List<CatalogCreditPerson> crew}) = _$CatalogCreditsImpl;

  factory _CatalogCredits.fromJson(Map<String, dynamic> json) =
      _$CatalogCreditsImpl.fromJson;

  @override
  List<CatalogCreditPerson> get cast;
  @override
  List<CatalogCreditPerson> get crew;

  /// Create a copy of CatalogCredits
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogCreditsImplCopyWith<_$CatalogCreditsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
