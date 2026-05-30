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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../responsive.dart';
import '../../theme/typography.dart';
import '../primitives/cta_button.dart';
import 'hero_backdrop.dart';
import 'hero_cta_button.dart';

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
    this.titleLogoUrl,
    this.videoId,
    this.languageCode = 'IT',
    this.inList = false,
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

  /// Official TMDB title logo (transparent PNG). When present the hero shows
  /// it instead of the typeset [title]; null → text fallback.
  final String? titleLogoUrl;

  /// Kept for source compatibility — the YouTube trailer reveal was
  /// dropped in the P1 hotfix. Ignored by HeroBackdrop now.
  final String? videoId;

  /// Locale chip shown in the meta line. Defaults to "IT".
  final String languageCode;

  /// Primary CTA (Guarda →) tap handler.
  final VoidCallback? onPlay;

  /// Secondary CTA (＋ La mia lista) tap handler.
  final VoidCallback? onAdd;

  /// Whether this title is already in "La mia lista" (toggles the CTA state).
  final bool inList;

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
                  titleLogoUrl: titleLogoUrl,
                  mediaType: mediaType,
                  year: year,
                  runtimeMinutes: runtimeMinutes,
                  episodeCount: episodeCount,
                  rating: rating,
                  languageCode: languageCode,
                ),
                ctas: HeroCtas(onPlay: onPlay, onAdd: onAdd, inList: inList),
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
        ? 96.0
        : isTablet
            ? 64.0
            : 96.0;

    return LayoutBuilder(
      builder: (context, c) {
        final availableWidth = c.maxWidth;
        final maxBlockWidth = isPhone
            ? availableWidth - (horizontalPad * 2)
            : (availableWidth * 0.5).clamp(360.0, 760.0);
        // Phone: lift the block clear of the fade/first row, but a touch
        // lower than the first pass (the CTAs sat a hair high). The extra
        // title→CTA gap below keeps the TITLE where it was while the buttons
        // drop slightly. Desktop/tablet keep their original ≤15% clamp.
        final bottomInset = isPhone
            ? (c.maxHeight * 0.15).clamp(72.0, 160.0)
            : baseBottomInset.clamp(0.0, c.maxHeight * 0.15);

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
                  // Phone uses a larger gap so lowering the block's bottom
                  // inset drops the CTAs without pulling the title down too.
                  SizedBox(height: isPhone ? 40 : 24),
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

/// Title + meta line. The title is the official TMDB logo (transparent PNG
/// wordmark) when [titleLogoUrl] is set — like Jellyfin — falling back to the
/// app's display font otherwise. Self-sizing; the carousel crossfades two of
/// these (current + neighbour) so the TITLE always matches the backdrop.
class HeroText extends StatelessWidget {
  const HeroText({
    super.key,
    required this.title,
    this.titleLogoUrl,
    required this.mediaType,
    this.year,
    this.runtimeMinutes,
    this.episodeCount,
    this.rating,
    this.languageCode = 'IT',
  });

  final String title;

  /// Official TMDB title logo. When non-null the hero renders this image
  /// instead of [title] as text; on load error it falls back to the text.
  final String? titleLogoUrl;

  final String mediaType;
  final int? year;
  final int? runtimeMinutes;
  final int? episodeCount;
  final double? rating;
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

    final titleText = Text(
      title,
      style: StreamloadTypography.v3DisplayHero().copyWith(fontSize: titleSize),
      textAlign: ta,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    // Logo height budget per breakpoint — roughly matches the text title's
    // optical size so the layout doesn't jump between logo/text titles.
    final logoMaxHeight = isPhone
        ? 76.0
        : isTablet
            ? 96.0
            : 120.0;

    final Widget titleVisual =
        (titleLogoUrl != null && titleLogoUrl!.isNotEmpty)
            ? LayoutBuilder(
                builder: (context, c) {
                  final boxWidth =
                      c.maxWidth.isFinite ? c.maxWidth : double.infinity;
                  return SizedBox(
                    width: boxWidth,
                    height: logoMaxHeight,
                    child: CachedNetworkImage(
                      imageUrl: titleLogoUrl!,
                      fit: BoxFit.contain,
                      alignment: isPhone
                          ? Alignment.bottomCenter
                          : Alignment.bottomLeft,
                      // Show nothing while loading (the backdrop is enough),
                      // and drop to the text title if the logo can't load.
                      placeholder: (_, __) => const SizedBox.shrink(),
                      errorWidget: (_, __, ___) => Align(
                        alignment: isPhone
                            ? Alignment.bottomCenter
                            : Alignment.bottomLeft,
                        child: titleText,
                      ),
                    ),
                  );
                },
              )
            : titleText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isPhone ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        titleVisual,
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
/// symmetric. Phone uses the bespoke [HeroCtaButton] pair (solid cream +
/// translucent glass); desktop/tablet keeps the typographic pills. Kept
/// stable across hero transitions so nothing animates or flickers.
class HeroCtas extends StatelessWidget {
  const HeroCtas({super.key, this.onPlay, this.onAdd, this.inList = false});

  final VoidCallback? onPlay;
  final VoidCallback? onAdd;

  /// Whether the title is already in "La mia lista" — flips the secondary CTA
  /// between ＋ "La mia lista" and ✓ "Nella lista".
  final bool inList;

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final listLabel = inList ? 'Nella lista' : 'La mia lista';
    final listIcon = inList ? Icons.check_rounded : Icons.add_rounded;

    if (isPhone) {
      // Same row, equal halves, clustered near the CENTRE. Each capped so the
      // pair stays compact instead of stretching to the screen edges.
      return LayoutBuilder(
        builder: (context, c) {
          final w = ((c.maxWidth - 10) / 2).clamp(0.0, 152.0);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: w,
                child: HeroCtaButton.primary(
                  label: 'Guarda',
                  icon: Icons.play_arrow_rounded,
                  onTap: onPlay,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: w,
                child: HeroCtaButton.glass(
                  label: listLabel,
                  icon: listIcon,
                  active: inList,
                  onTap: onAdd,
                ),
              ),
            ],
          );
        },
      );
    }

    // Desktop / tablet: side-by-side typographic pills, intrinsic widths.
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CtaButton(label: 'Guarda', leading: '▶', onTap: onPlay, filled: true),
        CtaButton(
          label: listLabel,
          leading: inList ? '✓' : '＋',
          onTap: onAdd,
          filled: false,
        ),
      ],
    );
  }
}
