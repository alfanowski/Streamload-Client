// lib/data/local/database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'schema/catalog_items.dart';
import 'schema/catalog_sources.dart';
import 'schema/favorites.dart';
import 'schema/installed_plugins.dart';
import 'schema/outbox.dart';
import 'schema/plugin_kv.dart';
import 'schema/tv_episodes.dart';
import 'schema/user_settings.dart';
import 'schema/watch_progress.dart';
import 'schema/watchlist.dart';
import 'daos/catalog_dao.dart';
import 'daos/user_settings_dao.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  CatalogItems,
  TvEpisodes,
  CatalogSources,
  WatchProgress,
  Favorites,
  Watchlist,
  UserSettings,
  Outbox,
  InstalledPlugins,
  PluginKv,
], daos: [
  CatalogDao,
  UserSettingsDao,
])
class StreamloadDatabase extends _$StreamloadDatabase {
  StreamloadDatabase() : super(_open());
  StreamloadDatabase.test(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() {
    // drift_flutter handles platform-appropriate paths (macOS application
    // support directory) and threading.
    return driftDatabase(name: 'streamload_v3');
  }
}
