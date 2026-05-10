// test/data/plugin_kv_dao_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/local/database.dart';

void main() {
  late StreamloadDatabase db;

  setUp(() => db = StreamloadDatabase.test(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('set + get round-trip per (plugin, key)', () async {
    await db.pluginKvDao.set('echo', 'token', 'abc');
    expect(await db.pluginKvDao.get('echo', 'token'), 'abc');
    expect(await db.pluginKvDao.get('echo', 'missing'), isNull);
  });

  test('set is overwrite-on-conflict', () async {
    await db.pluginKvDao.set('echo', 'token', 'v1');
    await db.pluginKvDao.set('echo', 'token', 'v2');
    expect(await db.pluginKvDao.get('echo', 'token'), 'v2');
  });

  test('delete removes the row', () async {
    await db.pluginKvDao.set('echo', 'token', 'abc');
    await db.pluginKvDao.remove('echo', 'token');
    expect(await db.pluginKvDao.get('echo', 'token'), isNull);
  });

  test('namespaces are isolated across plugins', () async {
    await db.pluginKvDao.set('echo', 'shared_key', 'echo_val');
    await db.pluginKvDao.set('sc', 'shared_key', 'sc_val');
    expect(await db.pluginKvDao.get('echo', 'shared_key'), 'echo_val');
    expect(await db.pluginKvDao.get('sc', 'shared_key'), 'sc_val');
  });

  test('clearForPlugin wipes only that plugin', () async {
    await db.pluginKvDao.set('echo', 'a', '1');
    await db.pluginKvDao.set('echo', 'b', '2');
    await db.pluginKvDao.set('sc', 'a', '3');
    await db.pluginKvDao.clearForPlugin('echo');
    expect(await db.pluginKvDao.get('echo', 'a'), isNull);
    expect(await db.pluginKvDao.get('echo', 'b'), isNull);
    expect(await db.pluginKvDao.get('sc', 'a'), '3');
  });
}
