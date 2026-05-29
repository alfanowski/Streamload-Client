// lib/presentation/widgets/primitives/content_row.dart
//
// A titled horizontal row of MediaPosterCards. Two robustness guarantees:
//   1. An empty row renders NOTHING (zero-height) — never an orphan header
//      or an empty gap.
//   2. The skeleton constructor reserves the exact row height during load,
//      so there is no jump when data arrives.
import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../view_models/media_card_vm.dart';
import 'media_poster_card.dart';
import 'skeleton_box.dart';

class ContentRow extends StatelessWidget {
  const ContentRow({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
  })  : _skeleton = false,
        placeholderCount = 0;

  const ContentRow.skeleton({
    super.key,
    required this.title,
    this.placeholderCount = 6,
  })  : items = const [],
        onItemTap = null,
        _skeleton = true;

  final String title;
  final List<MediaCardVm> items;
  final void Function(MediaCardVm item)? onItemTap;
  final bool _skeleton;
  final int placeholderCount;

  /// Fixed poster width per breakpoint (Direction A: roomy, fewer per screen).
  static double cardWidthForWidth(double width) {
    if (width < StreamloadTokens.bpPhone) return 116;
    if (width < StreamloadTokens.bpDesktop) return 132;
    return 160;
  }

  @override
  Widget build(BuildContext context) {
    // Robustness rule #4: an empty (non-skeleton) row is not built at all.
    if (!_skeleton && items.isEmpty) {
      return const SizedBox.shrink();
    }

    final cardWidth = cardWidthForWidth(MediaQuery.sizeOf(context).width);
    // poster (2:3) + gap + title line + meta line.
    final rowHeight = cardWidth * 3 / 2 + StreamloadTokens.space2 + 38;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: StreamloadTokens.space3),
          child: Text(
            title,
            style: const TextStyle(
              color: StreamloadTokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: rowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: _skeleton ? placeholderCount : items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: StreamloadTokens.space3),
            itemBuilder: (context, i) {
              if (_skeleton) {
                return SizedBox(
                  width: cardWidth,
                  child: SkeletonBox(
                    key: const Key('row-skeleton-tile'),
                    height: cardWidth * 3 / 2,
                  ),
                );
              }
              final item = items[i];
              return MediaPosterCard(
                item: item,
                width: cardWidth,
                onTap: onItemTap == null ? null : () => onItemTap!(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
