// test/state/player_engine_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/player/engine.dart';
import 'package:streamload_client/state/player_engine_provider.dart';

bool _mediaKitAvailable = false;

void main() {
  setUpAll(() {
    try {
      PlayerEngine.ensureInitialized();
      _mediaKitAvailable = true;
    } catch (_) {
      _mediaKitAvailable = false;
    }
  });

  test('playerEngineProvider returns a PlayerEngine instance', () {
    if (!_mediaKitAvailable) return; // skip gracefully on headless CI

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final engine = container.read(playerEngineProvider);
    expect(engine, isA<PlayerEngine>());
  });

  test('playerEngineProvider returns a new instance after dispose (autoDispose)', () {
    if (!_mediaKitAvailable) return; // skip gracefully on headless CI

    final container = ProviderContainer();

    // Read and hold a listener so the provider stays alive.
    final subscription = container.listen(playerEngineProvider, (_, __) {});
    final engine1 = container.read(playerEngineProvider);

    // Release the listener — the autoDispose provider can now be cleaned up.
    subscription.close();

    // After the listener is gone the provider disposes; a new read returns
    // a fresh instance.
    final engine2 = container.read(playerEngineProvider);
    expect(identical(engine1, engine2), isFalse);

    container.dispose();
  });
}
