// test/state/playback_prefs_provider_test.dart
//
// Verifies PlaybackPrefsNotifier reads/writes SharedPreferences keys
// 'playback.audio_lang' and 'playback.subtitle_lang' and that the
// defaults are 'it' / 'off' when no value is stored.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamload_client/state/playback_prefs_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to it / off when no stored value', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final prefs = await container.read(playbackPrefsProvider.future);
    expect(prefs.audioLang, 'it');
    expect(prefs.subtitleLang, 'off');
  });

  test('reads stored values back', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'playback.audio_lang': 'en',
      'playback.subtitle_lang': 'it',
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final prefs = await container.read(playbackPrefsProvider.future);
    expect(prefs.audioLang, 'en');
    expect(prefs.subtitleLang, 'it');
  });

  test('setAudioLang persists and updates state', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Force the FutureProvider to materialize first.
    await container.read(playbackPrefsProvider.future);

    final notifier = container.read(playbackPrefsProvider.notifier);
    await notifier.setAudioLang('ja');

    final fresh = await container.read(playbackPrefsProvider.future);
    expect(fresh.audioLang, 'ja');

    final raw = await SharedPreferences.getInstance();
    expect(raw.getString('playback.audio_lang'), 'ja');
  });

  test('setSubtitleLang persists and updates state', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(playbackPrefsProvider.future);

    final notifier = container.read(playbackPrefsProvider.notifier);
    await notifier.setSubtitleLang('it');

    final fresh = await container.read(playbackPrefsProvider.future);
    expect(fresh.subtitleLang, 'it');

    final raw = await SharedPreferences.getInstance();
    expect(raw.getString('playback.subtitle_lang'), 'it');
  });
}
