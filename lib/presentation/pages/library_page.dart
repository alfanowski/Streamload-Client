// lib/presentation/pages/library_page.dart
//
// "La mia lista" — la collezione personale (favorites ∪ watchlist). Coerente con
// la Home: full-bleed nera (lo scrim Dynamic Island di AppShell torna visibile),
// nav in liquid glass nativo (GlassLargeTitleHeader), copertine/titoli identici
// (PosterCard). I contenuti sono divisi in 4 categorie (Film · Serie TV · Show
// televisivi · Anime): in overview ogni categoria è una PosterRow Home-style;
// "Vedi tutti →" isola la categoria in una griglia a tutta pagina.
//
// Routed da /list (primario) e /library (back-compat).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/library_category.dart';
import '../../domain/models/media_summary.dart';
import '../../state/my_list_items_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/library/glass_large_title_header.dart';
import '../widgets/poster_card.dart';
import '../widgets/rows/poster_row.dart';

const _categoryOrder = <LibraryCategory>[
  LibraryCategory.film,
  LibraryCategory.serieTv,
  LibraryCategory.show,
  LibraryCategory.anime,
];

String _labelFor(LibraryCategory c) {
  switch (c) {
    case LibraryCategory.film:
      return 'Film';
    case LibraryCategory.serieTv:
      return 'Serie TV';
    case LibraryCategory.show:
      return 'Show televisivi';
    case LibraryCategory.anime:
      return 'Anime';
  }
}

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  LibraryCategory? _isolated;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myListItemsProvider);
    final topPad = MediaQuery.of(context).padding.top;

    return ColoredBox(
      color: Colors.black,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: GlassLargeTitleHeader(
              title: 'La mia lista',
              topPadding: topPad,
              isolatedLabel: _isolated == null ? null : _labelFor(_isolated!),
              onBack: () => setState(() => _isolated = null),
            ),
          ),
          ...async.when(
            data: (items) => _dataSlivers(context, items),
            loading: _loadingSlivers,
            error: (_, __) => _errorSlivers(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  List<Widget> _dataSlivers(BuildContext context, List<LibraryItem> items) {
    if (items.isEmpty) {
      return const [
        SliverFillRemaining(hasScrollBody: false, child: _EmptyState()),
      ];
    }
    final grouped = <LibraryCategory, List<MediaSummary>>{};
    for (final it in items) {
      (grouped[it.category] ??= <MediaSummary>[]).add(it.summary);
    }

    if (_isolated != null) {
      return [_grid(context, grouped[_isolated!] ?? const [], _isolated!)];
    }

    final rows = <Widget>[];
    for (final cat in _categoryOrder) {
      final list = grouped[cat];
      if (list == null || list.isEmpty) continue;
      rows.add(Padding(
        padding: EdgeInsets.only(top: rows.isEmpty ? 8 : 24),
        child: PosterRow(
          title: _labelFor(cat),
          items: list,
          onSeeAll: () => setState(() => _isolated = cat),
        ),
      ));
    }
    return [SliverList(delegate: SliverChildListDelegate(rows))];
  }

  Widget _grid(
      BuildContext context, List<MediaSummary> items, LibraryCategory cat) {
    final columns = Responsive.isPhone(context)
        ? 3
        : Responsive.isTablet(context)
            ? 4
            : 6;
    return SliverPadding(
      padding: StreamloadSpacing.pagePaddingPhone.copyWith(top: 12, bottom: 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final m = items[i];
            final tag = 'lib_${cat.name}_${m.tmdbId}_$i';
            return PosterCard(
              summary: m,
              width: double.infinity,
              showLabel: true,
              heroTag: tag,
              onTap: () => context.push(
                '/title/${m.tmdbId}?media_type=${m.mediaType}',
                extra: tag,
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  List<Widget> _loadingSlivers() {
    return const [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 8),
          child: PosterRow(title: 'Film', items: [], isLoading: true),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 24),
          child: PosterRow(title: 'Serie TV', items: [], isLoading: true),
        ),
      ),
    ];
  }

  List<Widget> _errorSlivers() {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(myListItemsProvider),
            child: Text(
              'Errore di caricamento. Riprova',
              style: StreamloadTypography.v3Body(
                color: StreamloadColors.v3TextMuted,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 56,
              color: StreamloadColors.v3TextMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'La tua lista è vuota',
              style: StreamloadTypography.v3SectionHeader().copyWith(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tocca ＋ La mia lista su un titolo per aggiungerlo qui.',
              style: StreamloadTypography.v3Body(
                color: StreamloadColors.v3TextMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
