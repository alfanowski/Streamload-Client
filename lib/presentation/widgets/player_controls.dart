// lib/presentation/widgets/player_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          // Play/pause
          StreamBuilder<bool>(
            stream: engine.playingStream,
            builder: (_, snap) {
              final playing = snap.data ?? false;
              return IconButton(
                iconSize: 40,
                color: Colors.white,
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                onPressed: () => playing ? engine.pause() : engine.play(),
              );
            },
          ),
        ],
      ),
    );
  }
}
