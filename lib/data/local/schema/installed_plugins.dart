import 'package:drift/drift.dart';

@DataClassName('InstalledPluginRow')
class InstalledPlugins extends Table {
  TextColumn get shortName => text()();
  TextColumn get version => text()();
  TextColumn get sha256 => text()();
  TextColumn get filePath => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get installedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {shortName};
}
