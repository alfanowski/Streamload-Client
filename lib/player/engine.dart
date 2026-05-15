// lib/player/engine.dart
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Thin wrapper around media_kit.Player. ONE instance per app lifetime —
/// the surrounding [playerEngineProvider] is NOT autoDispose, so the same
/// player + texture survives navigation between watch sessions. Watch pages
/// pause on close; the engine itself isn't disposed until app shutdown.
class PlayerEngine {
  PlayerEngine() : _player = Player();

  static void ensureInitialized() {
    MediaKit.ensureInitialized();
  }

  final Player _player;
  VideoController? _videoController;

  Player get player => _player;

  /// Lazily-constructed [VideoController] bound to this engine's player.
  /// Cached so the [Video] widget can stay attached across rebuilds and
  /// page navigations — recreating it on every WatchPage mount is what
  /// triggered the "ValueNotifier was used after being disposed" race.
  VideoController get videoController =>
      _videoController ??= VideoController(_player);

  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<bool> get playingStream => _player.stream.playing;

  void open(String uri, {required Map<String, String> headers}) {
    _player.open(Media(uri, httpHeaders: headers));
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration to) => _player.seek(to);

  void dispose() {
    _player.dispose();
  }
}
