// lib/player/engine.dart
import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Thin wrapper around media_kit.Player. ONE instance per app lifetime —
/// the surrounding [playerEngineProvider] is NOT autoDispose, so the same
/// player + texture survives navigation between watch sessions. Watch pages
/// pause on close; the engine itself isn't disposed until app shutdown.
class PlayerEngine {
  PlayerEngine() : _player = Player() {
    _configureMpv();
    _wirePreferredAudio();
  }

  static void ensureInitialized() {
    MediaKit.ensureInitialized();
  }

  /// Apply mpv options that the proxy + plugin pipeline depends on.
  ///
  /// `load-unsafe-playlists=yes`: by default mpv refuses to load HTTP URLs
  /// that appear inside HLS playlists (anti-exploit hardening — a malicious
  /// .m3u8 could reference file:// or arbitrary network targets). Our
  /// proxy IS the source of those URLs and only serves loopback content,
  /// so opting in is correct + required for any real HLS source.
  void _configureMpv() {
    final platform = _player.platform;
    if (platform is! NativePlayer) return;
    // Each setProperty is wrapped because some mpv builds lack the option
    // group ("property not found"). Without try/catch a single missing
    // option crashes the entire isolate when libmpv hits
    // m_config_cache_from_shadow with a stale group_index. Defensive: set
    // every option independently, swallow per-option failures.
    Future<void> safeSet(String key, String value) async {
      try {
        await platform.setProperty(key, value);
      } catch (_) {
        // Property unknown to this libmpv build — fine, we tried.
      }
    }

    // load-unsafe-playlists: required for our HLS proxy to serve loopback
    // URLs inside .m3u8 playlists (libmpv anti-exploit hardening).
    safeSet('load-unsafe-playlists', 'yes');
    // osc=no: explicitly disable mpv's on-screen controller. media_kit_video
    // tries to enable it on macOS, which fails on a video-only mpv build
    // and leaves the config cache in a half-initialized state — the very
    // crash the operator hit on 2026-05-17 (m_config_cache_from_shadow
    // assertion). Setting `no` up-front skips media_kit_video's later
    // attempt and keeps libmpv's option cache stable across hw-accel init.
    safeSet('osc', 'no');
    // Same hardening for the closely-related on-screen-display tag — some
    // mpv builds expose either or both.
    safeSet('osd-bar', 'no');
  }

  /// Languages we treat as "Italian" for auto-selection on track-list
  /// updates. Catalogs use different codes (ita, it, ital, italian).
  ///
  /// TODO(phase-i): replace this hardcoded Italian preference with the
  /// per-user preference exposed by `playbackPrefsProvider`
  /// (lib/state/playback_prefs_provider.dart). The Settings page already
  /// writes the user's choice to SharedPreferences keys
  /// 'playback.audio_lang' / 'playback.subtitle_lang' — wiring them in
  /// here means passing the chosen language through to `open()` (or
  /// reading it from a Ref-aware factory in player_engine_provider.dart).
  static const _italianCodes = {'ita', 'it', 'ital', 'italian'};

  /// True after we've auto-selected Italian for the current playback session.
  /// Reset on every `open()` so each new title gets one chance to auto-pick.
  /// Without the latch the player would yank the user back to Italian every
  /// time mpv re-emits the track list (it fires multiple updates while
  /// resolving HLS variants).
  bool _autoPickedAudio = false;
  bool _autoPickedSubtitle = false;

  StreamSubscription<Tracks>? _autoPickSub;

  void _wirePreferredAudio() {
    _autoPickSub = _player.stream.tracks.listen((tracks) {
      if (!_autoPickedAudio && tracks.audio.length > 1) {
        final ita = _firstItalian<AudioTrack>(
          tracks.audio,
          (t) => t.language,
          (t) => t.title,
        );
        if (ita != null) {
          _autoPickedAudio = true;
          _player.setAudioTrack(ita);
        }
      }
      if (!_autoPickedSubtitle && tracks.subtitle.length > 1) {
        // If we successfully set Italian AUDIO, subtitles default to "no"
        // — most users don't want IT subs over IT audio. If audio is left
        // in a non-Italian language, surface Italian subs instead.
        if (_autoPickedAudio) {
          _autoPickedSubtitle = true;
          _player.setSubtitleTrack(SubtitleTrack.no());
        } else {
          final ita = _firstItalian<SubtitleTrack>(
            tracks.subtitle,
            (t) => t.language,
            (t) => t.title,
          );
          if (ita != null) {
            _autoPickedSubtitle = true;
            _player.setSubtitleTrack(ita);
          }
        }
      }
    });
  }

  static T? _firstItalian<T>(
    List<T> tracks,
    String? Function(T) lang,
    String? Function(T) title,
  ) {
    for (final t in tracks) {
      final l = (lang(t) ?? '').toLowerCase();
      if (_italianCodes.contains(l)) return t;
    }
    for (final t in tracks) {
      final n = (title(t) ?? '').toLowerCase();
      if (n.contains('italian') || n.contains('italiano')) return t;
    }
    return null;
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
  Stream<String> get errorStream => _player.stream.error;
  Stream<int?> get widthStream => _player.stream.width;
  Stream<int?> get heightStream => _player.stream.height;
  Stream<String> get logStream =>
      _player.stream.log.map((e) => '${e.level} ${e.prefix}: ${e.text}');

  /// Available audio + subtitle + video tracks. Mpv emits a new event every
  /// time the track list changes (e.g. when an HLS variant resolves).
  Stream<Tracks> get tracksStream => _player.stream.tracks;

  /// Currently-active audio/subtitle/video track triple.
  Stream<Track> get trackStream => _player.stream.track;

  Tracks get tracks => _player.state.tracks;
  Track get track => _player.state.track;

  Future<void> setAudioTrack(AudioTrack track) =>
      _player.setAudioTrack(track);
  Future<void> setSubtitleTrack(SubtitleTrack track) =>
      _player.setSubtitleTrack(track);

  void open(String uri, {required Map<String, String> headers}) {
    // Reset the auto-pick latches so each new playback gets one shot at
    // selecting Italian audio / subtitles based on the loaded master.
    _autoPickedAudio = false;
    _autoPickedSubtitle = false;
    _player.open(Media(uri, httpHeaders: headers));
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration to) => _player.seek(to);

  void dispose() {
    _autoPickSub?.cancel();
    _player.dispose();
  }
}
