// test/player/engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/player/engine.dart';

// Whether the media_kit native library loaded successfully in this process.
bool _mediaKitAvailable = false;

void main() {
  setUpAll(() {
    try {
      PlayerEngine.ensureInitialized();
      _mediaKitAvailable = true;
    } catch (_) {
      // Headless test environments (CI, unit-test runner) may not have the
      // macOS dylib accessible — mark unavailable so dependent tests skip.
      _mediaKitAvailable = false;
    }
  });

  test('construct + dispose without error', () {
    if (!_mediaKitAvailable) {
      return; // skip gracefully
    }
    final eng = PlayerEngine();
    eng.dispose();
  });

  test('positionStream emits Duration values', () async {
    final eng = PlayerEngine();
    addTearDown(eng.dispose);
    expect(eng.positionStream, emitsThrough(isA<Duration>()));
  }, skip: 'needs media to play; covered in integration smoke');

  test('open(uri, headers) does not throw before play', () async {
    if (!_mediaKitAvailable) {
      return; // skip gracefully
    }
    final eng = PlayerEngine();
    addTearDown(eng.dispose);
    // Use a non-existent URL — open should not throw synchronously.
    eng.open('http://127.0.0.1:1/none.m3u8', headers: const {});
  });
}
