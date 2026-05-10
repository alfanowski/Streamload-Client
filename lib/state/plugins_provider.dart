// lib/state/plugins_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../plugins/github_client.dart';
import '../plugins/loader.dart';
import 'database_provider.dart';
import 'github_pat_provider.dart';
import 'plugin_runtime_provider.dart';

/// Stream of installed plugins from drift. Empty until the first refresh.
final installedPluginsProvider =
    StreamProvider<List<InstalledPluginRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.installedPluginsDao.watchAll();
});

/// Repo coordinates — match the streamload-plugins repo.
const _kRepoOwner = 'alfanowski';
const _kRepoName = 'streamload-plugins';

/// Builds a [PluginLoader] using the current PAT. Throws if no PAT.
final pluginLoaderProvider = FutureProvider<PluginLoader>((ref) async {
  final pat = ref.watch(githubPatProvider).value;
  if (pat == null || pat.isEmpty) {
    throw StateError('github PAT not set');
  }
  final runtime = await ref.watch(pluginRuntimeProvider.future);
  final db = ref.watch(databaseProvider);
  return PluginLoader(
    github: GithubClient(owner: _kRepoOwner, repo: _kRepoName, token: pat),
    runtime: runtime,
    installed: db.installedPluginsDao,
  );
});

/// One-shot refresh trigger; UI shows a spinner while in-flight.
class PluginRefreshController extends StateNotifier<AsyncValue<RefreshResult?>> {
  PluginRefreshController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final loader = await _ref.read(pluginLoaderProvider.future);
      final result = await loader.refresh();
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final pluginRefreshControllerProvider = StateNotifierProvider<
    PluginRefreshController, AsyncValue<RefreshResult?>>((ref) {
  return PluginRefreshController(ref);
});
