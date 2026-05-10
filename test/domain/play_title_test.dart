// test/domain/play_title_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/domain/play_title.dart';
import 'package:streamload_client/plugins/meta.dart';
import 'package:streamload_client/plugins/plugin.dart';
import 'package:streamload_client/player/session.dart';

class _PluginMock extends Mock implements Plugin {}

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
  });

  test('startMovie calls plugin.getStreams, registers session, returns master URL', () async {
    when(() => plugin.getStreams(any())).thenAnswer((_) async => {
          'manifest_url': 'https://upstream/master.m3u8',
          'headers': {'Referer': 'https://up'},
          'is_drm': false,
        });

    final controller = PlayController(
      registry: registry,
      proxyBaseUrl: 'http://127.0.0.1:47821',
      pluginFor: (_) => plugin,
    );

    final url = await controller.startMovie(tmdbId: 42);
    expect(url, startsWith('http://127.0.0.1:47821/master/'));
    expect(url, endsWith('.m3u8'));

    final sid = url.split('/').last.replaceAll('.m3u8', '');
    final session = registry.get(sid);
    expect(session, isNotNull);
    expect(session!.upstreamMasterUrl, 'https://upstream/master.m3u8');
    expect(session.upstreamHeaders['Referer'], 'https://up');
  });

  test('startMovie throws when no plugin can satisfy the request', () async {
    final controller = PlayController(
      registry: registry,
      proxyBaseUrl: 'http://127.0.0.1:47821',
      pluginFor: (_) => null,
    );
    expect(
      () => controller.startMovie(tmdbId: 42),
      throwsA(isA<StateError>().having((e) => e.message, 'message', contains('no plugin'))),
    );
  });
}
