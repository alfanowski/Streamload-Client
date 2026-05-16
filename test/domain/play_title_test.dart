// test/domain/play_title_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/domain/play_title.dart';
import 'package:streamload_client/player/session.dart';
import 'package:streamload_client/plugins/meta.dart';
import 'package:streamload_client/plugins/plugin.dart';
import 'package:streamload_client/plugins/routing/router.dart';
import 'package:streamload_client/plugins/runtime.dart';

class _PluginMock extends Mock implements Plugin {}
class _PluginRuntimeMock extends Mock implements PluginRuntime {}

Future<TitleHint> _fakeResolver(int tmdbId, String mediaType) async =>
    const TitleHint(title: 'Test', year: 2020);

void main() {
  late PlaybackSessionRegistry registry;
  late _PluginMock plugin;
  late _PluginRuntimeMock runtime;

  setUp(() {
    registry = PlaybackSessionRegistry(ttl: const Duration(hours: 1));
    plugin = _PluginMock();
    runtime = _PluginRuntimeMock();
    when(() => plugin.meta).thenReturn(const PluginMeta(
      shortName: 'echo',
      displayName: 'Echo',
      version: '1.0.0',
      apiVersion: 1,
      capabilities: ['movie'],
    ));
    when(() => runtime.all).thenReturn([plugin]);
    // Default: search returns one matching entry. Override per-test if needed.
    when(() => plugin.search(any())).thenAnswer((_) async => [
          {'id': '1:test:it', 'title': 'Test', 'type': 'movie', 'year': 2020}
        ]);
  });

  PlayController makeController({PluginRuntime? overrideRuntime}) =>
      PlayController(
        registry: registry,
        proxyBaseUrl: 'http://127.0.0.1:47821',
        router: ProviderRouter(runtime: overrideRuntime ?? runtime),
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

  test('startMovie throws when no plugin advertises matching capability',
      () async {
    final emptyRuntime = _PluginRuntimeMock();
    when(() => emptyRuntime.all).thenReturn(const []);
    final controller = makeController(overrideRuntime: emptyRuntime);
    expect(
      () => controller.startMovie(tmdbId: 42),
      throwsA(isA<StateError>()
          .having((e) => e.message, 'message', contains('Nessun plugin'))),
    );
  });

  test('startMovie throws when every plugin\'s search returns no result',
      () async {
    when(() => plugin.search(any())).thenAnswer((_) async => []);
    final controller = makeController();
    expect(
      () => controller.startMovie(tmdbId: 42),
      throwsA(isA<StateError>().having(
        (e) => e.message,
        'message',
        contains('Tutti i plugin hanno fallito'),
      )),
    );
  });

  test('startMovie BYPASSES proxy when stream needs no headers + no DRM',
      () async {
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

  test('startMovie skips DRM bundles and falls back to next plugin', () async {
    // Single DRM plugin → router scores 0 → all plugins "failed".
    when(() => plugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://upstream/master.m3u8',
          'headers': const <String, dynamic>{},
          'is_drm': true,
          'drm_keys': {'k': 'v'},
        });
    final controller = makeController();
    expect(
      () => controller.startMovie(tmdbId: 42),
      throwsA(isA<StateError>().having(
        (e) => e.message,
        'message',
        contains('Tutti i plugin hanno fallito'),
      )),
    );
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
    final calls = verify(() => plugin.getStreams(captureAny())).captured;
    final picked = calls.first as Map<String, dynamic>;
    expect(picked['id'], 'right:b:it');
  });

  test('match strips leading articles when comparing TMDB hint vs plugin title',
      () async {
    // TMDB returns "Il Commissario Montalbano"; plugin returns the title
    // without the leading article. Normalization should make these equal.
    when(() => plugin.search(any())).thenAnswer((_) async => [
          {
            'id': 'right',
            'title': 'Commissario Montalbano',
            'type': 'movie',
            'year': 1999
          },
        ]);
    when(() => plugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://upstream/master.m3u8',
          'headers': {'Referer': 'x'},
          'is_drm': false,
        });
    final resolver = (int _, String __) async =>
        const TitleHint(title: 'Il Commissario Montalbano', year: 1999);
    final controller = PlayController(
      registry: registry,
      proxyBaseUrl: 'http://127.0.0.1:47821',
      router: ProviderRouter(runtime: runtime),
      resolveTitle: resolver,
    );
    await controller.startMovie(tmdbId: 42);
    final calls = verify(() => plugin.getStreams(captureAny())).captured;
    final picked = calls.first as Map<String, dynamic>;
    expect(picked['id'], 'right');
  });

  test('match returns null when no result resembles the hint (no first-result fallback)',
      () async {
    // Plugin returns 3 unrelated results — none should be accepted by the new
    // tier-3 prefix logic.
    when(() => plugin.search(any())).thenAnswer((_) async => [
          {'id': 'a', 'title': 'Totally Different Show', 'type': 'movie', 'year': 2020},
          {'id': 'b', 'title': 'Another Wrong Title', 'type': 'movie', 'year': 2021},
          {'id': 'c', 'title': 'Yet Another', 'type': 'movie', 'year': 2019},
        ]);
    final controller = makeController();
    expect(
      () => controller.startMovie(tmdbId: 42),
      throwsA(isA<StateError>().having(
        (e) => e.message,
        'message',
        contains('Tutti i plugin hanno fallito'),
      )),
    );
    verifyNever(() => plugin.getStreams(any()));
  });

  test('match prefix REJECTS candidates 1.6x longer than hint (Pokemon !-> Detective Pikachu)',
      () async {
    // Hint "Pokemon" is 7 chars; "Pokemon Detective Pikachu" is 25 chars.
    // Should NOT be accepted as a tier-3 prefix match because the extra
    // tail makes it a different product, not a sub-edition.
    when(() => plugin.search(any())).thenAnswer((_) async => [
          {
            'id': 'wrong',
            'title': 'Pokemon Detective Pikachu',
            'type': 'movie',
            'year': 2019,
          },
        ]);
    final resolver = (int _, String __) async =>
        const TitleHint(title: 'Pokemon', year: 1997);
    final controller = PlayController(
      registry: registry,
      proxyBaseUrl: 'http://127.0.0.1:47821',
      router: ProviderRouter(runtime: runtime),
      resolveTitle: resolver,
    );
    expect(
      () => controller.startMovie(tmdbId: 42),
      throwsA(isA<StateError>().having(
        (e) => e.message,
        'message',
        contains('Tutti i plugin hanno fallito'),
      )),
    );
    verifyNever(() => plugin.getStreams(any()));
  });

  test('match prefix picks shortest title (Dragon Ball Z series over Movie 01)',
      () async {
    when(() => plugin.search(any())).thenAnswer((_) async => [
          {
            'id': 'long',
            'title': 'Dragon Ball Z Movie 01: La Vendetta Divina',
            'type': 'movie',
            'year': 1989
          },
          {
            'id': 'series',
            'title': 'Dragon Ball Z',
            'type': 'movie',
            'year': 1989
          },
        ]);
    when(() => plugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://upstream/master.m3u8',
          'headers': {'Referer': 'x'},
          'is_drm': false,
        });
    final resolver = (int _, String __) async =>
        const TitleHint(title: 'Dragon Ball Z', year: 1989);
    final controller = PlayController(
      registry: registry,
      proxyBaseUrl: 'http://127.0.0.1:47821',
      router: ProviderRouter(runtime: runtime),
      resolveTitle: resolver,
    );
    await controller.startMovie(tmdbId: 42);
    final calls = verify(() => plugin.getStreams(captureAny())).captured;
    final picked = calls.first as Map<String, dynamic>;
    // Tier-2 exact match should win, not tier-3 prefix.
    expect(picked['id'], 'series');
  });

  test('router scores by year-distance: AU 1999 beats SC 2023 for One Piece (1999) hint',
      () async {
    // Reproduction of the live One Piece bug: both plugins matched, but SC's
    // 2023 live-action came in faster than AU's 1999 anime. With first-success
    // semantics SC won; with collect+score+year-delta AU should win.
    final auPlugin = _PluginMock();
    when(() => auPlugin.meta).thenReturn(const PluginMeta(
      shortName: 'au',
      displayName: 'AnimeUnity',
      version: '1.0.0',
      apiVersion: 1,
      capabilities: ['tv:anime'],
    ));
    when(() => auPlugin.search(any())).thenAnswer((_) async => [
          {
            'id': 'au_op',
            'title': 'One Piece',
            'type': 'tv:anime',
            'year': 1999,
          }
        ]);
    when(() => auPlugin.getSeasons(any())).thenAnswer((_) async => [
          {'number': 1, 'id': 'au_s1'}
        ]);
    when(() => auPlugin.getEpisodes(any())).thenAnswer((invocation) async {
      // Simulate slow getEpisodes (the real AU paginates 1161 episodes).
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return [
        {'number': 1, 'id': 'au_e1'}
      ];
    });
    when(() => auPlugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://au/master.m3u8',
          'headers': const <String, dynamic>{},
          'is_drm': false,
        });

    final scPlugin = _PluginMock();
    when(() => scPlugin.meta).thenReturn(const PluginMeta(
      shortName: 'sc',
      displayName: 'StreamingCommunity',
      version: '1.0.2',
      apiVersion: 1,
      capabilities: ['tv'],
    ));
    when(() => scPlugin.search(any())).thenAnswer((_) async => [
          {
            'id': 'sc_op',
            'title': 'ONE PIECE',
            'type': 'tv',
            'year': 2023, // live-action
          }
        ]);
    when(() => scPlugin.getSeasons(any())).thenAnswer((_) async => [
          {'number': 1, 'id': 'sc_s1'}
        ]);
    when(() => scPlugin.getEpisodes(any())).thenAnswer((_) async => [
          {'number': 1, 'id': 'sc_e1'}
        ]);
    when(() => scPlugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://sc/master.m3u8',
          'headers': const <String, dynamic>{},
          'is_drm': false,
        });

    final mixedRuntime = _PluginRuntimeMock();
    when(() => mixedRuntime.all).thenReturn([auPlugin, scPlugin]);
    final resolver = (int _, String __) async =>
        const TitleHint(title: 'One Piece', year: 1999);
    final controller = PlayController(
      registry: registry,
      proxyBaseUrl: 'http://127.0.0.1:47821',
      router: ProviderRouter(runtime: mixedRuntime),
      resolveTitle: resolver,
    );

    final url = await controller.startEpisode(
      tmdbId: 37854,
      season: 1,
      episode: 1,
    );
    // AU has year delta 0, SC has year delta 24 → AU wins.
    expect(url, contains('au/master.m3u8'));
  });

  test('match strips accents: TMDB "Pokémon" matches plugin "Pokemon"',
      () async {
    when(() => plugin.search(any())).thenAnswer((_) async => [
          {'id': 'right', 'title': 'Pokemon', 'type': 'movie', 'year': 1997},
        ]);
    when(() => plugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://upstream/master.m3u8',
          'headers': const <String, dynamic>{},
          'is_drm': false,
        });
    final resolver = (int _, String __) async =>
        const TitleHint(title: 'Pokémon', year: 1997);
    final controller = PlayController(
      registry: registry,
      proxyBaseUrl: 'http://127.0.0.1:47821',
      router: ProviderRouter(runtime: runtime),
      resolveTitle: resolver,
    );
    await controller.startMovie(tmdbId: 42);
    final calls = verify(() => plugin.getStreams(captureAny())).captured;
    final picked = calls.first as Map<String, dynamic>;
    expect(picked['id'], 'right');
  });

  test('router fans out: first non-DRM bundle wins over a DRM-only plugin',
      () async {
    final drmPlugin = _PluginMock();
    when(() => drmPlugin.meta).thenReturn(const PluginMeta(
      shortName: 'drm_only',
      displayName: 'DRM Only',
      version: '1.0.0',
      apiVersion: 1,
      capabilities: ['movie'],
    ));
    when(() => drmPlugin.search(any())).thenAnswer((_) async => [
          {'id': 'd1', 'title': 'Test', 'type': 'movie', 'year': 2020}
        ]);
    when(() => drmPlugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://drm/master.m3u8',
          'headers': const <String, dynamic>{},
          'is_drm': true,
        });

    when(() => plugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://clean/master.m3u8',
          'headers': const <String, dynamic>{},
          'is_drm': false,
        });

    final mixedRuntime = _PluginRuntimeMock();
    when(() => mixedRuntime.all).thenReturn([drmPlugin, plugin]);
    final controller = makeController(overrideRuntime: mixedRuntime);

    final url = await controller.startMovie(tmdbId: 42);
    // Clean plugin should win — DRM plugin scored 0.
    expect(url, startsWith('https://clean/'));
  });
}
