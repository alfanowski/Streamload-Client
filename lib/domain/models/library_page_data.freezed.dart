// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_page_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LibraryPageData _$LibraryPageDataFromJson(Map<String, dynamic> json) {
  return _LibraryPageData.fromJson(json);
}

/// @nodoc
mixin _$LibraryPageData {
  List<MediaSummary> get items => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  @JsonKey(name: 'per_page')
  int get perPage => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this LibraryPageData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LibraryPageData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LibraryPageDataCopyWith<LibraryPageData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LibraryPageDataCopyWith<$Res> {
  factory $LibraryPageDataCopyWith(
          LibraryPageData value, $Res Function(LibraryPageData) then) =
      _$LibraryPageDataCopyWithImpl<$Res, LibraryPageData>;
  @useResult
  $Res call(
      {List<MediaSummary> items,
      int page,
      @JsonKey(name: 'per_page') int perPage,
      int total});
}

/// @nodoc
class _$LibraryPageDataCopyWithImpl<$Res, $Val extends LibraryPageData>
    implements $LibraryPageDataCopyWith<$Res> {
  _$LibraryPageDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LibraryPageData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? perPage = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MediaSummary>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      perPage: null == perPage
          ? _value.perPage
          : perPage // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LibraryPageDataImplCopyWith<$Res>
    implements $LibraryPageDataCopyWith<$Res> {
  factory _$$LibraryPageDataImplCopyWith(_$LibraryPageDataImpl value,
          $Res Function(_$LibraryPageDataImpl) then) =
      __$$LibraryPageDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<MediaSummary> items,
      int page,
      @JsonKey(name: 'per_page') int perPage,
      int total});
}

/// @nodoc
class __$$LibraryPageDataImplCopyWithImpl<$Res>
    extends _$LibraryPageDataCopyWithImpl<$Res, _$LibraryPageDataImpl>
    implements _$$LibraryPageDataImplCopyWith<$Res> {
  __$$LibraryPageDataImplCopyWithImpl(
      _$LibraryPageDataImpl _value, $Res Function(_$LibraryPageDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of LibraryPageData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? perPage = null,
    Object? total = null,
  }) {
    return _then(_$LibraryPageDataImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MediaSummary>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      perPage: null == perPage
          ? _value.perPage
          : perPage // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LibraryPageDataImpl implements _LibraryPageData {
  const _$LibraryPageDataImpl(
      {required final List<MediaSummary> items,
      required this.page,
      @JsonKey(name: 'per_page') required this.perPage,
      required this.total})
      : _items = items;

  factory _$LibraryPageDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$LibraryPageDataImplFromJson(json);

  final List<MediaSummary> _items;
  @override
  List<MediaSummary> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int page;
  @override
  @JsonKey(name: 'per_page')
  final int perPage;
  @override
  final int total;

  @override
  String toString() {
    return 'LibraryPageData(items: $items, page: $page, perPage: $perPage, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LibraryPageDataImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.perPage, perPage) || other.perPage == perPage) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_items), page, perPage, total);

  /// Create a copy of LibraryPageData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LibraryPageDataImplCopyWith<_$LibraryPageDataImpl> get copyWith =>
      __$$LibraryPageDataImplCopyWithImpl<_$LibraryPageDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LibraryPageDataImplToJson(
      this,
    );
  }
}

abstract class _LibraryPageData implements LibraryPageData {
  const factory _LibraryPageData(
      {required final List<MediaSummary> items,
      required final int page,
      @JsonKey(name: 'per_page') required final int perPage,
      required final int total}) = _$LibraryPageDataImpl;

  factory _LibraryPageData.fromJson(Map<String, dynamic> json) =
      _$LibraryPageDataImpl.fromJson;

  @override
  List<MediaSummary> get items;
  @override
  int get page;
  @override
  @JsonKey(name: 'per_page')
  int get perPage;
  @override
  int get total;

  /// Create a copy of LibraryPageData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LibraryPageDataImplCopyWith<_$LibraryPageDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
