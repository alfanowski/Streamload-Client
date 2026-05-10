import 'package:drift/drift.dart';

@DataClassName('TvEpisodeRow')
class TvEpisodes extends Table {
  IntColumn get tmdbId => integer()();
  TextColumn get mediaType => text().withDefault(const Constant('tv'))();
  IntColumn get seasonNumber => integer()();
  IntColumn get episodeNumber => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get overview => text().nullable()();
  DateTimeColumn get airDate => dateTime().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  TextColumn get stillUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {tmdbId, mediaType, seasonNumber, episodeNumber};
}
