// lib/presentation/widgets/title/title_sidebar.dart
//
// Title page sidebar — labeled blocks for crew (CREATO DA) + genres
// (GENERI). Renders crew names from creditsProvider plus genres from
// CatalogItemResponse.genres.
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
//
// 2026-05-17 (CM-2 / CM-6): the Pass 2B LiquidGlass card around the
// blocks was dropped. The sidebar is now flat text against the page
// background, with a hairline divider between each section. Editorial.
//
// 2026-05-17 (Pass 3 CAST-4): the CAST text block is gone. Cast lives
// in the photo CastRow on the title page itself (Prime Video / IMDb
// style); the sidebar keeps only CREATO DA + GENERI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/catalog_credits.dart';
import '../../../domain/models/catalog_item.dart';
import '../../../state/home_rows_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';

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
    final blocks = <Widget>[
      ...async.when(
        loading: () => <Widget>[const _SidebarSkeleton()],
        error: (_, __) => const <Widget>[],
        data: (credits) => _SidebarBody.buildBlocks(credits),
      ),
      if (item.genres.isNotEmpty)
        _Block(
          label: 'GENERI',
          value: item.genres.join(', '),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const _Divider(),
          blocks[i],
        ],
      ],
    );
  }
}

class _SidebarBody {
  /// Build the CREATO DA block (genres are appended by the parent so the
  /// divider layout stays consistent). CAST was moved out of the sidebar
  /// in Pass 3 CAST-4 — the new CastRow renders actor photos directly on
  /// the title page.
  static List<Widget> buildBlocks(CatalogCredits credits) {
    final crew = credits.crew;
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
    return [
      if (crewLine.isNotEmpty) _Block(label: 'CREATO DA', value: crewLine),
    ];
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CM-6: label uses v3LabelMono (already uppercase, wide-tracked
          // mono) — the brief asks for italic, but JetBrainsMono's italic
          // glyphs are too informal for a sidebar label. We keep the
          // existing label style; the editorial pivot is carried by the
          // hairline dividers + flat layout.
          Text(label, style: StreamloadTypography.v3LabelMono()),
          const SizedBox(height: 8),
          Text(
            value,
            style: StreamloadTypography.v3Body(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: StreamloadColors.v3BorderGlass,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CAST-4: the CAST sidebar block was removed (cast lives in the
          // photo row now), so the skeleton drops to a single CREATO DA
          // placeholder while credits resolve.
          Text(
            'CREATO DA',
            style: StreamloadTypography.v3LabelMono(),
          ),
          const SizedBox(height: 8),
          bar(0.5),
        ],
      ),
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
