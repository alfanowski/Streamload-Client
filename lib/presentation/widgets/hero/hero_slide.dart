// lib/presentation/widgets/hero/hero_slide.dart
//
// HeroSlide — single full-width hero panel composed of:
//
//   Stack:
//     0. CachedNetworkImage (backdrop) — always at the bottom
//     1. HeroTrailer (animated opacity 0→1) — fades in 2s after init
//        when videoId != null; sits ON TOP of the backdrop so it
//        replaces the static image with motion
//     2. Gradient overlay (transparent → black 0.8) — bottom 70% for
//        text readability over both backdrop and trailer
//     3. Metadata block (label + title + meta + synopsis) + CTA row
//        anchored bottom-left on desktop/tablet, bottom-center on phone
//
// The 🔊 toggle keeps a private bool, calls HeroTrailerState.setMuted via
// a GlobalKey to push the change into the iframe. Parent (HeroCarousel)
// owns play/add intents and pause-on-hover.
//
// Responsive:
//   - desktop / tablet : ~480 / 360 px tall, bottom-left ~40% width block
//   - phone            : 65% viewport height, full-width stacked metadata,
//                        CTAs stack vertically below 380px
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/motion.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../play_cta.dart';
import 'hero_trailer.dart';

class HeroSlide extends StatefulWidget {
  const HeroSlide({
    super.key,
    required this.title,
    required this.mediaType,
    this.year,
    this.runtimeMinutes,
    this.episodeCount,
    this.rating,
    this.synopsis,
    this.backdropUrl,
    this.videoId,
    this.label = 'IN EVIDENZA',
    this.languageCode = 'IT',
    this.onPlay,
    this.onAdd,
  });

  /// Display title (Italian where TMDB has it).
  final String title;

  /// ``"movie"`` or ``"tv"`` — drives whether we show runtime or ep count.
  final String mediaType;

  final int? year;
  final int? runtimeMinutes;
  final int? episodeCount;

  /// TMDB rating (0..10). Shown as "⭐ 7.8".
  final double? rating;

  /// 1-2 line summary. Ellipsised on phone to 1 line.
  final String? synopsis;

  /// TMDB backdrop URL (w1280 is fine; the hero stretches anyway).
  final String? backdropUrl;

  /// YouTube video id of the trailer to autoplay over the backdrop.
  /// When null, the static backdrop alone is shown — no trailer reveal.
  final String? videoId;

  /// Eyebrow label above the title. Defaults to "IN EVIDENZA". Carousel
  /// can override with "IN EVIDENZA · 2 DI 5" style.
  final String label;

  /// Locale chip shown in the meta line. Defaults to "IT".
  final String languageCode;

  /// Primary CTA (▶ Guarda) tap handler.
  final VoidCallback? onPlay;

  /// Secondary CTA (＋ La mia lista) tap handler.
  final VoidCallback? onAdd;

  @override
  State<HeroSlide> createState() => _HeroSlideState();
}

class _HeroSlideState extends State<HeroSlide> {
  final GlobalKey<HeroTrailerState> _trailerKey = GlobalKey<HeroTrailerState>();
  Timer? _revealTimer;
  bool _trailerVisible = false;
  bool _muted = true;

  @override
  void initState() {
    super.initState();
    _scheduleTrailerReveal();
  }

  @override
  void didUpdateWidget(covariant HeroSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      // Carousel swapped the underlying title — reset reveal.
      _revealTimer?.cancel();
      _trailerVisible = false;
      _scheduleTrailerReveal();
    }
  }

  void _scheduleTrailerReveal() {
    if (widget.videoId == null) return;
    _revealTimer = Timer(StreamloadMotion.trailerRevealDelay, () {
      if (!mounted) return;
      setState(() => _trailerVisible = true);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _trailerKey.currentState?.setMuted(_muted);
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 0. Backdrop image
            _Backdrop(url: widget.backdropUrl),
            // 1. Trailer (fades in over backdrop after delay)
            if (widget.videoId != null)
              AnimatedOpacity(
                duration: StreamloadMotion.heroCrossfade,
                curve: StreamloadMotion.heroCrossfadeCurve,
                opacity: _trailerVisible ? 1.0 : 0.0,
                child: HeroTrailer(
                  key: _trailerKey,
                  videoId: widget.videoId!,
                  muted: _muted,
                ),
              ),
            // 2. Dark gradient — sits above trailer so text is readable
            const _BottomGradient(),
            // 3. Metadata + CTAs
            Positioned.fill(
              child: _MetadataBlock(
                title: widget.title,
                synopsis: widget.synopsis,
                metaLine: _metaLine(),
                label: widget.label,
                isPhone: isPhone,
                muted: _muted,
                onPlay: widget.onPlay,
                onAdd: widget.onAdd,
                onToggleMute: widget.videoId != null ? _toggleMute : null,
                availableWidth: constraints.maxWidth,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build the "2025 · 8 ep · IT · ⭐ 7.8" mono meta line.
  String _metaLine() {
    final parts = <String>[];
    if (widget.year != null) parts.add('${widget.year}');
    if (widget.mediaType == 'tv' && widget.episodeCount != null) {
      parts.add('${widget.episodeCount} ep');
    } else if (widget.mediaType == 'movie' && widget.runtimeMinutes != null) {
      parts.add('${widget.runtimeMinutes} min');
    }
    parts.add(widget.languageCode);
    if (widget.rating != null) {
      parts.add('⭐ ${widget.rating!.toStringAsFixed(1)}');
    }
    return parts.join(' · ');
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(color: StreamloadColors.v3BgBase);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: StreamloadColors.v3BgBase),
      errorWidget: (_, __, ___) =>
          Container(color: StreamloadColors.v3BgBase),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3, 1.0],
            colors: [
              Colors.transparent,
              Colors.transparent,
              const Color(0xFF000000).withValues(alpha: 0.8),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetadataBlock extends StatelessWidget {
  const _MetadataBlock({
    required this.title,
    required this.synopsis,
    required this.metaLine,
    required this.label,
    required this.isPhone,
    required this.muted,
    required this.onPlay,
    required this.onAdd,
    required this.onToggleMute,
    required this.availableWidth,
  });

  final String title;
  final String? synopsis;
  final String metaLine;
  final String label;
  final bool isPhone;
  final bool muted;
  final VoidCallback? onPlay;
  final VoidCallback? onAdd;
  final VoidCallback? onToggleMute;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    final horizontalPad = isPhone ? 16.0 : 48.0;
    final align = isPhone ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final titleSize = isPhone ? 28.0 : 36.0;
    // Width budget for the text column — keep narrow on desktop so the
    // synopsis stays readable instead of stretching across the whole hero.
    final maxBlockWidth = isPhone
        ? availableWidth - (horizontalPad * 2)
        : (availableWidth * 0.45).clamp(360.0, 720.0);

    final children = <Widget>[
      Text(
        label,
        style: StreamloadTypography.v3LabelMono(
          color: StreamloadColors.v3TextSecondary,
        ),
        textAlign: isPhone ? TextAlign.center : TextAlign.start,
      ),
      const SizedBox(height: 8),
      Text(
        title,
        style: StreamloadTypography.v3DisplayHero().copyWith(fontSize: titleSize),
        textAlign: isPhone ? TextAlign.center : TextAlign.start,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 8),
      Text(
        metaLine,
        style: StreamloadTypography.v3MetaMono(),
        textAlign: isPhone ? TextAlign.center : TextAlign.start,
      ),
      if (synopsis != null && synopsis!.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(
          synopsis!,
          style: StreamloadTypography.v3Body(
            color: StreamloadColors.v3TextSecondary,
          ),
          maxLines: isPhone ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          textAlign: isPhone ? TextAlign.center : TextAlign.start,
        ),
      ],
      const SizedBox(height: 14),
      _Ctas(
        availableWidth: availableWidth - (horizontalPad * 2),
        onPlay: onPlay,
        onAdd: onAdd,
        muted: muted,
        onToggleMute: onToggleMute,
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        0,
        horizontalPad,
        isPhone ? 24.0 : 40.0,
      ),
      child: Align(
        alignment: isPhone ? Alignment.bottomCenter : Alignment.bottomLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBlockWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: align,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _Ctas extends StatelessWidget {
  const _Ctas({
    required this.availableWidth,
    required this.onPlay,
    required this.onAdd,
    required this.muted,
    required this.onToggleMute,
  });

  final double availableWidth;
  final VoidCallback? onPlay;
  final VoidCallback? onAdd;
  final bool muted;
  final VoidCallback? onToggleMute;

  @override
  Widget build(BuildContext context) {
    final stackVertical = availableWidth < 380;
    final ctaPlay = PlayCta(
      state: PlayCtaState.play,
      label: 'Guarda',
      onTap: onPlay,
    );
    final ctaAdd = _GlassPill(
      label: '＋ La mia lista',
      onTap: onAdd,
    );
    final mute = onToggleMute;
    final ctaMute = mute != null
        ? _GlassCircle(
            icon: muted ? Icons.volume_off : Icons.volume_up,
            tooltip: muted ? 'Riattiva audio' : 'Disattiva audio',
            onTap: mute,
          )
        : null;

    if (stackVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ctaPlay,
          const SizedBox(height: 8),
          ctaAdd,
          if (ctaMute != null) ...[
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: ctaMute),
          ],
        ],
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ctaPlay,
        ctaAdd,
        if (ctaMute != null) ctaMute,
      ],
    );
  }
}

/// Glass-pill secondary CTA — used by "＋ La mia lista".
class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: StreamloadColors.v3CtaSecondaryBg,
        borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
        border: Border.all(color: StreamloadColors.v3BorderGlass),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            child: Text(
              label,
              style: StreamloadTypography.v3CtaLabel(
                color: StreamloadColors.v3TextPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass-circle icon button — used by the 🔊 mute toggle.
class _GlassCircle extends StatelessWidget {
  const _GlassCircle({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: StreamloadColors.v3CtaSecondaryBg,
        shape: CircleBorder(
          side: BorderSide(color: StreamloadColors.v3BorderGlass),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: StreamloadColors.v3TextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
