import 'package:drift/drift.dart';

@DataClassName('WatchlistRow')
class Watchlist extends Table {
  IntColumn get tmdbId => integer()();
  TextColumn get mediaType => text()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {tmdbId, mediaType};
}
