import 'package:drift/drift.dart';

@DataClassName('CatalogItemRow')
class CatalogItems extends Table {
  IntColumn get tmdbId => integer()();
  TextColumn get mediaType => text()();
  TextColumn get title => text()();
  TextColumn get originalTitle => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get posterUrl => text().nullable()();
  TextColumn get backdropUrl => text().nullable()();
  TextColumn get overview => text().nullable()();
  RealColumn get rating => real().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  IntColumn get seasonsCount => integer().nullable()();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get metadataFetchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {tmdbId, mediaType};
}
