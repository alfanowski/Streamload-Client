// lib/plugins/plugin.dart
import 'meta.dart';

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
    final raw = await _call(meta.shortName, 'search', [query]);
    return (raw as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getSeasons(Map<String, dynamic> entry) async {
    final raw = await _call(meta.shortName, 'getSeasons', [entry]);
    return (raw as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getEpisodes(Map<String, dynamic> season) async {
    final raw = await _call(meta.shortName, 'getEpisodes', [season]);
    return (raw as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getStreams(Map<String, dynamic> target) async {
    final raw = await _call(meta.shortName, 'getStreams', [target]);
    return (raw as Map).cast<String, dynamic>();
  }
}
