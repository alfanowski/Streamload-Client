// lib/presentation/widgets/rows/poster_row.dart
//
// Horizontal scroll of PosterCard items, with a header row that holds
// the section title, optional count chip ("12"), and an optional
// "Vedi tutti →" link to a list page (sub-plan 8, Phase D3).
//
// Loading state: when [isLoading] is true and [items] is empty, renders
// six placeholder cards (StreamloadColors.v3SurfaceGlass blocks). Error
// state is the caller's responsibility — HomePage renders an inline
// `Errore di caricamento` so a single row failure doesn't kill the page.
//
// Card widths and padding adapt per breakpoint via Responsive +
// StreamloadSpacing.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/media_summary.dart';
import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../poster_card.dart';

class PosterRow extends StatelessWidget {
  const PosterRow({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
    this.seeAllTo,
    this.isLoading = false,
    this.placeholderCount = 6,
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
            countChipText: items.isNotEmpty ? '${items.length}' : null,
            seeAllTo: seeAllTo,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _rowHeight(cardWidth),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // Phone gets snap-style physics so cards center after a fling.
            physics: Responsive.isPhone(context)
                ? const PageScrollPhysics()
                : const BouncingScrollPhysics(),
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

  // 2:3 aspect ratio poster + ~36px reserved for title + subtitle.
  double _rowHeight(double cardWidth) => cardWidth * 3 / 2 + 44;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    this.countChipText,
    this.seeAllTo,
  });
  final String title;
  final String? countChipText;
  final String? seeAllTo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: StreamloadTypography.v3SectionHeader()),
        if (countChipText != null) ...[
          const SizedBox(width: 8),
          _CountChip(text: countChipText!),
        ],
        const Spacer(),
        if (seeAllTo != null)
          InkWell(
            onTap: () => context.go(seeAllTo!),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'Vedi tutti →',
                style: StreamloadTypography.v3MetaMono(
                  color: StreamloadColors.v3TextSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: StreamloadColors.v3SurfaceGlass,
        borderRadius: BorderRadius.circular(StreamloadSpacing.chipRadius),
        border: Border.all(color: StreamloadColors.v3BorderGlass),
      ),
      child: Text(
        text,
        style: StreamloadTypography.v3MetaMono(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: StreamloadColors.v3SurfaceGlass,
                borderRadius:
                    BorderRadius.circular(StreamloadSpacing.cardRadius),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: width * 0.7,
            height: 12,
            decoration: BoxDecoration(
              color: StreamloadColors.v3SurfaceGlass,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
