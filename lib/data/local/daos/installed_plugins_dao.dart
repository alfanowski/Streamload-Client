// lib/data/local/daos/installed_plugins_dao.dart
import 'package:drift/drift.dart';

import '../database.dart';
import '../schema/installed_plugins.dart';

part 'installed_plugins_dao.g.dart';

@DriftAccessor(tables: [InstalledPlugins])
class InstalledPluginsDao extends DatabaseAccessor<StreamloadDatabase>
    with _$InstalledPluginsDaoMixin {
  InstalledPluginsDao(super.db);

  Future<List<InstalledPluginRow>> listAll() {
    return select(installedPlugins).get();
  }

  Stream<List<InstalledPluginRow>> watchAll() {
    return select(installedPlugins).watch();
  }

  Future<InstalledPluginRow?> getByName(String shortName) {
    return (select(installedPlugins)
          ..where((t) => t.shortName.equals(shortName)))
        .getSingleOrNull();
  }

  Future<void> upsert(InstalledPluginsCompanion entry) async {
    await into(installedPlugins).insertOnConflictUpdate(entry);
  }

  Future<void> setEnabled(String shortName, bool enabled) async {
    await (update(installedPlugins)
          ..where((t) => t.shortName.equals(shortName)))
        .write(InstalledPluginsCompanion(enabled: Value(enabled)));
  }

  Future<void> remove(String shortName) async {
    await (attachedDatabase.delete(installedPlugins)
          ..where((t) => t.shortName.equals(shortName)))
        .go();
  }
}
