// lib/plugins/registry.dart

class RegistryEntry {
  const RegistryEntry({
    required this.shortName,
    required this.file,
    required this.version,
    required this.sha256,
    this.minAppVersion,
  });

  final String shortName;
  final String file;
  final String version;
  final String sha256;
  final String? minAppVersion;

  factory RegistryEntry.fromJson(Map<String, dynamic> json) {
    return RegistryEntry(
      shortName: json['short_name'] as String,
      file: json['file'] as String,
      version: json['version'] as String,
      sha256: json['sha256'] as String,
      minAppVersion: json['min_app_version'] as String?,
    );
  }
}

class InstalledRecord {
  const InstalledRecord({
    required this.shortName,
    required this.version,
    required this.sha256,
  });

  final String shortName;
  final String version;
  final String sha256;
}

class RegistryDiff {
  const RegistryDiff({
    required this.added,
    required this.changed,
    required this.removed,
    required this.unchanged,
  });

  /// Plugins in remote but not in local.
  final List<RegistryEntry> added;

  /// Plugins in both, with a different sha256.
  final List<RegistryEntry> changed;

  /// short_names in local but not in remote.
  final List<String> removed;

  /// Plugins in both with the same sha256.
  final List<RegistryEntry> unchanged;

  static RegistryDiff compute({
    required List<RegistryEntry> remote,
    required List<InstalledRecord> installed,
  }) {
    final byName = {for (final r in installed) r.shortName: r};
    final added = <RegistryEntry>[];
    final changed = <RegistryEntry>[];
    final unchanged = <RegistryEntry>[];

    final seenRemote = <String>{};
    for (final r in remote) {
      seenRemote.add(r.shortName);
      final local = byName[r.shortName];
      if (local == null) {
        added.add(r);
      } else if (local.sha256 != r.sha256) {
        changed.add(r);
      } else {
        unchanged.add(r);
      }
    }

    final removed = installed
        .where((i) => !seenRemote.contains(i.shortName))
        .map((i) => i.shortName)
        .toList();

    return RegistryDiff(
      added: added,
      changed: changed,
      removed: removed,
      unchanged: unchanged,
    );
  }
}
