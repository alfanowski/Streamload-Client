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
// "Guarda →" TextCta + "＋ La mia lista" TextCta so HeroCarousel can
// hand it pure data + onPlay / onAdd callbacks. The title page uses
// HeroBackdrop directly with its own CTA row (Phase E1) because it
// needs a richer set (Guarda S1 E1 / Riprendi / La mia lista / share /
// dynamic add).
//
// Responsive:
//   - desktop / tablet : ~480 / 360 px tall, bottom-left ~40% width block
//   - phone            : 65% viewport height, full-width stacked metadata,
//                        CTAs stack vertically below 380px
//
// 2026-05-17 (CM-2): the Pass 2F metadata fade+slide-up StatefulWidget
// was dropped — metadata is just there, statically. The PageView's own
// crossfade handles slide-to-slide transitions; the metadata doesn't
// need to "land" on top of that. CM-4 also swapped the LiquidGlass pill
// for a typographic TextCta cluster.
import 'package:flutter/material.dart';

import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../primitives/cta_button.dart';
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
    this.onOpen,
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

  /// 1-2 line summary. CM-5 drops this from the hero — the synopsis lives
  /// in the title page body. The param stays for source compatibility but
  /// no longer renders.
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

  /// Primary CTA (Guarda →) tap handler.
  final VoidCallback? onPlay;

  /// Secondary CTA (＋ La mia lista) tap handler.
  final VoidCallback? onAdd;

  /// Tapping anywhere on the hero (outside the CTAs) opens the title page,
  /// the way Netflix's billboard does.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: onOpen != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: LayoutBuilder(
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
        ),
      ),
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
    required this.metaLine,
    required this.label,
    required this.isPhone,
    required this.onPlay,
    required this.onAdd,
    required this.availableWidth,
  });

  final String title;
  final String metaLine;
  final String label;
  final bool isPhone;
  final VoidCallback? onPlay;
  final VoidCallback? onAdd;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    // CM-5: title size 56 / 44 / 36 by breakpoint. Tablet branch was
    // implicit before (just "not phone"); we now make it explicit so the
    // hero typography down-scales gracefully on iPad.
    final isTablet = Responsive.isTablet(context);
    final horizontalPad = isPhone ? 16.0 : 64.0;
    final align =
        isPhone ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final titleSize = isPhone
        ? 36.0
        : isTablet
            ? 44.0
            : 56.0;
    // CM-5 bottom inset: title should sit HIGH in the hero (96 desktop /
    // 64 tablet / 32 phone). Editorial framing — the title looks placed
    // on the image, not stuck to the bottom edge. Clamped against the
    // hero height below so a short hero never overflows (spec: no overflow).
    final baseBottomInset = isPhone
        ? 32.0
        : isTablet
            ? 64.0
            : 96.0;
    // Width budget for the text column — keep narrow on desktop so the
    // synopsis stays readable instead of stretching across the whole hero.
    final maxBlockWidth = isPhone
        ? availableWidth - (horizontalPad * 2)
        : (availableWidth * 0.5).clamp(360.0, 760.0);

    final children = <Widget>[
      Text(
        label,
        style: StreamloadTypography.v3LabelMono(
          color: StreamloadColors.accent,
        ),
        textAlign: isPhone ? TextAlign.center : TextAlign.start,
      ),
      const SizedBox(height: 12),
      Text(
        title,
        style: StreamloadTypography.v3DisplayHero().copyWith(fontSize: titleSize),
        textAlign: isPhone ? TextAlign.center : TextAlign.start,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 12),
      Text(
        metaLine,
        style: StreamloadTypography.v3MetaMono().copyWith(fontSize: 12),
        textAlign: isPhone ? TextAlign.center : TextAlign.start,
      ),
      // CM-5 dropped the synopsis from the hero — the full TRAMA lives
      // in the title page body. Keeps the hero terse.
      const SizedBox(height: 24),
      _Ctas(
        availableWidth: availableWidth - (horizontalPad * 2),
        isPhone: isPhone,
        onPlay: onPlay,
        onAdd: onAdd,
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        // Never let the inset push the metadata block past the hero edge:
        // on a short hero the inset shrinks (cap at 15% of hero height).
        final bottomInset = baseBottomInset.clamp(0.0, c.maxHeight * 0.15);
        return Padding(
          padding: EdgeInsets.fromLTRB(horizontalPad, 0, horizontalPad, bottomInset),
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
      },
    );
  }
}

class _Ctas extends StatelessWidget {
  const _Ctas({
    required this.availableWidth,
    required this.isPhone,
    required this.onPlay,
    required this.onAdd,
  });

  final double availableWidth;
  final bool isPhone;
  final VoidCallback? onPlay;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    // Phone: full-width stacked CTAs, centered (matches the approved mock).
    if (isPhone) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CtaButton(label: 'Guarda', leading: '▶', onTap: onPlay, block: true),
          const SizedBox(height: 12),
          CtaButton(
            label: 'La mia lista',
            leading: '＋',
            onTap: onAdd,
            filled: false,
            block: true,
          ),
        ],
      );
    }
    final stackVertical = availableWidth < 380;
    // UI refactor (2026-05-29): the approved "Cinematic Premium" mockup
    // uses a solid cream Play pill + a ghost "La mia lista" pill (Apple
    // TV+ lean), overriding the older CM-4 typographic-only cluster. The
    // rotating hero has no availability lifecycle (that lives on the title
    // page), so these are plain CtaButtons wired to onPlay / onAdd.
    final ctaPlay = CtaButton(
      label: 'Guarda',
      leading: '▶',
      onTap: onPlay,
      filled: true,
    );
    final ctaAdd = CtaButton(
      label: 'La mia lista',
      leading: '＋',
      onTap: onAdd,
      filled: false,
    );

    if (stackVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ctaPlay,
          const SizedBox(height: 12),
          ctaAdd,
        ],
      );
    }
    return Wrap(
      spacing: 32,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ctaPlay,
        ctaAdd,
      ],
    );
  }
}
