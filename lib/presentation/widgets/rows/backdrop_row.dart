// lib/presentation/widgets/rows/backdrop_row.dart
//
// Horizontal scroll of BackdropCard items (16:9). Used by the
// "Continua a guardare" and "Visti di recente" rows on Home (sub-plan 8,
// Phase D4). Mirrors PosterRow's header / layout but with a different
// card aspect ratio and an optional per-item progress fraction.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../cards/backdrop_card.dart';

/// Plain data carrier per card. Kept here (rather than reusing
/// ContinueWatchingItem) so the row stays decoupled from the source —
/// HomePage maps watch_progress / favorites into this shape.
class BackdropRowItem {
  const BackdropRowItem({
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.progressFraction,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? imageUrl;

  /// 0..1 progress overlay on the card; null hides the bar.
  final double? progressFraction;

  final VoidCallback? onTap;
}

class BackdropRow extends StatelessWidget {
  const BackdropRow({
    super.key,
    required this.title,
    required this.items,
    this.seeAllTo,
    this.isLoading = false,
    this.placeholderCount = 4,
  });

  final String title;
  final List<BackdropRowItem> items;
  final String? seeAllTo;
  final bool isLoading;
  final int placeholderCount;

  @override
  Widget build(BuildContext context) {
    final cardWidth = Responsive.isPhone(context)
        ? StreamloadSpacing.backdropCardWidthPhone
        : Responsive.isTablet(context)
            ? StreamloadSpacing.backdropCardWidthTablet
            : StreamloadSpacing.backdropCardWidthDesktop;
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
              return BackdropCard(
                title: m.title,
                subtitle: m.subtitle,
                imageUrl: m.imageUrl,
                progressFraction: m.progressFraction,
                onTap: m.onTap,
                width: cardWidth,
              );
            },
          ),
        ),
      ],
    );
  }

  // 16:9 image + ~36px reserved for title + subtitle.
  double _rowHeight(double cardWidth) => cardWidth * 9 / 16 + 44;
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: StreamloadColors.v3SurfaceGlass,
              borderRadius: BorderRadius.circular(StreamloadSpacing.chipRadius),
              border: Border.all(color: StreamloadColors.v3BorderGlass),
            ),
            child: Text(
              countChipText!,
              style: StreamloadTypography.v3MetaMono(),
            ),
          ),
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

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 9 / 16;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: StreamloadColors.v3SurfaceGlass,
              borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
            ),
          ),
          const SizedBox(height: 6),
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

