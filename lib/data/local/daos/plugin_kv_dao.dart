// lib/data/local/daos/plugin_kv_dao.dart
import 'package:drift/drift.dart';

import '../database.dart';
import '../schema/plugin_kv.dart';

part 'plugin_kv_dao.g.dart';

@DriftAccessor(tables: [PluginKv])
class PluginKvDao extends DatabaseAccessor<StreamloadDatabase>
    with _$PluginKvDaoMixin {
  PluginKvDao(super.db);

  Future<String?> get(String pluginShortName, String key) async {
    final row = await (select(pluginKv)
          ..where((t) =>
              t.pluginShortName.equals(pluginShortName) & t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String pluginShortName, String key, String value) async {
    await into(pluginKv).insertOnConflictUpdate(PluginKvCompanion(
      pluginShortName: Value(pluginShortName),
      key: Value(key),
      value: Value(value),
    ));
  }

  Future<void> remove(String pluginShortName, String key) async {
    await (attachedDatabase.delete(pluginKv)
          ..where((t) =>
              t.pluginShortName.equals(pluginShortName) & t.key.equals(key)))
        .go();
  }

  Future<void> clearForPlugin(String pluginShortName) async {
    await (attachedDatabase.delete(pluginKv)
          ..where((t) => t.pluginShortName.equals(pluginShortName)))
        .go();
  }
}
