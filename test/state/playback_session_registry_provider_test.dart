// test/state/playback_session_registry_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/player/session.dart';
import 'package:streamload_client/state/playback_session_registry_provider.dart';

void main() {
  test('playbackSessionRegistryProvider returns a singleton PlaybackSessionRegistry', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final a = container.read(playbackSessionRegistryProvider);
    final b = container.read(playbackSessionRegistryProvider);
    expect(a, isA<PlaybackSessionRegistry>());
    expect(identical(a, b), isTrue);
  });

  test('registry provided by provider can store and retrieve sessions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registry = container.read(playbackSessionRegistryProvider);
    final session = PlaybackSession.create(
      tmdbId: 42,
      mediaType: 'movie',
      pluginShortName: 'test_plugin',
      upstreamMasterUrl: 'https://example.com/master.m3u8',
      upstreamHeaders: {},
    );
    registry.put(session);
    expect(registry.get(session.id), isNotNull);
  });
}
