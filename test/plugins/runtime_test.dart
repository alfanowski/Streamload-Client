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

  test('plugin keeps its identity across awaits — every host call carries the plugin name', () async {
    // Regression test for a bug where __sl_currentPlugin was reset
    // synchronously after fn.apply returned its Promise, so any host call
    // made AFTER the first await landed under a null plugin name.
    final logs = <String>[];
    final hostApi2 = HostApi(
      http: HttpHost(),
      storage: StorageHost(db.pluginKvDao),
      log: LogHost(sink: (_, tag, msg) => logs.add('$tag|$msg')),
    );
    final rt = await PluginRuntime.create(hostApi: hostApi2);
    addTearDown(rt.dispose);

    const src = '''
export const meta = {
  short_name: "twocall",
  display_name: "Two Call",
  version: "1.0.0",
  api_version: 1,
  capabilities: ["movie"],
};

export async function search(_q) {
  await host.log.info("first");
  await host.log.info("second");
  await host.log.info("third");
  return [];
}

export async function getSeasons(_e) { return []; }
export async function getEpisodes(_s) { return []; }
export async function getStreams(_t) { return { manifest_url: "x", headers: {} }; }
''';

    final p = await rt.mount(src);
    await p.search('q');
    expect(logs, [
      'plugin:twocall|first',
      'plugin:twocall|second',
      'plugin:twocall|third',
    ]);
  });

  test('two plugins do not leak host identity across each other', () async {
    // Mount two plugins that each log their own name. Even with overlapping
    // calls, each plugin's host calls must report only its own identity.
    final logs = <String>[];
    final hostApi2 = HostApi(
      http: HttpHost(),
      storage: StorageHost(db.pluginKvDao),
      log: LogHost(sink: (_, tag, msg) => logs.add('$tag|$msg')),
    );
    final rt = await PluginRuntime.create(hostApi: hostApi2);
    addTearDown(rt.dispose);

    String src(String name) => '''
export const meta = {
  short_name: "$name",
  display_name: "$name",
  version: "1.0.0",
  api_version: 1,
  capabilities: ["movie"],
};
export async function search(_q) {
  await host.log.info("hi from $name");
  return [];
}
export async function getSeasons(_e) { return []; }
export async function getEpisodes(_s) { return []; }
export async function getStreams(_t) { return { manifest_url: "x", headers: {} }; }
''';

    final a = await rt.mount(src('alpha'));
    final b = await rt.mount(src('bravo'));

    // Fire concurrently — both must report their own short_name.
    await Future.wait([a.search('x'), b.search('y')]);

    expect(logs, containsAll([
      'plugin:alpha|hi from alpha',
      'plugin:bravo|hi from bravo',
    ]));
    // No log should be misattributed.
    expect(logs.where((l) => l.startsWith('plugin:alpha|') && l.contains('bravo')), isEmpty);
    expect(logs.where((l) => l.startsWith('plugin:bravo|') && l.contains('alpha')), isEmpty);
  });
}
