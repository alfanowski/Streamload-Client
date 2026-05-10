import 'package:drift/drift.dart';

/// Pending mutations not yet pushed to the backend. Drained by a background
/// isolate (sub-plan #6).
@DataClassName('OutboxRow')
class Outbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()();        // e.g. "favorite.add"
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().withDefault(currentDateAndTime)();
}
