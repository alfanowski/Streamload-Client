// lib/state/plugin_access_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../plugins/loader.dart';
import 'plugins_provider.dart';

enum PluginAccess { unknown, available, noAccess, networkError }

/// Derived from the most recent [pluginRefreshControllerProvider] state.
/// `unknown` while loading or before any refresh has run (notRun outcome).
final pluginAccessProvider = Provider<PluginAccess>((ref) {
  final state = ref.watch(pluginRefreshControllerProvider);
  return state.maybeWhen(
    data: (summary) {
      switch (summary.outcome) {
        case RefreshOutcome.success:
          return PluginAccess.available;
        case RefreshOutcome.noAccess:
          return PluginAccess.noAccess;
        case RefreshOutcome.networkError:
          return PluginAccess.networkError;
        case RefreshOutcome.notRun:
          return PluginAccess.unknown;
      }
    },
    orElse: () => PluginAccess.unknown,
  );
});
