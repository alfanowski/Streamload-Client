// lib/presentation/widgets/title/title_sidebar.dart
//
// Title page sidebar — three labeled blocks: CAST · CREATO DA · GENERI
// (Phase E2 of sub-plan 8). Renders cast + crew names from
// creditsProvider plus genres from CatalogItemResponse.genres.
//
// Used in two layouts:
//   - Desktop / Tablet : right-hand sidebar (1/3 width). Each block
//                        stacks `v3LabelMono` over a comma-separated
//                        name list rendered with `v3Body fontSize 12`.
//   - Phone            : reused inside an ExpansionTile titled
//                        "Mostra dettagli" below the synopsis.
//
// Loading state: subtle skeleton lines (no shimmer, just dim blocks)
// so the sidebar doesn't visually shout while TMDB resolves.
// Error / empty state: hidden entirely — the page reads cleanly without
// a "no credits" placeholder. Genres still render from the catalog item.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/catalog_credits.dart';
import '../../../domain/models/catalog_item.dart';
import '../../../state/home_rows_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../liquid_glass.dart';

class TitleSidebar extends ConsumerWidget {
  const TitleSidebar({super.key, required this.item});

  final CatalogItemResponse item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      creditsProvider(
        TmdbKey(tmdbId: item.tmdbId, mediaType: item.mediaType),
      ),
    );
    // Pass 2B (2026-05-17): the three info blocks (CAST / CREATO DA /
    // GENERI) are tucked inside a soft LiquidGlass card so the sidebar
    // reads as a discrete surface instead of bare text floating on the
    // page background. The glass picks up the hero gradient bleed at the
    // top of the page, then settles into a quiet translucent panel
    // further down — matches the Apple TV+ aesthetic where every block
    // feels like its own card.
    return LiquidGlass(
      borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius + 4),
      opacity: 0.06,
      blur: 18,
      borderOpacity: 0.10,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          async.when(
            loading: () => const _SidebarSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
            data: (credits) => _SidebarBody(credits: credits),
          ),
          if (item.genres.isNotEmpty) ...[
            const SizedBox(height: 20),
            _Block(
              label: 'GENERI',
              value: item.genres.join(', '),
            ),
          ],
        ],
      ),
    );
  }
}

class _SidebarBody extends StatelessWidget {
  const _SidebarBody({required this.credits});
  final CatalogCredits credits;

  @override
  Widget build(BuildContext context) {
    final cast = credits.cast;
    final crew = credits.crew;
    final castNames = cast.map((p) => p.name).join(', ');
    // Group crew by their job so multiple Producers don't read as
    // "Producer, Producer, Producer". We keep the per-job ordering
    // the backend returned (insertion order = relevance).
    final crewByJob = <String, List<String>>{};
    for (final p in crew) {
      final job = p.job ?? '';
      if (job.isEmpty) continue;
      crewByJob.putIfAbsent(job, () => <String>[]).add(p.name);
    }
    final crewLine = crewByJob.values
        .map((names) => names.join(', '))
        .join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (castNames.isNotEmpty)
          _Block(label: 'CAST', value: castNames),
        if (castNames.isNotEmpty && crewLine.isNotEmpty)
          const SizedBox(height: 20),
        if (crewLine.isNotEmpty)
          _Block(label: 'CREATO DA', value: crewLine),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StreamloadTypography.v3LabelMono()),
        const SizedBox(height: 6),
        Text(
          value,
          style: StreamloadTypography.v3Body(fontSize: 12),
        ),
      ],
    );
  }
}

class _SidebarSkeleton extends StatelessWidget {
  const _SidebarSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double widthFraction) => FractionallySizedBox(
          widthFactor: widthFraction,
          alignment: Alignment.centerLeft,
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: StreamloadColors.v3SurfaceGlass,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CAST',
          style: StreamloadTypography.v3LabelMono(),
        ),
        const SizedBox(height: 6),
        bar(0.9),
        const SizedBox(height: 6),
        bar(0.6),
        const SizedBox(height: 20),
        Text(
          'CREATO DA',
          style: StreamloadTypography.v3LabelMono(),
        ),
        const SizedBox(height: 6),
        bar(0.5),
      ],
    );
  }
}

/// Phone-only wrapper that collapses [TitleSidebar] behind a "Mostra
/// dettagli" expansion. Reuses the same widget so the sidebar content
/// stays consistent across breakpoints — the only difference is the
/// disclosure chrome.
class TitleSidebarExpandable extends StatelessWidget {
  const TitleSidebarExpandable({super.key, required this.item});

  final CatalogItemResponse item;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Strip the default ExpansionTile divider so the title page reads
      // as one continuous surface instead of segmented bands.
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        listTileTheme: ListTileTheme.of(context).copyWith(
          contentPadding: EdgeInsets.zero,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.symmetric(vertical: 4),
        title: Text(
          'Mostra dettagli',
          style: StreamloadTypography.v3SectionHeader(),
        ),
        iconColor: StreamloadColors.v3TextPrimary,
        collapsedIconColor: StreamloadColors.v3TextSecondary,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
              bottom: StreamloadSpacing.cardGap,
            ),
            child: TitleSidebar(item: item),
          ),
        ],
      ),
    );
  }
}
