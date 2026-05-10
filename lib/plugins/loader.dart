// lib/plugins/loader.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../data/local/daos/installed_plugins_dao.dart';
import '../data/local/database.dart';
import '../infra/logger.dart';
import 'github_client.dart';
import 'registry.dart';
import 'runtime.dart';

class RefreshResult {
  RefreshResult({
    required this.mounted,
    required this.failed,
    required this.removed,
  });

  /// short_names that were freshly mounted (added or changed).
  final List<String> mounted;

  /// short_names that failed sha256 / parse / validation.
  final List<String> failed;

  /// short_names dropped because the remote no longer lists them.
  final List<String> removed;
}

class PluginLoader {
  PluginLoader({
    required this.github,
    required this.runtime,
    required this.installed,
  });

  final GithubClient github;
  final PluginRuntime runtime;
  final InstalledPluginsDao installed;
  final _log = Logger('plugin.loader');

  /// Pull the registry, diff against installed, fetch what changed, sha256-
  /// verify, mount on success / leave previous version on failure.
  Future<RefreshResult> refresh() async {
    final remoteJson = await github.getRegistry();
    final remote = (remoteJson['plugins'] as List)
        .cast<Map<String, dynamic>>()
        .map(RegistryEntry.fromJson)
        .toList();

    final installedRows = await installed.listAll();
    final installedRecords = installedRows
        .map((r) => InstalledRecord(
              shortName: r.shortName,
              version: r.version,
              sha256: r.sha256,
            ))
        .toList();

    final diff = RegistryDiff.compute(remote: remote, installed: installedRecords);

    final mounted = <String>[];
    final failed = <String>[];

    Future<void> handle(RegistryEntry entry) async {
      try {
        final source = await github.getPluginSource(entry.file);
        final actualSha = sha256.convert(utf8.encode(source)).toString();
        if (actualSha != entry.sha256) {
          throw StateError(
            'sha256 mismatch for ${entry.shortName} '
            '(registry=${entry.sha256.substring(0, 12)}…, '
            'actual=${actualSha.substring(0, 12)}…)',
          );
        }
        await runtime.mount(source);
        await installed.upsert(InstalledPluginsCompanion.insert(
          shortName: entry.shortName,
          version: entry.version,
          sha256: entry.sha256,
          filePath: entry.file,
        ));
        mounted.add(entry.shortName);
      } catch (e, st) {
        _log.error('load failed for ${entry.shortName}', e, st);
        failed.add(entry.shortName);
      }
    }

    for (final e in diff.added) {
      await handle(e);
    }
    for (final e in diff.changed) {
      await handle(e);
    }
    // Re-mount unchanged plugins that aren't currently in the runtime — covers
    // app restart, where installed_plugins survives but the JS runtime starts empty.
    for (final e in diff.unchanged) {
      if (runtime.callable(e.shortName) == null) {
        await handle(e);
      }
    }

    final removed = <String>[];
    for (final shortName in diff.removed) {
      await runtime.unmount(shortName);
      await installed.remove(shortName);
      removed.add(shortName);
    }

    return RefreshResult(mounted: mounted, failed: failed, removed: removed);
  }
}
