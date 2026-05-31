// lib/presentation/pages/library_page.dart
//
// "La mia lista" — la collezione personale (favorites ∪ watchlist). Coerente con
// la Home: full-bleed nera (lo scrim Dynamic Island di AppShell torna visibile),
// nav in liquid glass nativo (GlassLargeTitleHeader), copertine/titoli identici
// (PosterCard). I contenuti sono divisi in 4 categorie (Film · Serie TV · Show
// televisivi · Anime): ogni categoria è una PosterRow Home-style; "Vedi tutti →"
// apre un modale full-screen (CategoryListPage) con la stessa fisica del popup
// Title/Person.
//
// Routed da /list (primario) e /library (back-compat).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/library_category.dart';
import '../../domain/models/media_summary.dart';
import '../../state/my_list_items_provider.dart';
import '../pages/category_list_page.dart' show categoryLabel;
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/library/glass_large_title_header.dart' show LibraryTitleHeader;
import '../widgets/rows/poster_row.dart';

const _categoryOrder = <LibraryCategory>[
  LibraryCategory.film,
  LibraryCategory.serieTv,
  LibraryCategory.show,
  LibraryCategory.anime,
];

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myListItemsProvider);
    final topPad = MediaQuery.of(context).padding.top;

    return ColoredBox(
      color: Colors.black,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: LibraryTitleHeader(
              title: 'La mia lista',
              topPadding: topPad,
            ),
          ),
          ...async.when(
            data: (items) => _dataSlivers(context, items),
            loading: _loadingSlivers,
            error: (_, __) => _errorSlivers(ref),
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

    final rows = <Widget>[];
    for (final cat in _categoryOrder) {
      final list = grouped[cat];
      if (list == null || list.isEmpty) continue;
      rows.add(Padding(
        padding: EdgeInsets.only(top: rows.isEmpty ? 8 : 24),
        child: PosterRow(
          title: categoryLabel(cat),
          items: list,
          onSeeAll: () => context.push('/category/${cat.name}'),
        ),
      ));
    }
    return [SliverList(delegate: SliverChildListDelegate(rows))];
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

  List<Widget> _errorSlivers(WidgetRef ref) {
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
