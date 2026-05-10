// lib/state/plugin_runtime_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../plugins/host/http_host.dart';
import '../plugins/host/log_host.dart';
import '../plugins/host/storage_host.dart';
import '../plugins/host_api.dart';
import '../plugins/runtime.dart';
import 'database_provider.dart';

/// Long-lived PluginRuntime. Built lazily on first watch.
final pluginRuntimeProvider = FutureProvider<PluginRuntime>((ref) async {
  final db = ref.watch(databaseProvider);
  final hostApi = HostApi(
    http: HttpHost(),
    storage: StorageHost(db.pluginKvDao),
    log: LogHost(),
  );
  final runtime = await PluginRuntime.create(hostApi: hostApi);
  ref.onDispose(runtime.dispose);
  return runtime;
});
