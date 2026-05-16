// lib/state/playback_prefs_provider.dart
//
// User-facing playback preferences surfaced in the Settings page's
// "Riproduzione" section (Phase H2). Two string knobs persisted via
// SharedPreferences:
//
//   playback.audio_lang     — 'it' (default), 'en', 'ja', 'original',
//                              'off' (any of the languages we render in
//                              the dropdown). 'original' means "don't
//                              override the master's first track"; 'off'
//                              disables audio entirely (effectively
//                              SubtitleTrack.no() for the audio side, used
//                              by accessibility-conscious users).
//   playback.subtitle_lang  — 'off' (default), 'it', 'en', 'same' (= match
//                              the chosen audio track's language).
//
// Defaults are 'it' / 'off' to match the v3 spec § Riproduzione.
//
// The engine integration is deferred to a follow-up (Phase I-ish). For now
// `lib/player/engine.dart` keeps its hardcoded Italian auto-pick logic;
// the prefs are written + displayed correctly here so wiring is a single
// future patch that consults this notifier from PlayController.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Snapshot of the user's playback preferences. Immutable; the notifier
/// emits a new instance on every change.
class PlaybackPrefs {
  const PlaybackPrefs({required this.audioLang, required this.subtitleLang});

  /// Lowercased language code for the user's preferred audio track. The
  /// special values 'original' and 'off' have semantic meaning (see file
  /// header); other values are matched against media_kit's AudioTrack.language.
  final String audioLang;

  /// Lowercased language code for subtitles. 'off' disables subtitles;
  /// 'same' tells the picker to match `audioLang`.
  final String subtitleLang;

  PlaybackPrefs copyWith({String? audioLang, String? subtitleLang}) =>
      PlaybackPrefs(
        audioLang: audioLang ?? this.audioLang,
        subtitleLang: subtitleLang ?? this.subtitleLang,
      );

  @override
  bool operator ==(Object other) =>
      other is PlaybackPrefs &&
      other.audioLang == audioLang &&
      other.subtitleLang == subtitleLang;

  @override
  int get hashCode => Object.hash(audioLang, subtitleLang);
}

/// Internal storage keys. Exposed for tests; do not hardcode elsewhere.
const String kPlaybackAudioLangKey = 'playback.audio_lang';
const String kPlaybackSubtitleLangKey = 'playback.subtitle_lang';

const String kPlaybackAudioLangDefault = 'it';
const String kPlaybackSubtitleLangDefault = 'off';

/// AsyncNotifier so the UI can `.when(...)` on the prefs while the
/// SharedPreferences instance bootstraps. Writes are immediate (no
/// debounce — these are user-driven dropdown changes, not a hot loop).
class PlaybackPrefsNotifier extends AsyncNotifier<PlaybackPrefs> {
  @override
  Future<PlaybackPrefs> build() async {
    final prefs = await SharedPreferences.getInstance();
    return PlaybackPrefs(
      audioLang: prefs.getString(kPlaybackAudioLangKey) ??
          kPlaybackAudioLangDefault,
      subtitleLang: prefs.getString(kPlaybackSubtitleLangKey) ??
          kPlaybackSubtitleLangDefault,
    );
  }

  Future<void> setAudioLang(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPlaybackAudioLangKey, code);
    final current = state.value ?? await future;
    state = AsyncData(current.copyWith(audioLang: code));
  }

  Future<void> setSubtitleLang(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPlaybackSubtitleLangKey, code);
    final current = state.value ?? await future;
    state = AsyncData(current.copyWith(subtitleLang: code));
  }
}

final playbackPrefsProvider =
    AsyncNotifierProvider<PlaybackPrefsNotifier, PlaybackPrefs>(
  PlaybackPrefsNotifier.new,
);
