// lib/presentation/widgets/media_grid.dart
import 'package:flutter/material.dart';

import '../../domain/models/media_summary.dart';
import 'poster_card.dart';

class MediaGrid extends StatelessWidget {
  const MediaGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.padding = const EdgeInsets.all(24),
  });

  final List<MediaSummary> items;
  final void Function(MediaSummary) onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Nessun risultato.'));
    }
    return GridView.builder(
      padding: padding,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.55,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => PosterCard(
        summary: items[i],
        onTap: () => onTap(items[i]),
      ),
    );
  }
}
