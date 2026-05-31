// lib/presentation/widgets/player/player_chrome.dart
//
// The full mobile player UI that sits ON TOP of the media_kit Video texture:
// Apple "liquid glass" controls (blurred translucent panels), tap-to-toggle
// with auto-hide, double-tap ±10s seek, plus the series features —
// Salta sigla, Prossimo episodio, and an Episodi browser. All chrome is
// landscape-only (WatchPage forces it); this widget assumes a wide canvas.
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import '../../../domain/models/episodes_response.dart';
import '../../../domain/models/playback_request.dart';
import '../../../player/engine.dart';
import '../../../state/episodes_provider.dart';
import '../../../state/home_rows_provider.dart' show titleLogoProvider, TmdbKey;
import '../../../state/intro_provider.dart';
import '../../../state/title_provider.dart';
import '../../theme/typography.dart';

const _skipSeconds = 10;

/// Seconds before the end to surface "Prossimo episodio" when the backend
/// has no detected outro marker.
const _fallbackOutroLeadSeconds = 45;

String _fmt(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

class PlayerChrome extends ConsumerStatefulWidget {
  const PlayerChrome({
    super.key,
    required this.engine,
    required this.request,
    required this.onClose,
    required this.onPlayEpisode,
    required this.onZoom,
    required this.zoomed,
  });

  final PlayerEngine engine;
  final PlaybackRequest request;
  final VoidCallback onClose;

  /// Switch to another episode of the same series.
  final void Function(int season, int episode) onPlayEpisode;

  /// Pinch-to-zoom: true = fill screen (BoxFit.cover), false = original
  /// (BoxFit.contain). [zoomed] is the current state.
  final ValueChanged<bool> onZoom;
  final bool zoomed;

  @override
  ConsumerState<PlayerChrome> createState() => _PlayerChromeState();
}

class _PlayerChromeState extends ConsumerState<PlayerChrome>
    with SingleTickerProviderStateMixin {
  bool _visible = true;
  Timer? _hideTimer;

  // Double-tap seek feedback, driven by a smooth animation.
  int _seekDir = 0; // -1 left, +1 right, 0 idle
  late final AnimationController _ripple;

  // Suppress the next-episode card once the user dismisses it for this episode.
  bool _nextEpDismissed = false;
  // Latch so auto-advance fires once per episode.
  bool _autoAdvanced = false;
  StreamSubscription<bool>? _completedSub;

  bool get _isTv => widget.request.mediaType == 'tv';
  int get _season => widget.request.season ?? 1;
  int get _episode => widget.request.episode ?? 1;

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) {
          setState(() => _seekDir = 0);
        }
      });
    _restartHideTimer();
    // Netflix-style auto-advance: when the episode finishes, roll to the next
    // one (if any) unless the user dismissed the prompt.
    _completedSub = widget.engine.completedStream.listen((done) {
      if (!done || _autoAdvanced || _nextEpDismissed) return;
      final next = _nextEpisode();
      if (next == null) return;
      _autoAdvanced = true;
      widget.onPlayEpisode(next.season, next.episode);
    });
  }

  @override
  void didUpdateWidget(covariant PlayerChrome oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The WatchPage/PlayerChrome State persists across episode switches (same
    // route, new request). Reset the per-episode latches so auto-advance and
    // the "Prossimo episodio" card work for EVERY episode, not just the first.
    final o = oldWidget.request, n = widget.request;
    if (o.tmdbId != n.tmdbId ||
        o.season != n.season ||
        o.episode != n.episode) {
      _autoAdvanced = false;
      _nextEpDismissed = false;
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _ripple.dispose();
    _completedSub?.cancel();
    super.dispose();
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && widget.engine.playing) setState(() => _visible = false);
    });
  }

  void _toggleControls() {
    setState(() => _visible = !_visible);
    if (_visible) _restartHideTimer();
  }

  void _poke() {
    // Any control interaction keeps the chrome alive a little longer.
    if (!_visible) setState(() => _visible = true);
    _restartHideTimer();
  }

  void _seekBy(int seconds) {
    final pos = widget.engine.position;
    final dur = widget.engine.duration;
    var target = pos + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (dur > Duration.zero && target > dur) target = dur;
    widget.engine.seek(target);
  }

  void _onDoubleTapSide(int dir) {
    _seekBy(dir * _skipSeconds);
    setState(() => _seekDir = dir);
    _ripple.forward(from: 0);
  }

  Offset _lastTapDown = Offset.zero;
  double _scaleStart = 1;

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    // Neutralise the app's amber accent inside the player: spinners, splashes
    // and selection all read white/translucent here.
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.transparent,
        splashFactory: InkRipple.splashFactory,
        colorScheme: base.colorScheme.copyWith(primary: Colors.white),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Gesture layer: tap toggles chrome, double-tap seeks, pinch zooms ──
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _lastTapDown = d.localPosition,
            onTap: _toggleControls,
            onDoubleTapDown: (d) => _lastTapDown = d.localPosition,
            onDoubleTap: () {
              final width =
                  context.size?.width ?? MediaQuery.sizeOf(context).width;
              _onDoubleTapSide(_lastTapDown.dx < width / 2 ? -1 : 1);
            },
            onScaleStart: (_) => _scaleStart = 1,
            onScaleUpdate: (d) {
              if (d.pointerCount < 2) return;
              final s = d.scale / _scaleStart;
              if (s > 1.15 && !widget.zoomed) {
                widget.onZoom(true);
              } else if (s < 0.88 && widget.zoomed) {
                widget.onZoom(false);
              }
            },
          ),

          // ── Double-tap seek ripple (smooth) ──
          if (_seekDir != 0)
            Positioned.fill(
              child: IgnorePointer(
                child: _SeekRipple(
                  animation: _ripple,
                  forward: _seekDir > 0,
                  seconds: _skipSeconds,
                ),
              ),
            ),

          // ── Buffering spinner, only when controls are HIDDEN. When the
          //    controls are open the spinner lives in the play/pause slot
          //    (see _centerTransport) so we never show two at once.
          if (!_visible)
            StreamBuilder<bool>(
              stream: engine.bufferingStream,
              initialData: engine.buffering,
              builder: (_, snap) {
                final buffering = snap.data ?? false;
                if (!buffering) return const SizedBox.shrink();
                return const Center(
                  child: CupertinoActivityIndicator(
                    radius: 18,
                    color: Colors.white,
                  ),
                );
              },
            ),

          // ── Chrome (top + center + bottom), fades together ──
          IgnorePointer(
            ignoring: !_visible,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: _buildControls(context, engine),
            ),
          ),

          // ── Skip-intro + Next-episode prompts (independent of chrome) ──
          if (_isTv)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              right: 24,
              bottom: _visible ? 110 : 28,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildSeriesPrompt(engine),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── Chrome layers ─────────────────────────

  Widget _buildControls(BuildContext context, PlayerEngine engine) {
    final pad = MediaQuery.of(context).padding;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Scrim — tapping it (empty area, not a button) dissolves the chrome.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _visible = false),
          onDoubleTapDown: (d) => _lastTapDown = d.localPosition,
          onDoubleTap: () {
            final width =
                context.size?.width ?? MediaQuery.sizeOf(context).width;
            _onDoubleTapSide(_lastTapDown.dx < width / 2 ? -1 : 1);
          },
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000),
                  Color(0x22000000),
                  Color(0x99000000),
                ],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
        ),
        // Top bar
        Positioned(
          top: pad.top + 12,
          left: pad.left + 16,
          right: pad.right + 16,
          child: _topBar(engine),
        ),
        // Center transport
        Align(
          alignment: Alignment.center,
          child: _centerTransport(engine),
        ),
        // Bottom bar
        Positioned(
          left: pad.left + 20,
          right: pad.right + 20,
          bottom: pad.bottom + 16,
          child: _bottomBar(context, engine),
        ),
      ],
    );
  }

  Widget _topBar(PlayerEngine engine) {
    return Row(
      children: [
        _GlassIconButton(
          icon: Icons.close_rounded,
          onTap: widget.onClose,
          size: 40,
        ),
        const SizedBox(width: 14),
        Expanded(child: _titleText()),
      ],
    );
  }

  Widget _titleText() {
    final key = TmdbKey(
      tmdbId: widget.request.tmdbId,
      mediaType: widget.request.mediaType,
    );
    // The official TMDB title logo (transparent wordmark) — same as the title
    // screen's hero. Falls back to typeset text only when there's no logo art.
    final logoUrl = ref.watch(titleLogoProvider(key)).valueOrNull;
    final title = ref
        .watch(titleProvider(TitleKey(
          tmdbId: widget.request.tmdbId,
          mediaType: widget.request.mediaType,
        )))
        .maybeWhen(data: (t) => t.title, orElse: () => '');
    final sub = _isTv ? 'S$_season · E$_episode' : null;

    // Fixed-footprint box (full width × 34h) with the logo drawn left-aligned.
    // Keeping the box size constant whether the image is loading or loaded
    // stops the logo from briefly appearing centred and then snapping left.
    final Widget titleVisual = (logoUrl != null && logoUrl.isNotEmpty)
        ? SizedBox(
            height: 34,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: logoUrl,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              fadeInDuration: const Duration(milliseconds: 150),
              errorWidget: (_, __, ___) => Align(
                alignment: Alignment.centerLeft,
                child: _titleFallback(title),
              ),
            ),
          )
        : _titleFallback(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        titleVisual,
        if (sub != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              sub,
              style: StreamloadTypography.v3MetaMono(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _titleFallback(String title) {
    if (title.isEmpty) return const SizedBox.shrink();
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: StreamloadTypography.v3DisplayHero().copyWith(
        fontSize: 22,
        color: Colors.white,
        shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
      ),
    );
  }

  Widget _centerTransport(PlayerEngine engine) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlassIconButton(
          icon: Icons.replay_10_rounded,
          onTap: () {
            _seekBy(-_skipSeconds);
            _poke();
          },
          size: 54,
        ),
        const SizedBox(width: 36),
        // Center slot: a loading spinner while buffering (the play/pause is
        // hidden then), otherwise the play/pause toggle.
        StreamBuilder<bool>(
          stream: engine.bufferingStream,
          initialData: engine.buffering,
          builder: (_, bufSnap) {
            final buffering = bufSnap.data ?? false;
            if (buffering) {
              return const SizedBox(
                width: 78,
                height: 78,
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: 18,
                    color: Colors.white,
                  ),
                ),
              );
            }
            return StreamBuilder<bool>(
              stream: engine.playingStream,
              initialData: engine.playing,
              builder: (_, snap) {
                final playing = snap.data ?? false;
                return _GlassIconButton(
                  icon:
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 78,
                  iconScale: 1.15,
                  onTap: () {
                    playing ? engine.pause() : engine.play();
                    _poke();
                  },
                );
              },
            );
          },
        ),
        const SizedBox(width: 36),
        _GlassIconButton(
          icon: Icons.forward_10_rounded,
          onTap: () {
            _seekBy(_skipSeconds);
            _poke();
          },
          size: 54,
        ),
      ],
    );
  }

  Widget _bottomBar(BuildContext context, PlayerEngine engine) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scrub bar with elapsed / remaining time.
        StreamBuilder<Duration>(
          stream: engine.positionStream,
          initialData: engine.position,
          builder: (_, posSnap) {
            return StreamBuilder<Duration>(
              stream: engine.durationStream,
              initialData: engine.duration,
              builder: (_, durSnap) {
                return StreamBuilder<Duration>(
                  stream: engine.bufferStream,
                  initialData: engine.buffer,
                  builder: (_, bufSnap) {
                    final pos = posSnap.data ?? Duration.zero;
                    final dur = durSnap.data ?? Duration.zero;
                    final buf = bufSnap.data ?? Duration.zero;
                    return Row(
                      children: [
                        Text(_fmt(pos), style: _timeStyle),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ScrubBar(
                            position: pos,
                            duration: dur,
                            buffered: buf,
                            onSeek: (to) {
                              engine.seek(to);
                              _poke();
                            },
                            onInteract: _poke,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          dur > Duration.zero
                              ? '-${_fmt(dur - pos)}'
                              : _fmt(dur),
                          style: _timeStyle,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),
        // Action row: audio/subtitles + (TV) episodes.
        Row(
          children: [
            _GlassPill(
              icon: Icons.subtitles_rounded,
              label: 'Audio e sottotitoli',
              onTap: () {
                _poke();
                _openTracksSheet(context, engine);
              },
            ),
            const Spacer(),
            if (_isTv)
              _GlassPill(
                icon: Icons.video_library_rounded,
                label: 'Episodi',
                onTap: () {
                  _poke();
                  _openEpisodesSheet(context);
                },
              ),
          ],
        ),
      ],
    );
  }

  // ───────────────────────── Series prompts ─────────────────────────

  Widget _buildSeriesPrompt(PlayerEngine engine) {
    // Keep the episodes + marker providers alive and rebuild when they load
    // (the actual lookups use ref.read so they're callback-safe).
    ref.watch(episodesProvider(widget.request.tmdbId));
    final marker = ref
        .watch(introMarkerProvider(
            (tmdbId: widget.request.tmdbId, season: _season)))
        .valueOrNull;

    return StreamBuilder<Duration>(
      stream: engine.positionStream,
      initialData: engine.position,
      builder: (_, posSnap) {
        return StreamBuilder<Duration>(
          stream: engine.durationStream,
          initialData: engine.duration,
          builder: (_, durSnap) {
            final pos = posSnap.data ?? Duration.zero;
            final dur = durSnap.data ?? Duration.zero;

            // 1) Skip intro takes priority while inside the intro window.
            if (marker != null &&
                pos >= marker.introStartD &&
                pos < marker.introEndD) {
              return _GlassPill(
                key: const ValueKey('skip-intro'),
                icon: Icons.fast_forward_rounded,
                label: 'Salta sigla',
                strong: true,
                onTap: () => engine.seek(marker.introEndD),
              );
            }

            // 2) Next episode near the end (outro marker, else last N seconds).
            final next = _nextEpisode();
            if (next != null && !_nextEpDismissed && dur > Duration.zero) {
              final outro = marker?.outroStartD ??
                  (dur - const Duration(seconds: _fallbackOutroLeadSeconds));
              if (pos >= outro) {
                return _NextEpisodeCard(
                  key: const ValueKey('next-ep'),
                  tmdbId: widget.request.tmdbId,
                  next: next,
                  onPlay: () => widget.onPlayEpisode(next.season, next.episode),
                  onDismiss: () => setState(() => _nextEpDismissed = true),
                );
              }
            }
            return const SizedBox.shrink(key: ValueKey('none'));
          },
        );
      },
    );
  }

  /// Compute the episode that follows the current one, or null if this is the
  /// last episode of the last season.
  ({int season, int episode, EpisodeInfo info})? _nextEpisode() {
    if (!_isTv) return null;
    // read (not watch): this is also called from the completedStream listener.
    final resp = ref.read(episodesProvider(widget.request.tmdbId)).valueOrNull;
    if (resp == null) return null;
    final seasons = [...resp.seasons]
      ..sort((a, b) => a.number.compareTo(b.number));
    final si = seasons.indexWhere((s) => s.number == _season);
    if (si < 0) return null;
    final eps = [...seasons[si].episodes]
      ..sort((a, b) => a.episode.compareTo(b.episode));
    final ei = eps.indexWhere((e) => e.episode == _episode);
    if (ei >= 0 && ei + 1 < eps.length) {
      final e = eps[ei + 1];
      return (season: _season, episode: e.episode, info: e);
    }
    // Roll to first episode of the next season.
    if (si + 1 < seasons.length) {
      final ns = seasons[si + 1];
      final nEps = [...ns.episodes]
        ..sort((a, b) => a.episode.compareTo(b.episode));
      if (nEps.isNotEmpty) {
        return (
          season: ns.number,
          episode: nEps.first.episode,
          info: nEps.first
        );
      }
    }
    return null;
  }

  // ───────────────────────── Sheets ─────────────────────────

  void _openTracksSheet(BuildContext context, PlayerEngine engine) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _TracksSheet(engine: engine),
    );
  }

  void _openEpisodesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) => _EpisodesSheet(
        tmdbId: widget.request.tmdbId,
        currentSeason: _season,
        currentEpisode: _episode,
        onPlay: (s, e) {
          Navigator.of(context).pop();
          widget.onPlayEpisode(s, e);
        },
      ),
    );
  }
}

const _timeStyle = TextStyle(
  color: Colors.white,
  fontSize: 12.5,
  fontWeight: FontWeight.w500,
  fontFeatures: [FontFeature.tabularFigures()],
);

// ──────────────────────────────────────────────────────────────────────────
// Liquid-glass building blocks
// ──────────────────────────────────────────────────────────────────────────

/// A translucent rounded surface. Deliberately NO BackdropFilter: a real-time
/// blur is a separate, expensive render layer that re-rasterises every frame
/// of the fade — that was the "late blur" + stutter. A plain dark-translucent
/// fill is effectively free and stays buttery during opacity animations.
class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.radius = 18,
    this.strong = false,
  });
  final Widget child;
  final double radius;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: strong ? 0.58 : 0.42),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 0.8,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.size = 48,
    this.iconScale = 1,
  });
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      radius: size / 2,
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child:
                Icon(icon, color: Colors.white, size: size * 0.5 * iconScale),
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.strong = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      radius: 24,
      strong: strong,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 19),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Netflix-style double-tap feedback: a soft radial wash on the tapped half
/// that blooms and fades, with an icon + "±10s" that pops and settles.
class _SeekRipple extends StatelessWidget {
  const _SeekRipple({
    required this.animation,
    required this.forward,
    required this.seconds,
  });
  final Animation<double> animation;
  final bool forward;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value; // 0 → 1
        // No background wash — just the icon + label that pops and fades.
        final iconOpacity = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3);
        final iconScale =
            0.7 + 0.3 * Curves.easeOutBack.transform(t.clamp(0, 1));
        return Align(
          alignment: forward ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Opacity(
              opacity: iconOpacity.clamp(0, 1).toDouble(),
              child: Transform.scale(
                scale: iconScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      forward
                          ? Icons.forward_10_rounded
                          : Icons.replay_10_rounded,
                      color: Colors.white,
                      size: 44,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 12)
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${forward ? '+' : '−'}$seconds s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 12)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Custom scrub bar — background / buffered / progress + draggable thumb.
// ──────────────────────────────────────────────────────────────────────────

class _ScrubBar extends StatefulWidget {
  const _ScrubBar({
    required this.position,
    required this.duration,
    required this.buffered,
    required this.onSeek,
    required this.onInteract,
  });
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onInteract;

  @override
  State<_ScrubBar> createState() => _ScrubBarState();
}

class _ScrubBarState extends State<_ScrubBar> {
  double? _dragFraction;

  double get _posFraction {
    if (_dragFraction != null) return _dragFraction!;
    final ms = widget.duration.inMilliseconds;
    if (ms <= 0) return 0;
    return (widget.position.inMilliseconds / ms).clamp(0.0, 1.0);
  }

  double get _bufFraction {
    final ms = widget.duration.inMilliseconds;
    if (ms <= 0) return 0;
    return (widget.buffered.inMilliseconds / ms).clamp(0.0, 1.0);
  }

  void _seekToFraction(double f) {
    final ms = widget.duration.inMilliseconds;
    if (ms <= 0) return;
    widget.onSeek(Duration(milliseconds: (f.clamp(0.0, 1.0) * ms).round()));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) {
            widget.onInteract();
            _seekToFraction(d.localPosition.dx / w);
          },
          onHorizontalDragStart: (d) {
            widget.onInteract();
            setState(
                () => _dragFraction = (d.localPosition.dx / w).clamp(0.0, 1.0));
          },
          onHorizontalDragUpdate: (d) {
            widget.onInteract();
            setState(
                () => _dragFraction = (d.localPosition.dx / w).clamp(0.0, 1.0));
          },
          onHorizontalDragEnd: (_) {
            final f = _dragFraction;
            if (f != null) _seekToFraction(f);
            setState(() => _dragFraction = null);
          },
          child: SizedBox(
            height: 26,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Background track
                _bar(w, 1, Colors.white.withValues(alpha: 0.22)),
                // Buffered
                _bar(w, _bufFraction, Colors.white.withValues(alpha: 0.4)),
                // Progress
                _bar(w, _posFraction, Colors.white),
                // Thumb
                Positioned(
                  left: (w * _posFraction - 7).clamp(0.0, w - 14),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black38, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bar(double maxW, double frac, Color color) {
    return Container(
      width: (maxW * frac).clamp(0.0, maxW),
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Next-episode card (end credits)
// ──────────────────────────────────────────────────────────────────────────

class _NextEpisodeCard extends StatelessWidget {
  const _NextEpisodeCard({
    super.key,
    required this.tmdbId,
    required this.next,
    required this.onPlay,
    required this.onDismiss,
  });
  final int tmdbId;
  final ({int season, int episode, EpisodeInfo info}) next;
  final VoidCallback onPlay;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final e = next.info;
    return _GlassPanel(
      radius: 18,
      strong: true,
      child: SizedBox(
        width: 320,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Prossimo episodio',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 96,
                      height: 54,
                      color: Colors.white.withValues(alpha: 0.1),
                      child: _Still(url: e.stillUrl),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'S${next.season} · E${next.episode}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          e.title ?? 'Episodio ${next.episode}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: onDismiss,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 9),
                          child: Center(
                            child: Text('Chiudi',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: onPlay,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 9),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_arrow_rounded,
                                      color: Colors.black, size: 18),
                                  SizedBox(width: 4),
                                  Text('Riproduci',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Audio + subtitle sheet
// ──────────────────────────────────────────────────────────────────────────

class _TracksSheet extends StatelessWidget {
  const _TracksSheet({required this.engine});
  final PlayerEngine engine;

  @override
  Widget build(BuildContext context) {
    return _GlassSheet(
      child: StreamBuilder<Tracks>(
        stream: engine.tracksStream,
        initialData: engine.tracks,
        builder: (_, tracksSnap) {
          final tracks = tracksSnap.data ?? engine.tracks;
          return StreamBuilder<Track>(
            stream: engine.trackStream,
            initialData: engine.track,
            builder: (_, trackSnap) {
              final active = trackSnap.data ?? engine.track;
              final audio = tracks.audio
                  .where((t) => t.id != 'auto' && t.id != 'no')
                  .toList();
              final subs = tracks.subtitle
                  .where((t) => t.id != 'no' && t.id != 'auto')
                  .toList();
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  const _SheetTitle('Audio'),
                  for (final (i, t) in audio.indexed)
                    _TrackTile(
                      label: _trackLabel(t.language, t.title, i),
                      selected: t.id == active.audio.id,
                      onTap: () {
                        engine.setAudioTrack(t);
                        Navigator.of(context).pop();
                      },
                    ),
                  const SizedBox(height: 16),
                  const _SheetTitle('Sottotitoli'),
                  _TrackTile(
                    label: 'Disattivati',
                    selected: active.subtitle.id == 'no',
                    onTap: () {
                      engine.setSubtitleTrack(SubtitleTrack.no());
                      Navigator.of(context).pop();
                    },
                  ),
                  for (final (i, t) in subs.indexed)
                    _TrackTile(
                      label: _trackLabel(t.language, t.title, i),
                      selected: t.id == active.subtitle.id,
                      onTap: () {
                        engine.setSubtitleTrack(t);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Human-readable label: a mapped language name when we can ("Italiano"),
  /// else the embedded title, else a clean sequential "Traccia N" — never the
  /// raw mpv id (which produced the confusing "traccia no / 1 / 2").
  static String _trackLabel(String? language, String? title, int index) {
    final lang = _languageDisplay((language ?? '').toLowerCase());
    final t = (title ?? '').trim();
    if (lang != null) {
      return (t.isNotEmpty && !lang.toLowerCase().contains(t.toLowerCase()))
          ? '$lang · $t'
          : lang;
    }
    if (t.isNotEmpty) return t;
    return 'Traccia ${index + 1}';
  }
}

/// ISO-639 → Italian display name. mpv reports codes like "ita"/"eng"/"jpn".
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
    default:
      return null;
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Episodes sheet
// ──────────────────────────────────────────────────────────────────────────

class _EpisodesSheet extends ConsumerStatefulWidget {
  const _EpisodesSheet({
    required this.tmdbId,
    required this.currentSeason,
    required this.currentEpisode,
    required this.onPlay,
  });
  final int tmdbId;
  final int currentSeason;
  final int currentEpisode;
  final void Function(int season, int episode) onPlay;

  @override
  ConsumerState<_EpisodesSheet> createState() => _EpisodesSheetState();
}

class _EpisodesSheetState extends ConsumerState<_EpisodesSheet> {
  late int _selectedSeason = widget.currentSeason;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(episodesProvider(widget.tmdbId));
    return _GlassSheet(
      heightFactor: 0.8,
      child: async.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        error: (_, __) => const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text('Impossibile caricare gli episodi',
                style: TextStyle(color: Colors.white70)),
          ),
        ),
        data: (resp) {
          final seasons = [...resp.seasons]
            ..sort((a, b) => a.number.compareTo(b.number));
          if (seasons.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text('Nessun episodio',
                    style: TextStyle(color: Colors.white70)),
              ),
            );
          }
          final season = seasons.firstWhere(
            (s) => s.number == _selectedSeason,
            orElse: () => seasons.first,
          );
          final eps = [...season.episodes]
            ..sort((a, b) => a.episode.compareTo(b.episode));
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Episodi',
                      style: StreamloadTypography.display(
                              fontSize: 22, italic: true)
                          .copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Season selector
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: seasons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final s = seasons[i];
                    final sel = s.number == _selectedSeason;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSeason = s.number),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: sel
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          'Stagione ${s.number}',
                          style: TextStyle(
                            color: sel ? Colors.black : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: eps.length,
                  itemBuilder: (_, i) {
                    final e = eps[i];
                    final isCurrent = season.number == widget.currentSeason &&
                        e.episode == widget.currentEpisode;
                    return _EpisodeRow(
                      episode: e,
                      isCurrent: isCurrent,
                      onTap: () => widget.onPlay(season.number, e.episode),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({
    required this.episode,
    required this.isCurrent,
    required this.onTap,
  });
  final EpisodeInfo episode;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 104,
                  height: 58,
                  color: Colors.white.withValues(alpha: 0.1),
                  child: _Still(url: episode.stillUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${episode.episode}.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            episode.title ?? 'Episodio ${episode.episode}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight:
                                  isCurrent ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (episode.runtimeMinutes != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${episode.runtimeMinutes} min',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (isCurrent)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.equalizer_rounded,
                                color: Colors.white, size: 16),
                          ),
                      ],
                    ),
                    if ((episode.overview ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        episode.overview!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Shared sheet shell + small bits
// ──────────────────────────────────────────────────────────────────────────

class _GlassSheet extends StatelessWidget {
  const _GlassSheet({required this.child, this.heightFactor});
  final Widget child;
  final double? heightFactor;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height *
        (heightFactor ?? 0.0); // 0 → wrap content
    // Tapping the empty area ABOVE the panel closes the sheet. With
    // isScrollControlled the sheet owns the full height, so that region isn't
    // the modal barrier — this outer detector restores "tap outside to close".
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).maybePop(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {}, // absorb taps on the panel itself
          child: Container(
            constraints: heightFactor != null
                ? BoxConstraints(maxHeight: maxH)
                : const BoxConstraints(),
            decoration: BoxDecoration(
              // Near-opaque dark fill — no BackdropFilter (kept the player light).
              color: const Color(0xF21A1A1C),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
                width: 0.8,
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Flexible(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Episode still / thumbnail — cached, with a quiet placeholder while loading
/// and a film-frame fallback so a missing or slow image never shows a blank
/// (or a hard network error) box.
class _Still extends StatelessWidget {
  const _Still({required this.url});
  final String? url;

  static const _fallback = Center(
    child: Icon(Icons.movie_outlined, color: Colors.white38, size: 22),
  );

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _fallback;
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (_, __) => const ColoredBox(color: Color(0x14FFFFFF)),
      errorWidget: (_, __, ___) => _fallback,
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4, top: 4),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      );
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_rounded : null,
                color: Colors.white,
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
