// lib/presentation/widgets/cast/cast_row.dart
//
// Pass 3 CAST-3 — horizontal scroll of CastCards under a "Cast" header.
// Empty list returns const SizedBox.shrink so a missing cast doesn't
// leave a dangling header on the title page.
import 'package:flutter/material.dart';

import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import 'cast_card.dart';

class CastRow extends StatelessWidget {
  const CastRow({
    super.key,
    required this.members,
    this.isLoading = false,
    this.placeholderCount = 8,
  });

  final List<CastCardData> members;

  /// When true and [members] is empty, renders circular skeleton avatars
  /// in place of cards so the row's height stays reserved during the
  /// initial fetch.
  final bool isLoading;

  /// How many placeholder avatars to render during loading.
  final int placeholderCount;

  @override
  Widget build(BuildContext context) {
    final showSkeletons = isLoading && members.isEmpty;
    // Empty AND not loading → row collapses entirely so the title page
    // doesn't carry a header with no content under it.
    if (members.isEmpty && !showSkeletons) {
      return const SizedBox.shrink();
    }

    final pagePad = Responsive.isPhone(context)
        ? StreamloadSpacing.pagePaddingPhone
        : Responsive.isTablet(context)
            ? StreamloadSpacing.pagePaddingTablet
            : StreamloadSpacing.pagePaddingDesktop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: pagePad,
          child: Text('Cast', style: StreamloadTypography.v3SectionHeader()),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: _rowHeight(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: pagePad,
            itemCount: showSkeletons ? placeholderCount : members.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              if (showSkeletons) {
                return _CastSkeleton(radius: _avatarRadius(context));
              }
              return CastCard(data: members[i]);
            },
          ),
        ),
      ],
    );
  }

  double _avatarRadius(BuildContext context) =>
      Responsive.isDesktop(context) ? 52 : 44;

  double _rowHeight(BuildContext context) {
    // Avatar diameter + ~52px for name (2 lines @ ~16px line-height) +
    // character (1 line @ 12px) + the 10px gap above the name. Leaves a
    // few px of headroom for the press scale animation.
    return _avatarRadius(context) * 2 + 74;
  }
}

class _CastSkeleton extends StatelessWidget {
  const _CastSkeleton({required this.radius});
  final double radius;

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: StreamloadColors.v3SurfaceGlass,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: diameter * 0.8,
          height: 10,
          decoration: BoxDecoration(
            color: StreamloadColors.v3SurfaceGlass,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
