// test/plugins/runtime_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/plugins/host/http_host.dart';
import 'package:streamload_client/plugins/host/log_host.dart';
import 'package:streamload_client/plugins/host/storage_host.dart';
import 'package:streamload_client/plugins/host_api.dart';
import 'package:streamload_client/plugins/runtime.dart';

const _echoSource = '''
export const meta = {
  short_name: "echo",
  display_name: "Echo",
  version: "1.0.0",
  api_version: 1,
  capabilities: ["movie"],
};

export async function search(query) {
  return [{ id: "echo-1", title: query, type: "movie", service: "echo", url: "https://example.invalid/" + query }];
}

export async function getSeasons(_entry) { return []; }
export async function getEpisodes(_season) { return []; }

export async function getStreams(entry) {
  return { manifest_url: "https://example.invalid/master.m3u8", headers: {} };
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StreamloadDatabase db;
  late HostApi hostApi;
  late PluginRuntime runtime;

  setUp(() async {
    db = StreamloadDatabase.test(NativeDatabase.memory());
    hostApi = HostApi(
      http: HttpHost(),
      storage: StorageHost(db.pluginKvDao),
      log: LogHost(sink: (_, __, ___) {}),
    );
    runtime = await PluginRuntime.create(hostApi: hostApi);
  });

  tearDown(() async {
    await runtime.dispose();
    await db.close();
  });

  test('mount + Plugin.search returns the echo synthetic shape', () async {
    final plugin = await runtime.mount(_echoSource);
    expect(plugin.meta.shortName, 'echo');
    final results = await plugin.search('hello');
    expect(results, hasLength(1));
    expect(results.first['title'], 'hello');
    expect(results.first['service'], 'echo');
  });

  test('mount validates meta and rejects bad source', () async {
    expect(
      () => runtime.mount('export const meta = { short_name: "BAD-NAME", display_name: "x", version: "1.0.0", api_version: 1, capabilities: ["movie"] };'),
      throwsA(isA<StateError>().having((e) => e.message, 'message', contains('short_name'))),
    );
  });

  test('atomic swap: a failed mount leaves the previous version active', () async {
    await runtime.mount(_echoSource);
    final before = await runtime.callable('echo')!.search('a');
    expect(before.first['title'], 'a');

    // Try to mount a corrupt source for the same short_name.
    expect(
      () => runtime.mount(_echoSource.replaceFirst(
        'capabilities: ["movie"]',
        'capabilities: ["movie:made_up"]',
      )),
      throwsA(isA<StateError>().having((e) => e.message, 'message', contains('capabilities'))),
    );

    // Original still callable.
    final after = await runtime.callable('echo')!.search('b');
    expect(after.first['title'], 'b');
  });

  test('unmount drops the plugin', () async {
    await runtime.mount(_echoSource);
    await runtime.unmount('echo');
    expect(runtime.callable('echo'), isNull);
  });
}
