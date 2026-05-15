// lib/state/player_engine_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../player/engine.dart';

/// App-lifetime [PlayerEngine] — NOT autoDispose.
///
/// The watch page uses `ref.read` (not watch) when it kicks off playback,
/// so an autoDispose provider would tear down the engine the moment
/// `_start()` finishes — which would dispose media_kit's internal
/// ValueNotifiers while the [Video] widget is still attached, throwing
/// "ValueNotifier was used after being disposed" on close.
///
/// Keeping the engine alive across page navigations also lets us reuse
/// the [VideoController] / texture (see [PlayerEngine.videoController]),
/// which is the recommended pattern for media_kit_video.
final playerEngineProvider = Provider<PlayerEngine>((ref) {
  final engine = PlayerEngine();
  ref.onDispose(engine.dispose);
  return engine;
});
