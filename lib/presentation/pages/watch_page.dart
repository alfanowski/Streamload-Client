// lib/presentation/pages/watch_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../domain/models/playback_request.dart';
import '../../infra/logger.dart';
import '../../player/engine.dart';
import '../../state/api_client_provider.dart';
import '../../state/play_controller_provider.dart';
import '../../state/player_engine_provider.dart';
import '../../state/progress_tracker.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/player_controls.dart';

final _log = Logger('watch');

/// Typedef that lets tests inject a no-op widget instead of the real
/// media_kit [Video], which throws in headless test environments.
/// Receives the engine so the default builder can construct/access the
/// shared [VideoController] without forcing tests to mock it.
typedef VideoBuilder = Widget Function(PlayerEngine engine);

Widget _defaultVideoBuilder(PlayerEngine e) => SizedBox.expand(
      // Force the Video widget to use ALL available space. media_kit_video's
      // Video has its own internal LayoutBuilder that occasionally measures
      // to 0x0 inside a Stack — wrapping with SizedBox.expand pins it to
      // the parent's constraints.
      child: Video(
        controller: e.videoController,
        // Disable built-in controls — we render our own PlayerControls below,
        // otherwise both render and the user sees two scrub bars + two
        // play/pause buttons stacked.
        controls: NoVideoControls,
        fit: BoxFit.contain,
      ),
    );

class WatchPage extends ConsumerStatefulWidget {
  const WatchPage({
    super.key,
    required this.request,
    this.videoBuilder = _defaultVideoBuilder,
  });

  final PlaybackRequest request;
  final VideoBuilder videoBuilder;

  @override
  ConsumerState<WatchPage> createState() => _WatchPageState();
}

enum _Phase { loading, playing, error }

class _WatchPageState extends ConsumerState<WatchPage> {
  _Phase _phase = _Phase.loading;
  String? _error;
  PlayerEngine? _engine;
  ProgressTracker? _tracker;
  final _engineSubs = <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    try {
      final controller = await ref.read(playControllerProvider.future);
      final url =
          widget.request.season != null && widget.request.episode != null
              ? await controller.startEpisode(
                  tmdbId: widget.request.tmdbId,
                  season: widget.request.season!,
                  episode: widget.request.episode!,
                )
              : await controller.startMovie(tmdbId: widget.request.tmdbId);
      // The engine is now a process-level singleton (see player_engine_provider).
      // Pull it once; it survives across watch sessions and so does its
      // VideoController + texture.
      final engine = ref.read(playerEngineProvider);
      _engine = engine;

      // Wire diagnostic listeners BEFORE open() so we don't miss early
      // errors/logs. Any unrecoverable error surfaces in the UI instead
      // of leaving the user staring at a black screen.
      _engineSubs.add(engine.errorStream.listen((msg) {
        _log.error('media_kit error: $msg');
        if (mounted) {
          setState(() {
            _phase = _Phase.error;
            _error = 'Errore di riproduzione: $msg';
          });
        }
      }));
      _engineSubs.add(engine.logStream.listen((msg) => _log.info('media_kit $msg')));
      _engineSubs.add(engine.widthStream.listen((w) => _log.info('media_kit video width → $w')));
      _engineSubs.add(engine.heightStream.listen((h) => _log.info('media_kit video height → $h')));

      engine.open(url, headers: const {});
      await engine.play();
      final progressApi = await ref.read(progressApiProvider.future);
      _tracker = ProgressTracker(
        api: progressApi,
        tmdbId: widget.request.tmdbId,
        mediaType: widget.request.mediaType,
        seasonNumber: widget.request.season,
        episodeNumber: widget.request.episode,
        positionStream: engine.positionStream,
        durationStream: engine.durationStream,
      )..start();
      if (mounted) setState(() => _phase = _Phase.playing);
    } catch (e) {
      if (mounted) {
        setState(() {
          _phase = _Phase.error;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    for (final s in _engineSubs) {
      unawaited(s.cancel());
    }
    _tracker?.stop();
    if (_engine != null) unawaited(_engine!.pause());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          // Default StackFit.loose left the Video widget with zero constraints
          // — media_kit then created a 0x0 texture and never started decoding
          // (look for `VideoOutput.Resize {width: 0, height: 0}` in the logs).
          // Expand makes non-positioned children fill the Stack.
          fit: StackFit.expand,
          children: [
            switch (_phase) {
              _Phase.loading =>
                const Center(child: CircularProgressIndicator()),
              _Phase.error => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error ?? 'Errore sconosciuto',
                      textAlign: TextAlign.center,
                      style: StreamloadTypography.body(
                        fontSize: 14,
                        color: StreamloadColors.critical,
                      ),
                    ),
                  ),
                ),
              _Phase.playing => widget.videoBuilder(_engine!),
            },
            // Always-visible top bar with close.
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                // go_router uses .go (not .push), so the navigation stack
                // is flat and there's nothing to pop. Send back to /home.
                onPressed: () => context.go('/home'),
                tooltip: 'Chiudi',
              ),
            ),
            // Bottom controls overlay only when playing.
            if (_phase == _Phase.playing)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PlayerControls(),
              ),
          ],
        ),
      ),
    );
  }
}
