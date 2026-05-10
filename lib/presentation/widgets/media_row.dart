// lib/presentation/widgets/media_row.dart
import 'package:flutter/material.dart';

import '../../domain/models/media_summary.dart';
import '../theme/typography.dart';
import 'poster_card.dart';

class MediaRow extends StatelessWidget {
  const MediaRow({
    super.key,
    required this.title,
    required this.items,
    required this.onTap,
  });

  final String title;
  final List<MediaSummary> items;
  final void Function(MediaSummary) onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              title,
              style: StreamloadTypography.mono(fontSize: 11),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => PosterCard(
                summary: items[i],
                onTap: () => onTap(items[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
