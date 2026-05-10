// test/data/user_settings_dao_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/local/database.dart';

void main() {
  late StreamloadDatabase db;

  setUp(() {
    db = StreamloadDatabase.test(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('getOrSeed returns defaults on first call', () async {
    final s = await db.userSettingsDao.getOrSeed();
    expect(s.audioPrefLang, 'ita');
    expect(s.subsPrefLang, 'ita');
    expect(s.theme, 'auto');
    expect(s.autoplayNextEpisode, true);
  });

  test('upsertFromServer overwrites and persists', () async {
    await db.userSettingsDao.getOrSeed();
    await db.userSettingsDao.upsertFromServer(
      audioPrefLang: 'eng',
      subsPrefLang: 'ita',
      qualityCapHeight: 1080,
      autoplayNextEpisode: false,
      skipIntro: false,
      theme: 'dark',
      locale: 'en-US',
    );
    final s = await db.userSettingsDao.getOrSeed();
    expect(s.audioPrefLang, 'eng');
    expect(s.theme, 'dark');
    expect(s.qualityCapHeight, 1080);
  });
}
