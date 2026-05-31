// lib/presentation/widgets/library/glass_large_title_header.dart
//
// Titolo di "La mia lista" — IDENTICO al titolo "Cerca" della SearchPage: stesso
// stile (v3DisplayPage, Fraunces italic 36), stesso spacing (status bar + 8, poi
// padding 16/0/16/14) e stesso comportamento (scorre via con la lista, non
// fissato). Nessuna barra glass, nessun titolo piccolo persistente.
import 'package:flutter/material.dart';

import '../../theme/typography.dart';

class LibraryTitleHeader extends StatelessWidget {
  const LibraryTitleHeader({
    super.key,
    required this.title,
    required this.topPadding,
  });

  final String title;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stessa spaziatura della SearchPage: status bar / Dynamic Island + 8.
        SizedBox(height: topPadding + 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StreamloadTypography.v3DisplayPage(),
          ),
        ),
      ],
    );
  }
}
