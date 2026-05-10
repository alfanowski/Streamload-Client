// lib/data/local/daos/user_settings_dao.dart
import 'package:drift/drift.dart';

import '../database.dart';
import '../schema/user_settings.dart';

part 'user_settings_dao.g.dart';

@DriftAccessor(tables: [UserSettings])
class UserSettingsDao extends DatabaseAccessor<StreamloadDatabase>
    with _$UserSettingsDaoMixin {
  UserSettingsDao(super.db);

  /// The single-row settings record. Returns the inserted defaults if absent.
  Future<UserSettingsRow> getOrSeed() async {
    final existing = await (select(userSettings)
          ..where((t) => t.key.equals('user')))
        .getSingleOrNull();
    if (existing != null) return existing;
    await into(userSettings).insert(const UserSettingsCompanion());
    return (select(userSettings)..where((t) => t.key.equals('user')))
        .getSingle();
  }

  /// Upsert from server payload. Caller has already converted the API DTO.
  Future<void> upsertFromServer({
    required String audioPrefLang,
    required String subsPrefLang,
    required int? qualityCapHeight,
    required bool autoplayNextEpisode,
    required bool skipIntro,
    required String theme,
    required String locale,
  }) async {
    await into(userSettings).insertOnConflictUpdate(UserSettingsCompanion(
      key: const Value('user'),
      audioPrefLang: Value(audioPrefLang),
      subsPrefLang: Value(subsPrefLang),
      qualityCapHeight: Value(qualityCapHeight),
      autoplayNextEpisode: Value(autoplayNextEpisode),
      skipIntro: Value(skipIntro),
      theme: Value(theme),
      locale: Value(locale),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Stream<UserSettingsRow> watch() {
    return (select(userSettings)..where((t) => t.key.equals('user')))
        .watchSingleOrNull()
        .asyncMap((row) async => row ?? await getOrSeed());
  }
}
