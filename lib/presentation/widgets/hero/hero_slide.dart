// lib/presentation/widgets/hero/hero_slide.dart
//
// HeroSlide — single full-width hero panel composed of:
//
//   Stack:
//     0. HeroBackdrop (backdrop image + bottom gradient)
//     1. Metadata block (label + title + meta + synopsis) + CTA row
//        anchored bottom-left on desktop/tablet, bottom-center on phone
//
// 2026-05-16 (P1 hotfix): the YouTube trailer reveal was removed per
// operator feedback — heroes now show the static backdrop only (no
// autoplay video, no 🔊 toggle). The [videoId] param is kept for source
// compatibility but is ignored.
//
// HeroSlide is the *home* flavour of a hero panel — it bakes in a
// "▶ Guarda" PlayCta + "＋ La mia lista" glass pill so HeroCarousel can
// hand it pure data + onPlay / onAdd callbacks. The title page uses
// HeroBackdrop directly with its own CTA row (Phase E1) because it
// needs a richer set (Guarda S1 E1 / Riprendi / share / dynamic add).
//
// Responsive:
//   - desktop / tablet : ~480 / 360 px tall, bottom-left ~40% width block
//   - phone            : 65% viewport height, full-width stacked metadata,
//                        CTAs stack vertically below 380px
import 'package:flutter/material.dart';

import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../play_cta.dart';
import 'hero_backdrop.dart';

class HeroSlide extends StatelessWidget {
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
    this.posterUrl,
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

  /// Fallback when [backdropUrl] is null — TMDB poster gets cropped to the
  /// hero frame so the operator never sees a black slab.
  final String? posterUrl;

  /// Kept for source compatibility — the YouTube trailer reveal was
  /// dropped in the P1 hotfix. Ignored by HeroBackdrop now.
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
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            HeroBackdrop(
              backdropUrl: backdropUrl,
              posterUrl: posterUrl,
            ),
            Positioned.fill(
              child: _MetadataBlock(
                title: title,
                synopsis: synopsis,
                metaLine: _metaLine(),
                label: label,
                isPhone: isPhone,
                onPlay: onPlay,
                onAdd: onAdd,
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
    if (year != null) parts.add('$year');
    if (mediaType == 'tv' && episodeCount != null) {
      parts.add('$episodeCount ep');
    } else if (mediaType == 'movie' && runtimeMinutes != null) {
      parts.add('$runtimeMinutes min');
    }
    parts.add(languageCode);
    if (rating != null) {
      parts.add('⭐ ${rating!.toStringAsFixed(1)}');
    }
    return parts.join(' · ');
  }
}

class _MetadataBlock extends StatelessWidget {
  const _MetadataBlock({
    required this.title,
    required this.synopsis,
    required this.metaLine,
    required this.label,
    required this.isPhone,
    required this.onPlay,
    required this.onAdd,
    required this.availableWidth,
  });

  final String title;
  final String? synopsis;
  final String metaLine;
  final String label;
  final bool isPhone;
  final VoidCallback? onPlay;
  final VoidCallback? onAdd;
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
  });

  final double availableWidth;
  final VoidCallback? onPlay;
  final VoidCallback? onAdd;

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

    if (stackVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ctaPlay,
          const SizedBox(height: 8),
          ctaAdd,
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
