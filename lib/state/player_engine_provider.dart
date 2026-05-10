// lib/state/player_engine_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../player/engine.dart';

/// Per-watch-screen [PlayerEngine]. Auto-disposes when the last listener is
/// removed (i.e., when the watch screen is popped), which calls
/// [PlayerEngine.dispose] to release the underlying media_kit [Player].
final playerEngineProvider = Provider.autoDispose<PlayerEngine>((ref) {
  final engine = PlayerEngine();
  ref.onDispose(engine.dispose);
  return engine;
});
