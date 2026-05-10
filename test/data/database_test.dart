// test/data/database_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/local/database.dart';

void main() {
  late StreamloadDatabase db;

  setUp(() {
    db = StreamloadDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('schema v1 is created with all 10 tables', () async {
    final tables = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    ).get();
    final names = tables.map((r) => r.read<String>('name')).toList();
    expect(
      names,
      containsAll([
        'catalog_items',
        'catalog_sources',
        'favorites',
        'installed_plugins',
        'outbox',
        'plugin_kv',
        'tv_episodes',
        'user_settings',
        'watch_progress',
        'watchlist',
      ]),
    );
  });

  test('schemaVersion is 1', () {
    expect(db.schemaVersion, 1);
  });
}
