// lib/presentation/pages/watch_page.dart
import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/player/player_chrome.dart';

final _log = Logger('watch');

/// Typedef that lets tests inject a no-op widget instead of the real
/// media_kit [Video], which throws in headless test environments.
/// Receives the engine so the default builder can construct/access the
/// shared [VideoController] without forcing tests to mock it.
typedef VideoBuilder = Widget Function(PlayerEngine engine);

class WatchPage extends ConsumerStatefulWidget {
  const WatchPage({
    super.key,
    required this.request,
    this.videoBuilder,
    this.debugBypassProxy = false,
  });

  final PlaybackRequest request;

  /// Test seam: inject a no-op widget instead of the real media_kit [Video]
  /// (which throws in headless tests). Null in the app → the real Video with
  /// the pinch-zoom fit is used.
  final VideoBuilder? videoBuilder;

  /// DIAGNOSTIC: when true, skip plugin + proxy + session and feed media_kit
  /// the raw Apple BipBop URL directly. Used to isolate whether playback
  /// problems live in our proxy chain or in media_kit setup itself.
  final bool debugBypassProxy;

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

  /// Pinch-to-zoom: contain (original letterbox) ↔ cover (fill the screen).
  BoxFit _videoFit = BoxFit.contain;

  /// The real media_kit Video, sized to fill and honouring the current fit.
  Widget _buildVideo(PlayerEngine e) => SizedBox.expand(
        // media_kit_video's internal LayoutBuilder occasionally measures to
        // 0x0 inside a Stack — SizedBox.expand pins it to the parent.
        child: Video(
          controller: e.videoController,
          controls: NoVideoControls,
          fit: _videoFit,
        ),
      );

  @override
  void initState() {
    super.initState();
    // The player is the ONLY landscape surface. Force landscape + hide the
    // status/home chrome for an immersive, cinema-style frame. dispose()
    // restores the app-wide portrait lock.
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void didUpdateWidget(covariant WatchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Episode switch (same WatchPage, new season/episode in the route) →
    // tear down the current session and resolve + open the new stream.
    final a = oldWidget.request, b = widget.request;
    if (a.tmdbId != b.tmdbId ||
        a.season != b.season ||
        a.episode != b.episode) {
      _clearSession();
      setState(() {
        _phase = _Phase.loading;
        _error = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
  }

  /// Cancel listeners + progress tracker from the previous playback so a
  /// restart (episode switch) doesn't accumulate duplicate subscriptions.
  void _clearSession() {
    for (final s in _engineSubs) {
      unawaited(s.cancel());
    }
    _engineSubs.clear();
    _tracker?.stop();
    _tracker = null;
  }

  /// Ask the SERVER for the saved position for this exact title/episode. Read
  /// fresh from the backend (not a cached list) so it's exact and the same
  /// record across all the user's devices. Returned as the point to START
  /// playback at — passed to mpv's `start` so it BEGINS there (a post-open
  /// seek is ignored by HLS, which made "Riprendi" restart from 0). Null when
  /// there's nothing meaningful to resume.
  Future<Duration?> _savedResumePosition() async {
    if (widget.debugBypassProxy) return null;
    try {
      final r = widget.request;
      final isTv = r.mediaType == 'tv';
      final api = await ref.read(progressApiProvider.future);
      final saved = await api.resume(
        tmdbId: r.tmdbId,
        mediaType: r.mediaType,
        seasonNumber: isTv ? (r.season ?? 1) : null,
        episodeNumber: isTv ? (r.episode ?? 1) : null,
      );
      if (saved == null) return null;
      final pos = (saved['position_seconds'] as num?)?.toInt() ?? 0;
      final dur = (saved['duration_seconds'] as num?)?.toInt() ?? 0;
      final completed = saved['completed'] == true;
      // Don't resume the very start, or something already watched to the end.
      if (completed || pos < 5) return null;
      if (dur > 0 && pos >= dur - 10) return null;
      return Duration(seconds: pos);
    } catch (_) {
      // Best-effort — a missing/failed lookup just means "start from 0".
      return null;
    }
  }

  static const _debugUrl =
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8';

  Future<void> _start() async {
    try {
      final String url;
      if (widget.debugBypassProxy) {
        _log.info('DEBUG MODE: bypassing proxy, opening Apple BipBop directly');
        url = _debugUrl;
      } else {
        final controller = await ref.read(playControllerProvider.future);
        // Route by mediaType, not by presence of season/episode. A TV-show
        // title page (e.g. /watch/60572?media_type=tv) links here without
        // specifying which episode — default to s1e1 so we still resolve a
        // playable stream rather than falling through to startMovie and
        // matching against the wrong catalog half (Pokemon series tapped →
        // startMovie used to pick "Pokemon Detective Pikachu").
        final isTv = widget.request.mediaType == 'tv';
        if (isTv) {
          url = await controller.startEpisode(
            tmdbId: widget.request.tmdbId,
            season: widget.request.season ?? 1,
            episode: widget.request.episode ?? 1,
          );
        } else {
          url = await controller.startMovie(tmdbId: widget.request.tmdbId);
        }
      }
      // The engine is now a process-level singleton (see player_engine_provider).
      // Pull it once; it survives across watch sessions and so does its
      // VideoController + texture.
      final engine = ref.read(playerEngineProvider);
      _engine = engine;

      // Wire diagnostic listeners BEFORE open() so we don't miss early
      // errors/logs. Any unrecoverable error surfaces in the UI instead
      // of leaving the user staring at a black screen.
      _engineSubs.add(engine.errorStream.listen((msg) {
        if (msg.trim().isEmpty) return;
        // Always log so we see it in the console.
        _log.error('media_kit error: $msg');
        // Don't latch UI to error on benign warnings — media_kit_video at
        // startup tries to set mpv properties like "osc" that don't exist
        // on newer libmpv (warning: 'property not found _setProperty...').
        // Only the patterns below are actual playback failures.
        if (_phase == _Phase.error) return;
        final isFatal = msg.contains('avformat_open_input') ||
            msg.contains('Failed to recognize file format') ||
            msg.contains('Failed to open') ||
            msg.contains('hls: Error when loading') ||
            msg.contains('Refusing to load');
        if (!isFatal) return;
        if (mounted) {
          setState(() {
            _phase = _Phase.error;
            _error = 'Errore di riproduzione: $msg';
          });
        }
      }));
      _engineSubs
          .add(engine.logStream.listen((msg) => _log.info('media_kit $msg')));
      _engineSubs.add(engine.widthStream
          .listen((w) => _log.info('media_kit video width → $w')));
      _engineSubs.add(engine.heightStream
          .listen((h) => _log.info('media_kit video height → $h')));

      // Resume exactly where the user left off (best-effort): mpv starts AT
      // this position rather than seeking after load.
      final resumeAt = await _savedResumePosition();
      engine.open(url, headers: const {}, startAt: resumeAt);
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
    _clearSession();
    if (_engine != null) unawaited(_engine!.pause());
    // Leaving the player: restore the app-wide portrait lock + normal UI.
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // No SafeArea: the video is full-bleed (cinema). PlayerChrome insets its
      // own controls using MediaQuery.padding.
      body: SizedBox.expand(
        child: Stack(
          // Default StackFit.loose left the Video widget with zero constraints
          // — media_kit then created a 0x0 texture and never started decoding
          // (look for `VideoOutput.Resize {width: 0, height: 0}` in the logs).
          // Expand makes non-positioned children fill the Stack.
          fit: StackFit.expand,
          children: [
            switch (_phase) {
              _Phase.loading => const Center(
                  child: CupertinoActivityIndicator(
                    radius: 18,
                    color: Colors.white,
                  ),
                ),
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
              _Phase.playing =>
                widget.videoBuilder?.call(_engine!) ?? _buildVideo(_engine!),
            },
            // The full liquid-glass chrome (controls, gestures, series
            // features) only once we're actually playing.
            if (_phase == _Phase.playing && _engine != null)
              PlayerChrome(
                engine: _engine!,
                request: widget.request,
                onClose: () => context.go('/home'),
                onPlayEpisode: (season, episode) => context.go(
                  '/watch/${widget.request.tmdbId}'
                  '?media_type=tv&season=$season&episode=$episode',
                ),
                zoomed: _videoFit == BoxFit.cover,
                onZoom: (z) => setState(
                  () => _videoFit = z ? BoxFit.cover : BoxFit.contain,
                ),
              )
            else
              // Loading / error states still need a way out.
              Positioned(
                top: 8,
                left: 8,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.go('/home'),
                    tooltip: 'Chiudi',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
