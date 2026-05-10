// lib/plugins/meta.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meta.freezed.dart';
part 'meta.g.dart';

const Set<String> kAllowedCapabilities = {
  'movie',
  'movie:anime',
  'movie:kids',
  'movie:documentary',
  'tv',
  'tv:anime',
  'tv:kids',
  'tv:documentary',
  'tv:reality',
  'tv:news',
  'tv:sport',
};

final RegExp _shortNameRe = RegExp(r'^[a-z][a-z0-9_]{1,15}$');
final RegExp _semverRe =
    RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.-]+)?$');

@freezed
class PluginMeta with _$PluginMeta {
  const factory PluginMeta({
    @JsonKey(name: 'short_name') required String shortName,
    @JsonKey(name: 'display_name') required String displayName,
    required String version,
    @JsonKey(name: 'api_version') required int apiVersion,
    required List<String> capabilities,
    @JsonKey(name: 'min_app_version') String? minAppVersion,
  }) = _PluginMeta;

  factory PluginMeta.fromJson(Map<String, dynamic> json) =>
      _$PluginMetaFromJson(json);

  /// Returns null if the payload satisfies the contract; otherwise a
  /// human-readable string describing the first failure (substring will
  /// include the offending field name).
  static String? validate(Map<String, dynamic> json) {
    final shortName = json['short_name'];
    if (shortName is! String || !_shortNameRe.hasMatch(shortName)) {
      return 'meta.short_name must match ${_shortNameRe.pattern}';
    }
    final displayName = json['display_name'];
    if (displayName is! String || displayName.isEmpty) {
      return 'meta.display_name must be a non-empty string';
    }
    final version = json['version'];
    if (version is! String || !_semverRe.hasMatch(version)) {
      return 'meta.version must be semver';
    }
    final apiVersion = json['api_version'];
    if (apiVersion != 1) {
      return 'meta.api_version must be 1';
    }
    final caps = json['capabilities'];
    if (caps is! List || caps.isEmpty) {
      return 'meta.capabilities must be a non-empty array';
    }
    for (final c in caps) {
      if (c is! String || !kAllowedCapabilities.contains(c)) {
        return 'meta.capabilities contains unknown value: $c';
      }
    }
    return null;
  }
}
