// test/plugins/host/storage_host_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/plugins/host/storage_host.dart';

void main() {
  late StreamloadDatabase db;
  late StorageHost host;

  setUp(() {
    db = StreamloadDatabase.test(NativeDatabase.memory());
    host = StorageHost(db.pluginKvDao);
  });

  tearDown(() => db.close());

  test('set + get round-trip per plugin', () async {
    await host.set('echo', 'session', 'abc');
    expect(await host.get('echo', 'session'), 'abc');
    expect(await host.get('echo', 'missing'), isNull);
  });

  test('namespaces stay isolated per plugin', () async {
    await host.set('echo', 'k', 'echo_val');
    await host.set('sc', 'k', 'sc_val');
    expect(await host.get('echo', 'k'), 'echo_val');
    expect(await host.get('sc', 'k'), 'sc_val');
  });

  test('delete drops the row', () async {
    await host.set('echo', 'k', 'v');
    await host.delete('echo', 'k');
    expect(await host.get('echo', 'k'), isNull);
  });
}
