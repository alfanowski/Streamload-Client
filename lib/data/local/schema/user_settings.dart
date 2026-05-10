import 'package:drift/drift.dart';

/// Single-row mirror of /api/settings. The single row uses key='user'.
@DataClassName('UserSettingsRow')
class UserSettings extends Table {
  TextColumn get key => text().withDefault(const Constant('user'))();
  TextColumn get audioPrefLang => text().withDefault(const Constant('ita'))();
  TextColumn get subsPrefLang => text().withDefault(const Constant('ita'))();
  IntColumn get qualityCapHeight => integer().nullable()();
  BoolColumn get autoplayNextEpisode => boolean().withDefault(const Constant(true))();
  BoolColumn get skipIntro => boolean().withDefault(const Constant(true))();
  TextColumn get theme => text().withDefault(const Constant('auto'))();
  TextColumn get locale => text().withDefault(const Constant('it-IT'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}
