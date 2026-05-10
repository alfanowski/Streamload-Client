// lib/state/database_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';

/// Singleton drift database for the app's lifetime.
/// In tests, override with `databaseProvider.overrideWith((_) => StreamloadDatabase.test(...))`.
final databaseProvider = Provider<StreamloadDatabase>((ref) {
  final db = StreamloadDatabase();
  ref.onDispose(db.close);
  return db;
});
