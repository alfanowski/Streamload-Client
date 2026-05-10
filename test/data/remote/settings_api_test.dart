// test/data/remote/settings_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/endpoints/settings_api.dart';
import 'package:streamload_client/domain/models/settings.dart';

class _ClientMock extends Mock implements ApiClient {}

void main() {
  test('get returns parsed UserSettingsModel', () async {
    final client = _ClientMock();
    when(() => client.getJson('/api/settings')).thenAnswer((_) async => {
          'audio_pref_lang': 'eng',
          'subs_pref_lang': 'ita',
          'quality_cap_height': 1080,
          'autoplay_next_episode': false,
          'skip_intro': false,
          'theme': 'dark',
          'locale': 'en-US',
        });
    final s = await SettingsApi(client).get();
    expect(s.audioPrefLang, 'eng');
    expect(s.theme, 'dark');
    expect(s.qualityCapHeight, 1080);
  });

  test('update PUTs the serialized settings', () async {
    final client = _ClientMock();
    final input = const UserSettingsModel(theme: 'dark');
    when(() => client.putJson('/api/settings', body: input.toJson()))
        .thenAnswer((_) async => input.toJson());
    final out = await SettingsApi(client).update(input);
    expect(out.theme, 'dark');
  });
}
