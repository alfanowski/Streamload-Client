// test/domain/play_title_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/domain/play_title.dart';
import 'package:streamload_client/player/session.dart';
import 'package:streamload_client/plugins/meta.dart';
import 'package:streamload_client/plugins/plugin.dart';

class _PluginMock extends Mock implements Plugin {}

Future<TitleHint> _fakeResolver(int tmdbId, String mediaType) async =>
    const TitleHint(title: 'Test', year: 2020);

void main() {
  late PlaybackSessionRegistry registry;
  late _PluginMock plugin;

  setUp(() {
    registry = PlaybackSessionRegistry(ttl: const Duration(hours: 1));
    plugin = _PluginMock();
    when(() => plugin.meta).thenReturn(const PluginMeta(
      shortName: 'echo',
      displayName: 'Echo',
      version: '1.0.0',
      apiVersion: 1,
      capabilities: ['movie'],
    ));
    // Default: search returns one matching entry. Override per-test if needed.
    when(() => plugin.search(any())).thenAnswer((_) async => [
          {'id': '1:test:it', 'title': 'Test', 'type': 'movie', 'year': 2020}
        ]);
  });

  PlayController makeController({Plugin? Function((
      {int tmdbId,
      String mediaType,
      })?)? pluginFor}) =>
      PlayController(
        registry: registry,
        proxyBaseUrl: 'http://127.0.0.1:47821',
        pluginFor: pluginFor == null ? (_) => plugin : (q) => pluginFor(q),
        resolveTitle: _fakeResolver,
      );

  test('startMovie: search → match → getStreams → register session (proxy mode)',
      () async {
    when(() => plugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://upstream/master.m3u8',
          'headers': {'Referer': 'https://up'},
          'is_drm': false,
        });

    final controller = makeController();
    final url = await controller.startMovie(tmdbId: 42);
    expect(url, startsWith('http://127.0.0.1:47821/master/'));
    expect(url, endsWith('.m3u8'));

    verify(() => plugin.search('Test')).called(1);

    final sid = url.split('/').last.replaceAll('.m3u8', '');
    final session = registry.get(sid);
    expect(session, isNotNull);
    expect(session!.upstreamMasterUrl, 'https://upstream/master.m3u8');
    expect(session.upstreamHeaders['Referer'], 'https://up');
  });

  test('startMovie throws when no plugin can satisfy the request', () async {
    final controller = makeController(pluginFor: (_) => null);
    expect(
      () => controller.startMovie(tmdbId: 42),
      throwsA(isA<StateError>()
          .having((e) => e.message, 'message', contains('Nessun plugin'))),
    );
  });

  test('startMovie throws when plugin.search returns no result', () async {
    when(() => plugin.search(any())).thenAnswer((_) async => []);
    final controller = makeController();
    expect(
      () => controller.startMovie(tmdbId: 42),
      throwsA(isA<StateError>()
          .having((e) => e.message, 'message', contains('non trova'))),
    );
  });

  test('startMovie BYPASSES proxy when stream needs no headers + no DRM', () async {
    when(() => plugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url':
              'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8',
          'headers': const <String, dynamic>{},
          'is_drm': false,
        });
    final controller = makeController();
    final url = await controller.startMovie(tmdbId: 42);
    expect(url, startsWith('https://devstreaming-cdn.apple.com/'));
    expect(url, isNot(startsWith('http://127.0.0.1')));
  });

  test('startMovie uses proxy when headers are required', () async {
    when(() => plugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://upstream/master.m3u8',
          'headers': {'Referer': 'https://up'},
          'is_drm': false,
        });
    final controller = makeController();
    final url = await controller.startMovie(tmdbId: 42);
    expect(url, startsWith('http://127.0.0.1:47821/master/'));
  });

  test('startMovie uses proxy when stream is DRM', () async {
    when(() => plugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://upstream/master.m3u8',
          'headers': const <String, dynamic>{},
          'is_drm': true,
          'drm_keys': {'k': 'v'},
        });
    final controller = makeController();
    final url = await controller.startMovie(tmdbId: 42);
    expect(url, startsWith('http://127.0.0.1:47821/master/'));
  });

  test('match prefers exact title + year over loose hits', () async {
    when(() => plugin.search(any())).thenAnswer((_) async => [
          {'id': 'wrong:a:it', 'title': 'Test Sequel', 'type': 'movie', 'year': 2021},
          {'id': 'right:b:it', 'title': 'Test', 'type': 'movie', 'year': 2020},
          {'id': 'old:c:it', 'title': 'Test', 'type': 'movie', 'year': 1985},
        ]);
    when(() => plugin.getStreams(any())).thenAnswer((invocation) async => {
          'manifest_url':
              'https://upstream/${(invocation.positionalArguments[0]['id'])}.m3u8',
          'headers': {'Referer': 'x'},
          'is_drm': false,
        });
    final controller = makeController();
    await controller.startMovie(tmdbId: 42);
    // Verify the right entry was picked by inspecting the captured call.
    final calls = verify(() => plugin.getStreams(captureAny())).captured;
    final picked = calls.first as Map<String, dynamic>;
    expect(picked['id'], 'right:b:it');
  });
}
