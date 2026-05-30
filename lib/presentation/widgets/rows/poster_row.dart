// lib/presentation/widgets/rows/poster_row.dart
//
// Horizontal scroll of PosterCard items, with a header row that holds
// the section title and an optional "Vedi tutti →" link to a list page
// (sub-plan 8, Phase D3).
//
// Loading state: when [isLoading] is true and [items] is empty, renders
// six placeholder cards (StreamloadColors.v3SurfaceGlass blocks). Error
// state is the caller's responsibility — HomePage renders an inline
// `Errore di caricamento` so a single row failure doesn't kill the page.
//
// Card widths and padding adapt per breakpoint via Responsive +
// StreamloadSpacing.
//
// 2026-05-17 (CM-2 / CM-7): the Pass 2F.3 per-card stagger entrance was
// dropped (cards just render immediately under the page fade). The
// header's "count chip" was also removed — editorial pages don't carry
// badge counts. "Vedi tutti →" stays as a quiet typographic link.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/media_summary.dart';
import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../poster_card.dart';
import '../shimmer.dart';

class PosterRow extends StatelessWidget {
  const PosterRow({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
    this.seeAllTo,
    this.isLoading = false,
    this.placeholderCount = 6,
    this.progressByTmdbId,
    this.subtitleByTmdbId,
  });

  final String title;
  final List<MediaSummary> items;
  final ValueChanged<MediaSummary>? onItemTap;

  /// Optional GoRouter path the "Vedi tutti →" link navigates to. When
  /// null, the link is hidden.
  final String? seeAllTo;

  /// While loading, render shimmer placeholder cards instead of items.
  final bool isLoading;

  /// How many placeholder cards to render during loading.
  final int placeholderCount;

  /// 0..1 per-item progress. Used by "Continua a guardare" — same 2:3
  /// poster as the other rows, just with a resume hint over the image.
  final Map<int, double>? progressByTmdbId;

  /// Per-item subtitle override. Used by "Continua a guardare" to show
  /// `S1 · E3 · 28 min rimanenti` instead of the bare release year.
  final Map<int, String>? subtitleByTmdbId;

  @override
  Widget build(BuildContext context) {
    final cardWidth = Responsive.isPhone(context)
        ? StreamloadSpacing.posterCardWidthPhone
        : Responsive.isTablet(context)
            ? StreamloadSpacing.posterCardWidthTablet
            : StreamloadSpacing.posterCardWidthDesktop;
    final pagePad = Responsive.isPhone(context)
        ? StreamloadSpacing.pagePaddingPhone
        : Responsive.isTablet(context)
            ? StreamloadSpacing.pagePaddingTablet
            : StreamloadSpacing.pagePaddingDesktop;

    final showPlaceholders = isLoading && items.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: pagePad,
          child: _Header(
            title: title,
            seeAllTo: seeAllTo,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _rowHeight(cardWidth),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // Fluid, free-scroll everywhere (no snap/step) — the old phone
            // PageScrollPhysics made it advance card-by-card.
            physics: const BouncingScrollPhysics(),
            padding: pagePad,
            itemCount: showPlaceholders ? placeholderCount : items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: StreamloadSpacing.cardGap),
            itemBuilder: (context, i) {
              if (showPlaceholders) {
                return _Placeholder(width: cardWidth);
              }
              final m = items[i];
              return PosterCard(
                summary: m,
                width: cardWidth,
                showLabel: false,
                progressFraction: progressByTmdbId?[m.tmdbId],
                subtitleOverride: subtitleByTmdbId?[m.tmdbId],
                onTap: () {
                  if (onItemTap != null) {
                    onItemTap!(m);
                  } else {
                    context.go(
                      '/title/${m.tmdbId}?media_type=${m.mediaType}',
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Covers-only rows: just the 2:3 poster + a little headroom so the desktop
  // hover-scale doesn't clip.
  double _rowHeight(double cardWidth) => cardWidth * 3 / 2 + 10;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    this.seeAllTo,
  });
  final String title;
  final String? seeAllTo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // CM-7: row title bumps to Fraunces non-italic 20 px so the
        // section header reads as editorial heading, not app chrome.
        Text(
          title,
          style: StreamloadTypography.display(
            fontSize: 20,
            italic: false,
          ),
        ),
        const Spacer(),
        if (seeAllTo != null)
          InkWell(
            onTap: () => context.go(seeAllTo!),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'Vedi tutti →',
                style: StreamloadTypography.body(
                  fontSize: 12,
                  color: StreamloadColors.v3TextSecondary,
                ).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    // CM-2 kept the shimmer skeletons — they're tasteful and signal
    // loading without shouting. The Pass 2F per-card stagger was the
    // motion that came off as excessive; the shimmer stays.
    return Shimmer(
      child: SizedBox(
        width: width,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Container(
            decoration: BoxDecoration(
              color: StreamloadColors.v3SurfaceGlass,
              borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
            ),
          ),
        ),
      ),
    );
  }
}
