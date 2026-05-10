import 'package:drift/drift.dart';

@DataClassName('WatchProgressRow')
class WatchProgress extends Table {
  IntColumn get tmdbId => integer()();
  TextColumn get mediaType => text()();
  IntColumn get seasonNumber => integer().withDefault(const Constant(0))();
  IntColumn get episodeNumber => integer().withDefault(const Constant(0))();
  IntColumn get positionSeconds => integer()();
  IntColumn get durationSeconds => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {tmdbId, mediaType, seasonNumber, episodeNumber};
}
