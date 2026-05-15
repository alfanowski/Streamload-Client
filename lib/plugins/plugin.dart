// lib/plugins/plugin.dart
import '../infra/logger.dart';
import 'meta.dart';

final _log = Logger('plugin');

/// Forward declaration of the JS-evaluating callable. PluginRuntime supplies
/// the real implementation.
typedef PluginCall = Future<Object?> Function(
  String pluginShortName,
  String functionName,
  List<Object?> args,
);

/// Typed Dart-side handle to one mounted JS plugin.
///
/// Created by PluginRuntime; instances are cheap and disposable. Calling a
/// method on a stale instance after the plugin has been unmounted will throw
/// from the underlying runtime.
class Plugin {
  Plugin({
    required this.meta,
    required PluginCall call,
  }) : _call = call;

  final PluginMeta meta;
  final PluginCall _call;

  String get shortName => meta.shortName;

  Future<List<Map<String, dynamic>>> search(String query) async {
    return _callListMethod('search', [query]);
  }

  Future<List<Map<String, dynamic>>> getSeasons(Map<String, dynamic> entry) async {
    return _callListMethod('getSeasons', [entry]);
  }

  Future<List<Map<String, dynamic>>> getEpisodes(Map<String, dynamic> season) async {
    return _callListMethod('getEpisodes', [season]);
  }

  Future<Map<String, dynamic>> getStreams(Map<String, dynamic> target) async {
    final raw = await _call(meta.shortName, 'getStreams', [target]);
    if (raw == null) {
      throw StateError('plugin ${meta.shortName}.getStreams returned null');
    }
    if (raw is! Map) {
      throw StateError(
          'plugin ${meta.shortName}.getStreams returned ${raw.runtimeType} '
          'not Map — value: $raw');
    }
    return raw.cast<String, dynamic>();
  }

  /// Common envelope for list-returning JS calls. Loud when the JS returned
  /// a non-list — the previous `as List` cast threw a TypeError whose
  /// toString turned into noise; here we tell the caller what the JS
  /// actually returned, so debugging takes 1 round trip not 5.
  Future<List<Map<String, dynamic>>> _callListMethod(
    String method,
    List<Object?> args,
  ) async {
    final raw = await _call(meta.shortName, method, args);
    if (raw == null) {
      _log.warn('${meta.shortName}.$method returned null → treating as []');
      return const [];
    }
    if (raw is! List) {
      throw StateError(
        'plugin ${meta.shortName}.$method returned ${raw.runtimeType} '
        'instead of List — value: $raw',
      );
    }
    return raw.cast<Map<String, dynamic>>();
  }
}
