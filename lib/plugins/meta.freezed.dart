// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PluginMeta _$PluginMetaFromJson(Map<String, dynamic> json) {
  return _PluginMeta.fromJson(json);
}

/// @nodoc
mixin _$PluginMeta {
  @JsonKey(name: 'short_name')
  String get shortName => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  @JsonKey(name: 'api_version')
  int get apiVersion => throw _privateConstructorUsedError;
  List<String> get capabilities => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_app_version')
  String? get minAppVersion => throw _privateConstructorUsedError;

  /// Serializes this PluginMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PluginMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PluginMetaCopyWith<PluginMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PluginMetaCopyWith<$Res> {
  factory $PluginMetaCopyWith(
          PluginMeta value, $Res Function(PluginMeta) then) =
      _$PluginMetaCopyWithImpl<$Res, PluginMeta>;
  @useResult
  $Res call(
      {@JsonKey(name: 'short_name') String shortName,
      @JsonKey(name: 'display_name') String displayName,
      String version,
      @JsonKey(name: 'api_version') int apiVersion,
      List<String> capabilities,
      @JsonKey(name: 'min_app_version') String? minAppVersion});
}

/// @nodoc
class _$PluginMetaCopyWithImpl<$Res, $Val extends PluginMeta>
    implements $PluginMetaCopyWith<$Res> {
  _$PluginMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PluginMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shortName = null,
    Object? displayName = null,
    Object? version = null,
    Object? apiVersion = null,
    Object? capabilities = null,
    Object? minAppVersion = freezed,
  }) {
    return _then(_value.copyWith(
      shortName: null == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      apiVersion: null == apiVersion
          ? _value.apiVersion
          : apiVersion // ignore: cast_nullable_to_non_nullable
              as int,
      capabilities: null == capabilities
          ? _value.capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minAppVersion: freezed == minAppVersion
          ? _value.minAppVersion
          : minAppVersion // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PluginMetaImplCopyWith<$Res>
    implements $PluginMetaCopyWith<$Res> {
  factory _$$PluginMetaImplCopyWith(
          _$PluginMetaImpl value, $Res Function(_$PluginMetaImpl) then) =
      __$$PluginMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'short_name') String shortName,
      @JsonKey(name: 'display_name') String displayName,
      String version,
      @JsonKey(name: 'api_version') int apiVersion,
      List<String> capabilities,
      @JsonKey(name: 'min_app_version') String? minAppVersion});
}

/// @nodoc
class __$$PluginMetaImplCopyWithImpl<$Res>
    extends _$PluginMetaCopyWithImpl<$Res, _$PluginMetaImpl>
    implements _$$PluginMetaImplCopyWith<$Res> {
  __$$PluginMetaImplCopyWithImpl(
      _$PluginMetaImpl _value, $Res Function(_$PluginMetaImpl) _then)
      : super(_value, _then);

  /// Create a copy of PluginMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shortName = null,
    Object? displayName = null,
    Object? version = null,
    Object? apiVersion = null,
    Object? capabilities = null,
    Object? minAppVersion = freezed,
  }) {
    return _then(_$PluginMetaImpl(
      shortName: null == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      apiVersion: null == apiVersion
          ? _value.apiVersion
          : apiVersion // ignore: cast_nullable_to_non_nullable
              as int,
      capabilities: null == capabilities
          ? _value._capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minAppVersion: freezed == minAppVersion
          ? _value.minAppVersion
          : minAppVersion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PluginMetaImpl implements _PluginMeta {
  const _$PluginMetaImpl(
      {@JsonKey(name: 'short_name') required this.shortName,
      @JsonKey(name: 'display_name') required this.displayName,
      required this.version,
      @JsonKey(name: 'api_version') required this.apiVersion,
      required final List<String> capabilities,
      @JsonKey(name: 'min_app_version') this.minAppVersion})
      : _capabilities = capabilities;

  factory _$PluginMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$PluginMetaImplFromJson(json);

  @override
  @JsonKey(name: 'short_name')
  final String shortName;
  @override
  @JsonKey(name: 'display_name')
  final String displayName;
  @override
  final String version;
  @override
  @JsonKey(name: 'api_version')
  final int apiVersion;
  final List<String> _capabilities;
  @override
  List<String> get capabilities {
    if (_capabilities is EqualUnmodifiableListView) return _capabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_capabilities);
  }

  @override
  @JsonKey(name: 'min_app_version')
  final String? minAppVersion;

  @override
  String toString() {
    return 'PluginMeta(shortName: $shortName, displayName: $displayName, version: $version, apiVersion: $apiVersion, capabilities: $capabilities, minAppVersion: $minAppVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PluginMetaImpl &&
            (identical(other.shortName, shortName) ||
                other.shortName == shortName) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.apiVersion, apiVersion) ||
                other.apiVersion == apiVersion) &&
            const DeepCollectionEquality()
                .equals(other._capabilities, _capabilities) &&
            (identical(other.minAppVersion, minAppVersion) ||
                other.minAppVersion == minAppVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      shortName,
      displayName,
      version,
      apiVersion,
      const DeepCollectionEquality().hash(_capabilities),
      minAppVersion);

  /// Create a copy of PluginMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PluginMetaImplCopyWith<_$PluginMetaImpl> get copyWith =>
      __$$PluginMetaImplCopyWithImpl<_$PluginMetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PluginMetaImplToJson(
      this,
    );
  }
}

abstract class _PluginMeta implements PluginMeta {
  const factory _PluginMeta(
          {@JsonKey(name: 'short_name') required final String shortName,
          @JsonKey(name: 'display_name') required final String displayName,
          required final String version,
          @JsonKey(name: 'api_version') required final int apiVersion,
          required final List<String> capabilities,
          @JsonKey(name: 'min_app_version') final String? minAppVersion}) =
      _$PluginMetaImpl;

  factory _PluginMeta.fromJson(Map<String, dynamic> json) =
      _$PluginMetaImpl.fromJson;

  @override
  @JsonKey(name: 'short_name')
  String get shortName;
  @override
  @JsonKey(name: 'display_name')
  String get displayName;
  @override
  String get version;
  @override
  @JsonKey(name: 'api_version')
  int get apiVersion;
  @override
  List<String> get capabilities;
  @override
  @JsonKey(name: 'min_app_version')
  String? get minAppVersion;

  /// Create a copy of PluginMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PluginMetaImplCopyWith<_$PluginMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
