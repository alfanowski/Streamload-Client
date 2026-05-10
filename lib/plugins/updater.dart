// lib/plugins/updater.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../infra/logger.dart';
import '../state/plugins_provider.dart';

/// Periodically refreshes the plugin registry while the app is open.
///
/// Call [start] once after auth bootstrap. [start] fires one immediate refresh
/// then schedules a [Timer.periodic] at 30-minute intervals. Call [stop] (or
/// let [pluginUpdaterProvider]'s `ref.onDispose` handle it) to cancel the
/// timer when the app tears down.
class PluginUpdater {
  PluginUpdater(this._ref);

  final Ref _ref;
  static final _log = Logger('plugin-updater');
  Timer? _timer;

  /// Start a foreground poll: one immediate refresh + every 30 minutes.
  void start() {
    _refresh();
    _timer ??= Timer.periodic(const Duration(minutes: 30), (_) => _refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _refresh() async {
    try {
      await _ref.read(pluginRefreshControllerProvider.notifier).refresh();
      _log.info('plugin refresh tick complete');
    } catch (e) {
      _log.warn('plugin refresh tick skipped: $e');
    }
  }
}

/// Riverpod provider that wires up and auto-disposes a [PluginUpdater].
final pluginUpdaterProvider = Provider<PluginUpdater>((ref) {
  final updater = PluginUpdater(ref);
  ref.onDispose(updater.stop);
  return updater;
});
