import 'package:drift/drift.dart';

/// Backing store for the sandbox `host.storage` API (sub-plan #4).
/// Each plugin gets its own namespace; key is `(plugin_short_name, key)`.
@DataClassName('PluginKvRow')
class PluginKv extends Table {
  TextColumn get pluginShortName => text()();
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {pluginShortName, key};
}
