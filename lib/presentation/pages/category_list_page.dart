// lib/presentation/pages/category_list_page.dart
//
// Modale full-screen "Vedi tutti" di una categoria de La mia lista. Stessa fisica
// del popup Title / Person: presentato via _modalRoute (fade full-screen,
// opaque:false) e avvolto in [ModalShell] (sfondo nero, ✕ in liquid glass,
// pull-to-dismiss con trascinamento verso il basso).
//
// Contenuto: titolo categoria + griglia SOLO COPERTINE dei titoli salvati in
// quella categoria. I dati vengono da myListItemsProvider (già risolto +
// classificato), filtrati per categoria.
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
import '../widgets/modal/modal_shell.dart';
import '../widgets/poster_card.dart';

String categoryLabel(LibraryCategory c) {
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

class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key, required this.category});

  final LibraryCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myListItemsProvider);
    return ModalShell(
      child: async.when(
        loading: () => const _Centered(child: CircularProgressIndicator()),
        error: (_, __) => _Centered(
          child: Text(
            'Errore di caricamento',
            style: StreamloadTypography.v3Body(
              color: StreamloadColors.v3TextMuted,
            ),
          ),
        ),
        data: (items) {
          final list = items
              .where((i) => i.category == category)
              .map((i) => i.summary)
              .toList(growable: false);
          return _CategoryGrid(category: category, items: list);
        },
      ),
    );
  }
}

/// Wrapper scrollabile (così il pull-to-dismiss di ModalShell ha un scroll da
/// ascoltare) per gli stati senza griglia.
class _Centered extends StatelessWidget {
  const _Centered({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: child),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.category, required this.items});
  final LibraryCategory category;
  final List<MediaSummary> items;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final columns = Responsive.isPhone(context)
        ? 3
        : Responsive.isTablet(context)
            ? 4
            : 6;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          // topPad + 60 lascia spazio sotto il ✕ glass (top: topPad+8, h 38).
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, topPad + 60, 20, 12),
            child: Text(
              categoryLabel(category),
              style: StreamloadTypography.display(fontSize: 30, italic: false)
                  .copyWith(color: StreamloadColors.v3TextPrimary),
            ),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'Nessun titolo in questa categoria.',
                style: StreamloadTypography.v3Body(
                  color: StreamloadColors.v3TextMuted,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: StreamloadSpacing.pagePaddingPhone
                .copyWith(top: 4, bottom: topPad + 80),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 2 / 3,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final m = items[i];
                  final tag = 'cat_${category.name}_${m.tmdbId}_$i';
                  return PosterCard(
                    summary: m,
                    width: double.infinity,
                    showLabel: false,
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
          ),
      ],
    );
  }
}
