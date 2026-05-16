// lib/state/plugins_provider.dart
//
// Phase I2 (sub-plan 8) cleanup: dropped `installedPluginsProvider`. The old
// PluginsPage was the only consumer that needed to *watch* the full installed
// list; after Phase H1 ripped that page out, nothing surfaced the list any
// more. The plugin loader still reads + writes db.installedPluginsDao directly
// for the actual runtime install/disable flow — that path is unchanged.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../plugins/github_client.dart';
import '../plugins/loader.dart';
import 'database_provider.dart';
import 'github_token_provider.dart';
import 'plugin_runtime_provider.dart';

/// Repo coordinates — match the streamload-plugins repo.
const _kRepoOwner = 'alfanowski';
const _kRepoName = 'streamload-plugins';

/// Builds a [PluginLoader] using the current token. Throws if no token.
final pluginLoaderProvider = FutureProvider<PluginLoader>((ref) async {
  final pat = ref.watch(githubTokenProvider).value;
  if (pat == null || pat.isEmpty) {
    throw StateError('github token not set');
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
class PluginRefreshController extends StateNotifier<AsyncValue<RefreshSummary>> {
  PluginRefreshController(this._ref) : super(AsyncData(RefreshSummary.notRun()));

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
    PluginRefreshController, AsyncValue<RefreshSummary>>((ref) {
  return PluginRefreshController(ref);
});
