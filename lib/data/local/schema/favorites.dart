import 'package:drift/drift.dart';

@DataClassName('FavoriteRow')
class Favorites extends Table {
  IntColumn get tmdbId => integer()();
  TextColumn get mediaType => text()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {tmdbId, mediaType};
}
