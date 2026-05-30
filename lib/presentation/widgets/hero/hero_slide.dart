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
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:native_liquid_glass/native_liquid_glass.dart';

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
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: onOpen != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: Stack(
          fit: StackFit.expand,
          children: [
            HeroBackdrop(backdropUrl: backdropUrl, posterUrl: posterUrl),
            Positioned.fill(
              child: HeroMetadata(
                text: HeroText(
                  title: title,
                  mediaType: mediaType,
                  year: year,
                  runtimeMinutes: runtimeMinutes,
                  episodeCount: episodeCount,
                  rating: rating,
                  label: label,
                  languageCode: languageCode,
                ),
                ctas: HeroCtas(onPlay: onPlay, onAdd: onAdd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The hero's text + CTA block (eyebrow, title, meta line, Guarda / La mia
/// lista). Public so HeroCarousel can render it on its OWN layer, separate
/// from the backdrop — that lets the backdrop crossfade between slides while
/// a SINGLE set of (native) CTAs fades out and back in, with no flicker from
/// crossfading two platform-view button sets at once.
class HeroMetadata extends StatelessWidget {
  const HeroMetadata({super.key, required this.text, required this.ctas});

  /// Eyebrow + title + meta block (usually a [HeroText], possibly crossfading
  /// between slides in the carousel).
  final Widget text;

  /// The CTA row (usually [HeroCtas]) — kept stable across transitions so the
  /// native glass buttons never animate/flicker.
  final Widget ctas;

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final isTablet = Responsive.isTablet(context);
    final horizontalPad = isPhone ? 16.0 : 64.0;
    final baseBottomInset = isPhone
        ? 32.0
        : isTablet
            ? 64.0
            : 96.0;

    return LayoutBuilder(
      builder: (context, c) {
        final availableWidth = c.maxWidth;
        final maxBlockWidth = isPhone
            ? availableWidth - (horizontalPad * 2)
            : (availableWidth * 0.5).clamp(360.0, 760.0);
        final bottomInset = baseBottomInset.clamp(0.0, c.maxHeight * 0.15);

        return Padding(
          padding:
              EdgeInsets.fromLTRB(horizontalPad, 0, horizontalPad, bottomInset),
          child: Align(
            alignment: isPhone ? Alignment.bottomCenter : Alignment.bottomLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBlockWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    isPhone ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  text,
                  const SizedBox(height: 24),
                  ctas,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Eyebrow + title + meta line. Self-sizing; the carousel crossfades two of
/// these (current + neighbour) so the TITLE always matches the backdrop.
class HeroText extends StatelessWidget {
  const HeroText({
    super.key,
    required this.title,
    required this.mediaType,
    this.year,
    this.runtimeMinutes,
    this.episodeCount,
    this.rating,
    this.label = 'IN EVIDENZA',
    this.languageCode = 'IT',
  });

  final String title;
  final String mediaType;
  final int? year;
  final int? runtimeMinutes;
  final int? episodeCount;
  final double? rating;
  final String label;
  final String languageCode;

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

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final isTablet = Responsive.isTablet(context);
    final titleSize = isPhone
        ? 36.0
        : isTablet
            ? 44.0
            : 56.0;
    final ta = isPhone ? TextAlign.center : TextAlign.start;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isPhone ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StreamloadTypography.v3LabelMono(
            color: StreamloadColors.accent,
          ),
          textAlign: ta,
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style:
              StreamloadTypography.v3DisplayHero().copyWith(fontSize: titleSize),
          textAlign: ta,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Text(
          _metaLine(),
          style: StreamloadTypography.v3MetaMono().copyWith(fontSize: 12),
          textAlign: ta,
        ),
      ],
    );
  }
}

/// Hero CTAs — Guarda (left) + La mia lista (right) on ONE row, equal width,
/// symmetric. Native Apple liquid-glass buttons on iOS; cream/ghost pills as
/// the cross-platform fallback. Kept stable across hero transitions.
class HeroCtas extends StatelessWidget {
  const HeroCtas({super.key, this.onPlay, this.onAdd});

  final VoidCallback? onPlay;
  final VoidCallback? onAdd;

  static bool get _useNativeGlass {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);

    if (isPhone) {
      final Widget guarda = _useNativeGlass
          ? LiquidGlassButton(
              label: 'Guarda',
              icon: const NativeLiquidGlassIcon.sfSymbol('play.fill'),
              onPressed: onPlay ?? () {},
              style: LiquidGlassButtonStyle.glass,
              tint: Colors.white.withValues(alpha: 0.22),
              labelColor: Colors.white,
              iconColor: Colors.white,
            )
          : CtaButton(label: 'Guarda', leading: '▶', onTap: onPlay, block: true);

      final Widget lista = _useNativeGlass
          ? LiquidGlassButton(
              label: 'La mia lista',
              icon: const NativeLiquidGlassIcon.sfSymbol('plus'),
              onPressed: onAdd ?? () {},
              style: LiquidGlassButtonStyle.glass,
              tint: Colors.black.withValues(alpha: 0.22),
              labelColor: Colors.white,
              iconColor: Colors.white,
            )
          : CtaButton(
              label: 'La mia lista',
              leading: '＋',
              onTap: onAdd,
              filled: false,
              block: true,
            );

      // Same row, equal halves, symmetric. Native glass buttons size to
      // their content and ignore Expanded, so we force an explicit equal
      // width (half the row, minus the gap).
      return LayoutBuilder(
        builder: (context, c) {
          // Compact, equal-width buttons clustered near the CENTRE (not
          // stretched to the edges): cap each at ~150 px.
          final w = ((c.maxWidth - 14) / 2).clamp(0.0, 150.0);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: w, child: guarda),
              const SizedBox(width: 14),
              SizedBox(width: w, child: lista),
            ],
          );
        },
      );
    }

    // Desktop / tablet (never iOS): side-by-side pills, intrinsic widths.
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CtaButton(label: 'Guarda', leading: '▶', onTap: onPlay, filled: true),
        CtaButton(label: 'La mia lista', leading: '＋', onTap: onAdd, filled: false),
      ],
    );
  }
}
