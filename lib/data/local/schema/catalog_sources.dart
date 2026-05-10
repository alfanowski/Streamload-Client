import 'package:drift/drift.dart';

/// LOCAL ONLY. The plugin runtime in sub-plan #4 fills this. Never synced
/// to the operator's backend (radioactive — would link the operator to
/// upstream pirate URLs).
@DataClassName('CatalogSourceRow')
class CatalogSources extends Table {
  IntColumn get tmdbId => integer()();
  TextColumn get mediaType => text()();
  TextColumn get pluginShortName => text()();
  TextColumn get serviceUrl => text()();
  TextColumn get serviceMediaId => text()();
  IntColumn get qualityMaxHeight => integer().nullable()();
  TextColumn get audioLangsJson => text().withDefault(const Constant('[]'))();
  TextColumn get subsLangsJson => text().withDefault(const Constant('[]'))();
  IntColumn get successCount => integer().withDefault(const Constant(0))();
  IntColumn get failureCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastVerifiedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {tmdbId, mediaType, pluginShortName};
}
