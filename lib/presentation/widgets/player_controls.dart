// lib/presentation/widgets/player_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import '../../player/engine.dart';
import '../../state/player_engine_provider.dart';

class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  static String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(playerEngineProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrub bar
          StreamBuilder<Duration>(
            stream: engine.positionStream,
            builder: (_, posSnap) {
              return StreamBuilder<Duration>(
                stream: engine.durationStream,
                builder: (_, durSnap) {
                  final pos = posSnap.data ?? Duration.zero;
                  final dur = durSnap.data ?? Duration.zero;
                  final maxMs = dur.inMilliseconds.clamp(1, 1 << 31);
                  return Row(
                    children: [
                      Text(
                        _fmt(pos),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: pos.inMilliseconds
                              .clamp(0, maxMs)
                              .toDouble(),
                          max: maxMs.toDouble(),
                          onChangeEnd: (v) =>
                              engine.seek(Duration(milliseconds: v.toInt())),
                          onChanged: (_) {},
                        ),
                      ),
                      Text(
                        _fmt(dur),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 4),
          // Transport + track menus
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<bool>(
                stream: engine.playingStream,
                builder: (_, snap) {
                  final playing = snap.data ?? false;
                  return IconButton(
                    iconSize: 40,
                    color: Colors.white,
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    onPressed: () =>
                        playing ? engine.pause() : engine.play(),
                  );
                },
              ),
              const SizedBox(width: 12),
              _TrackMenus(engine: engine),
            ],
          ),
        ],
      ),
    );
  }
}

/// Two popup menus (audio + subtitle) populated from the engine's current
/// track list. Both menus rebuild whenever mpv emits a new tracks event
/// (HLS variant resolution can churn the list multiple times early in
/// playback). Selecting an item is fire-and-forget on the engine.
class _TrackMenus extends StatelessWidget {
  const _TrackMenus({required this.engine});

  final PlayerEngine engine;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Tracks>(
      stream: engine.tracksStream,
      initialData: engine.tracks,
      builder: (_, tracksSnap) {
        final tracks = tracksSnap.data ?? engine.tracks;
        return StreamBuilder<Track>(
          stream: engine.trackStream,
          initialData: engine.track,
          builder: (_, trackSnap) {
            final active = trackSnap.data ?? engine.track;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_realCount(tracks.audio) >= 2)
                  _AudioMenu(
                    engine: engine,
                    audio: tracks.audio,
                    active: active.audio,
                  ),
                if (_realCount(tracks.subtitle) >= 1)
                  _SubtitleMenu(
                    engine: engine,
                    subtitles: tracks.subtitle,
                    active: active.subtitle,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Count tracks excluding the pseudo "auto" / "no" entries mpv injects.
  static int _realCount(List<dynamic> ts) =>
      ts.where((t) => t.id != 'auto' && t.id != 'no').length;
}

class _AudioMenu extends StatelessWidget {
  const _AudioMenu({
    required this.engine,
    required this.audio,
    required this.active,
  });

  final PlayerEngine engine;
  final List<AudioTrack> audio;
  final AudioTrack active;

  @override
  Widget build(BuildContext context) {
    final real = audio.where((t) => t.id != 'auto' && t.id != 'no').toList();
    return PopupMenuButton<AudioTrack>(
      tooltip: 'Audio',
      icon: const Icon(Icons.audiotrack, color: Colors.white),
      color: Colors.black.withValues(alpha: 0.92),
      itemBuilder: (_) => [
        for (final t in real)
          CheckedPopupMenuItem<AudioTrack>(
            value: t,
            checked: t.id == active.id,
            child: Text(
              _audioLabel(t),
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
      onSelected: (t) => engine.setAudioTrack(t),
    );
  }

  static String _audioLabel(AudioTrack t) {
    final lang = (t.language ?? '').toLowerCase();
    final title = (t.title ?? '').trim();
    final base = _languageDisplay(lang) ??
        (title.isNotEmpty ? title : 'Traccia ${t.id}');
    if (title.isNotEmpty && !base.toLowerCase().contains(title.toLowerCase())) {
      return '$base — $title';
    }
    return base;
  }
}

class _SubtitleMenu extends StatelessWidget {
  const _SubtitleMenu({
    required this.engine,
    required this.subtitles,
    required this.active,
  });

  final PlayerEngine engine;
  final List<SubtitleTrack> subtitles;
  final SubtitleTrack active;

  @override
  Widget build(BuildContext context) {
    final real =
        subtitles.where((t) => t.id != 'auto' && t.id != 'no').toList();
    return PopupMenuButton<SubtitleTrack>(
      tooltip: 'Sottotitoli',
      icon: const Icon(Icons.closed_caption, color: Colors.white),
      color: Colors.black.withValues(alpha: 0.92),
      itemBuilder: (_) => [
        CheckedPopupMenuItem<SubtitleTrack>(
          value: SubtitleTrack.no(),
          checked: active.id == 'no',
          child: const Text(
            'Disattivati',
            style: TextStyle(color: Colors.white),
          ),
        ),
        for (final t in real)
          CheckedPopupMenuItem<SubtitleTrack>(
            value: t,
            checked: t.id == active.id,
            child: Text(
              _subtitleLabel(t),
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
      onSelected: (t) => engine.setSubtitleTrack(t),
    );
  }

  static String _subtitleLabel(SubtitleTrack t) {
    final lang = (t.language ?? '').toLowerCase();
    final title = (t.title ?? '').trim();
    final base = _languageDisplay(lang) ??
        (title.isNotEmpty ? title : 'Sottotitoli ${t.id}');
    if (title.isNotEmpty && !base.toLowerCase().contains(title.toLowerCase())) {
      return '$base — $title';
    }
    return base;
  }
}

/// Map common ISO-639 codes to a user-friendly Italian display string. Mpv
/// reports language codes like "ita", "eng", "jpn" — these are unreadable
/// to most users.
String? _languageDisplay(String code) {
  switch (code) {
    case 'ita':
    case 'it':
      return 'Italiano';
    case 'eng':
    case 'en':
      return 'Inglese';
    case 'jpn':
    case 'ja':
      return 'Giapponese';
    case 'spa':
    case 'es':
      return 'Spagnolo';
    case 'fra':
    case 'fre':
    case 'fr':
      return 'Francese';
    case 'deu':
    case 'ger':
    case 'de':
      return 'Tedesco';
    case 'por':
    case 'pt':
      return 'Portoghese';
    case 'rus':
    case 'ru':
      return 'Russo';
    case 'zho':
    case 'chi':
    case 'zh':
      return 'Cinese';
    case 'kor':
    case 'ko':
      return 'Coreano';
    case 'ara':
    case 'ar':
      return 'Arabo';
    case 'des':
      return 'Audiodescrizione';
    default:
      return null;
  }
}
