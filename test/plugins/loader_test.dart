// test/plugins/loader_test.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/plugins/github_client.dart';
import 'package:streamload_client/plugins/host/http_host.dart';
import 'package:streamload_client/plugins/host/log_host.dart';
import 'package:streamload_client/plugins/host/storage_host.dart';
import 'package:streamload_client/plugins/host_api.dart';
import 'package:streamload_client/plugins/loader.dart';
import 'package:streamload_client/plugins/runtime.dart';

class _GhMock extends Mock implements GithubClient {}

// Inline echo fixture — mirrors /streamload-plugins/plugins/_fixture/echo.js
const _echoSource = r'''
export const meta = {
  short_name: "echo",
  display_name: "Echo (test fixture)",
  version: "1.0.0",
  api_version: 1,
  capabilities: ["movie"],
};

export async function search(query) {
  return [
    {
      id: "echo-1",
      title: query,
      url: `https://example.invalid/title/${encodeURIComponent(query)}`,
      type: "movie",
      service: "echo",
      year: null,
      genre: null,
      image_url: null,
      description: null,
    },
  ];
}

export async function getSeasons(_entry) {
  return [];
}

export async function getEpisodes(_season) {
  return [];
}

export async function getStreams(entry) {
  return {
    manifest_url: "https://example.invalid/master.m3u8",
    headers: { "X-Echo-Title": entry.title ?? "" },
    is_drm: false,
    drm_keys: null,
  };
}
''';

String _sha256OfString(String s) => sha256.convert(utf8.encode(s)).toString();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StreamloadDatabase db;
  late HostApi hostApi;
  late PluginRuntime runtime;
  late _GhMock gh;

  setUp(() async {
    db = StreamloadDatabase.test(NativeDatabase.memory());
    hostApi = HostApi(
      http: HttpHost(),
      storage: StorageHost(db.pluginKvDao),
      log: LogHost(sink: (_, __, ___) {}),
    );
    runtime = await PluginRuntime.create(hostApi: hostApi);
    gh = _GhMock();
  });

  tearDown(() async {
    await runtime.dispose();
    await db.close();
  });

  test('refresh: fetch registry + plugin file + sha256-verify + mount', () async {
    final hash = _sha256OfString(_echoSource);
    when(gh.getRegistry).thenAnswer((_) async => {
          'format_version': 1,
          'updated_at': '2026-05-10T00:00:00Z',
          'plugins': [
            {
              'short_name': 'echo',
              'file': 'plugins/_fixture/echo.js',
              'version': '1.0.0',
              'api_version': 1,
              'sha256': hash,
              'capabilities': ['movie'],
            }
          ],
        });
    when(() => gh.getPluginSource('plugins/_fixture/echo.js'))
        .thenAnswer((_) async => _echoSource);

    final loader = PluginLoader(
      github: gh,
      runtime: runtime,
      installed: db.installedPluginsDao,
    );
    final result = await loader.refresh();
    expect(result.mounted, ['echo']);
    expect(result.failed, isEmpty);

    final p = runtime.callable('echo');
    expect(p, isNotNull);
    final out = await p!.search('hello');
    expect(out.first['title'], 'hello');

    final installed = await db.installedPluginsDao.listAll();
    expect(installed.single.shortName, 'echo');
    expect(installed.single.sha256, hash);
  });

  test('refresh: sha256 mismatch → drop the file, do not mount', () async {
    when(gh.getRegistry).thenAnswer((_) async => {
          'format_version': 1,
          'updated_at': '2026-05-10T00:00:00Z',
          'plugins': [
            {
              'short_name': 'echo',
              'file': 'plugins/_fixture/echo.js',
              'version': '1.0.0',
              'api_version': 1,
              'sha256': 'ff' * 32, // wrong
              'capabilities': ['movie'],
            }
          ],
        });
    when(() => gh.getPluginSource('plugins/_fixture/echo.js'))
        .thenAnswer((_) async => _echoSource);

    final loader = PluginLoader(
      github: gh,
      runtime: runtime,
      installed: db.installedPluginsDao,
    );
    final result = await loader.refresh();
    expect(result.mounted, isEmpty);
    expect(result.failed, ['echo']);

    expect(runtime.callable('echo'), isNull);
    expect(await db.installedPluginsDao.listAll(), isEmpty);
  });

  test('refresh: unchanged + runtime empty (app restart) → re-mount', () async {
    // Pre-seed an installed plugin in DB but NOT in the runtime (simulates
    // app restart: drift row survives, JS runtime starts fresh).
    final hash = _sha256OfString(_echoSource);
    await db.installedPluginsDao.upsert(InstalledPluginsCompanion.insert(
      shortName: 'echo',
      version: '1.0.0',
      sha256: hash,
      filePath: 'plugins/_fixture/echo.js',
    ));
    expect(runtime.callable('echo'), isNull);

    when(gh.getRegistry).thenAnswer((_) async => {
          'format_version': 1,
          'updated_at': '2026-05-10T00:00:00Z',
          'plugins': [
            {
              'short_name': 'echo',
              'file': 'plugins/_fixture/echo.js',
              'version': '1.0.0',
              'api_version': 1,
              'sha256': hash,
              'capabilities': ['movie'],
            }
          ],
        });
    when(() => gh.getPluginSource('plugins/_fixture/echo.js'))
        .thenAnswer((_) async => _echoSource);

    final loader = PluginLoader(
      github: gh,
      runtime: runtime,
      installed: db.installedPluginsDao,
    );
    final result = await loader.refresh();
    expect(result.mounted, ['echo']);
    expect(runtime.callable('echo'), isNotNull);
  });

  test('refresh: removed-from-registry → unmount + delete row', () async {
    // Pre-seed an installed plugin.
    final hash = _sha256OfString(_echoSource);
    await db.installedPluginsDao.upsert(InstalledPluginsCompanion.insert(
      shortName: 'echo',
      version: '1.0.0',
      sha256: hash,
      filePath: 'plugins/_fixture/echo.js',
    ));
    await runtime.mount(_echoSource);

    when(gh.getRegistry).thenAnswer((_) async => {
          'format_version': 1,
          'updated_at': '2026-05-10T00:00:00Z',
          'plugins': const <Map<String, dynamic>>[],
        });

    final loader = PluginLoader(
      github: gh,
      runtime: runtime,
      installed: db.installedPluginsDao,
    );
    final result = await loader.refresh();
    expect(result.removed, ['echo']);
    expect(runtime.callable('echo'), isNull);
    expect(await db.installedPluginsDao.listAll(), isEmpty);
  });
}
