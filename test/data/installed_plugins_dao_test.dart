// test/data/installed_plugins_dao_test.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/data/local/schema/installed_plugins.dart';

void main() {
  late StreamloadDatabase db;

  setUp(() {
    db = StreamloadDatabase.test(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('upsert + listAll round-trip', () async {
    await db.installedPluginsDao.upsert(InstalledPluginsCompanion.insert(
      shortName: 'echo',
      version: '1.0.0',
      sha256: 'aa' * 32,
      filePath: '/cache/plugins/echo.js',
    ));
    final rows = await db.installedPluginsDao.listAll();
    expect(rows, hasLength(1));
    expect(rows.first.shortName, 'echo');
    expect(rows.first.enabled, isTrue);
  });

  test('upsert overwrites existing row by short_name PK', () async {
    await db.installedPluginsDao.upsert(InstalledPluginsCompanion.insert(
      shortName: 'echo', version: '1.0.0',
      sha256: 'aa' * 32, filePath: '/x',
    ));
    await db.installedPluginsDao.upsert(InstalledPluginsCompanion.insert(
      shortName: 'echo', version: '1.0.1',
      sha256: 'bb' * 32, filePath: '/y',
    ));
    final row = (await db.installedPluginsDao.listAll()).single;
    expect(row.version, '1.0.1');
    expect(row.sha256, 'bb' * 32);
    expect(row.filePath, '/y');
  });

  test('setEnabled flips the flag', () async {
    await db.installedPluginsDao.upsert(InstalledPluginsCompanion.insert(
      shortName: 'echo', version: '1.0.0',
      sha256: 'aa' * 32, filePath: '/x',
    ));
    await db.installedPluginsDao.setEnabled('echo', false);
    final row = (await db.installedPluginsDao.listAll()).single;
    expect(row.enabled, isFalse);
  });

  test('delete drops the row', () async {
    await db.installedPluginsDao.upsert(InstalledPluginsCompanion.insert(
      shortName: 'echo', version: '1.0.0',
      sha256: 'aa' * 32, filePath: '/x',
    ));
    await db.installedPluginsDao.remove('echo');
    expect(await db.installedPluginsDao.listAll(), isEmpty);
  });
}
