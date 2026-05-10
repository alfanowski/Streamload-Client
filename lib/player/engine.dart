// lib/player/engine.dart
import 'package:media_kit/media_kit.dart';

/// Thin wrapper around media_kit.Player. Owns one player; dispose drops it.
class PlayerEngine {
  PlayerEngine() : _player = Player();

  static void ensureInitialized() {
    MediaKit.ensureInitialized();
  }

  final Player _player;

  Player get player => _player;

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
