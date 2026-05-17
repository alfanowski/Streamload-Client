// lib/presentation/pages/search_page.dart
//
// v3 Netflix×AppleTV refactor — full-results /search page.
//
// Pass 2E (2026-05-17): operator dropped the filter chip row + asked for
// a Netflix-style search experience. The page now:
//   - Skips the Tutto / Film / Serie TV / Anime chip row entirely; all
//     media types mix into the same grid.
//   - When the query is empty, renders a "Ricerche di tendenza" row of
//     up to 12 poster cards from trendingDayProvider (Top searches
//     parallel — clicking a poster jumps to the title page).
//   - The grid is full-bleed: 24 px page padding on desktop / tablet,
//     12 px on phone.
//   - Loading state: skeleton grid bumped to 24 cells (was 12).
//
// CM-2 (2026-05-17): the Pass 2E LiquidGlass pill input got swapped for
// a plain TextField on transparent with a hairline underline. The
// editorial pivot wants the search input to read like a magazine
// search field, not an iOS spotlight.
//
// The URL is still the source of truth for the query (?q=<query>),
// the input mirrors it on mount, and submitting writes back via
// context.go so results stay shareable and survive back nav.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/remote/endpoints/search_api.dart';
import '../../domain/models/media_summary.dart';
import '../../state/api_client_provider.dart';
import '../../state/home_rows_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/poster_card.dart';
import '../widgets/press_feedback.dart';
import '../widgets/shimmer.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialQuery = ''});

  /// The query the page opens with. Driven by `?q=<query>` in the URL so
  /// the page is shareable and survives a refresh.
  final String initialQuery;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  // Hard cap to keep TMDB happy and the grid finite. 5 pages × 20 items
  // = 100 results, which is more than enough for the user to skim.
  static const int _maxPages = 5;

  late final TextEditingController _controller;
  late final ScrollController _scrollController;
  String _activeQuery = '';

  final List<MediaSummary> _items = [];
  bool _loading = false;
  bool _exhausted = false;
  Object? _error;
  int _pagesLoaded = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _scrollController = ScrollController()..addListener(_onScroll);
    _activeQuery = widget.initialQuery.trim();
    if (_activeQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runFirstPage());
    }
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      _controller.text = widget.initialQuery;
      _activeQuery = widget.initialQuery.trim();
      _resetResults();
      if (_activeQuery.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _runFirstPage());
      }
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _resetResults() {
    setState(() {
      _items.clear();
      _loading = false;
      _exhausted = false;
      _error = null;
      _pagesLoaded = 0;
    });
  }

  Future<void> _runFirstPage() async {
    _resetResults();
    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_loading || _exhausted || _activeQuery.isEmpty) return;
    if (_pagesLoaded >= _maxPages) {
      setState(() => _exhausted = true);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final nextPage = _pagesLoaded + 1;
    try {
      final SearchApi api = await ref.read(searchApiProvider.future);
      final raw = await api.run(_activeQuery, page: nextPage);
      final list = (raw['results'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(MediaSummary.fromJson)
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _items.addAll(list);
        _pagesLoaded = nextPage;
        if (list.length < 20 || _pagesLoaded >= _maxPages) {
          _exhausted = true;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }

  void _onSubmit(String value) {
    final v = value.trim();
    if (v == _activeQuery) return;
    // URL is the source of truth.
    context.go('/search?q=${Uri.encodeQueryComponent(v)}');
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    // Pass 2E: full-bleed — 24 px desktop/tablet, 12 px phone. The Inter
    // 24 input expects ~16 px of breathing room; chip + grid bleed all
    // the way to those page paddings.
    final topPad = isPhone ? 16.0 : 72.0;
    final horizontalPad = isPhone ? 12.0 : 24.0;

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: StreamloadColors.v3BgBase),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Input row.
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  topPad,
                  horizontalPad,
                  16,
                ),
                child: _MaxWidth(
                  maxWidth: isPhone ? double.infinity : 820,
                  child: _SearchInput(
                    controller: _controller,
                    onSubmitted: _onSubmit,
                  ),
                ),
              ),
            ),
            // Body branches: empty → "Ricerche di tendenza" row;
            // otherwise loading/error/no-results/grid.
            if (_activeQuery.isEmpty)
              _TopSearchesSection(padding: horizontalPad)
            else if (_loading && _items.isEmpty)
              _SkeletonGridSliver(padding: horizontalPad)
            else if (_error != null && _items.isEmpty)
              _ErrorSliver(
                padding: horizontalPad,
                onRetry: _runFirstPage,
              )
            else if (_items.isEmpty)
              _NoResultsSliver(
                padding: horizontalPad,
                query: _activeQuery,
              )
            else
              _ResultsGridSliver(
                padding: horizontalPad,
                items: _items,
              ),
            // Footer: trailing spinner during incremental fetches.
            if (_loading && _items.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Input — Netflix-style glass pill (Pass 2E)
// ──────────────────────────────────────────────────────────────────────────

class _SearchInput extends StatelessWidget {
  const _SearchInput({required this.controller, required this.onSubmitted});
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: StreamloadColors.v3BorderGlass,
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: StreamloadColors.v3TextSecondary,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: controller,
                  cursorColor: StreamloadColors.v3TextPrimary,
                  cursorWidth: 1.5,
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSubmitted,
                  style: StreamloadTypography.display(
                    fontSize: 28,
                    italic: true,
                    color: StreamloadColors.v3TextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cerca un titolo, una serie o un anime…',
                    hintStyle: StreamloadTypography.display(
                      fontSize: 22,
                      italic: true,
                      color: StreamloadColors.v3TextMuted,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    isCollapsed: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Layout helpers
// ──────────────────────────────────────────────────────────────────────────

class _MaxWidth extends StatelessWidget {
  const _MaxWidth({required this.maxWidth, required this.child});
  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (maxWidth == double.infinity) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Empty-query → "Ricerche di tendenza" (Pass 2E)
// ──────────────────────────────────────────────────────────────────────────

class _TopSearchesSection extends ConsumerWidget {
  const _TopSearchesSection({required this.padding});
  final double padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trendingDayProvider);
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 12, padding, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mono eyebrow label keeps with the v3 "metadata as data"
            // typography. Operator wanted a real Netflix-style suggestion
            // row above the empty grid instead of a centered text prompt.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'SUGGERITE PER TE',
                style: StreamloadTypography.v3LabelMono(
                  color: StreamloadColors.v3TextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Ricerche di tendenza',
                style: StreamloadTypography.v3SectionHeader(),
              ),
            ),
            const SizedBox(height: 16),
            async.when(
              loading: () => const _SkeletonGrid(padding: 0, cells: 12),
              error: (_, __) => Text(
                'Errore nel caricamento delle tendenze',
                style: StreamloadTypography.v3MetaMono(
                  color: StreamloadColors.v3TextMuted,
                ),
              ),
              data: (items) {
                final top = items.take(12).toList(growable: false);
                if (top.isEmpty) {
                  return Text(
                    'Cerca un titolo, una serie o un anime',
                    style: StreamloadTypography.v3Body(
                      color: StreamloadColors.v3TextMuted,
                      fontSize: 16,
                    ),
                  );
                }
                return _Grid(items: top);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.items});
  final List<MediaSummary> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // Section is embedded in a CustomScrollView; this inner grid must
      // not scroll on its own.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final m = items[i];
        return PosterCard(
          summary: m,
          width: 180,
          onTap: () => context.go(
            '/title/${m.tmdbId}?media_type=${m.mediaType}',
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// State slivers
// ──────────────────────────────────────────────────────────────────────────

class _NoResultsSliver extends StatelessWidget {
  const _NoResultsSliver({required this.padding, required this.query});
  final double padding;
  final String query;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nessun risultato per “$query”',
                textAlign: TextAlign.center,
                style: StreamloadTypography.v3Body(
                  color: StreamloadColors.v3TextPrimary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Prova con meno parole.',
                textAlign: TextAlign.center,
                style: StreamloadTypography.v3MetaMono(
                  color: StreamloadColors.v3TextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorSliver extends StatelessWidget {
  const _ErrorSliver({required this.padding, required this.onRetry});
  final double padding;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Errore nella ricerca',
                style: StreamloadTypography.v3Body(
                  color: StreamloadColors.v3TextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              PressFeedback(
                child: Material(
                  color: StreamloadColors.v3SurfaceGlass,
                  borderRadius:
                      BorderRadius.circular(StreamloadSpacing.pillRadius),
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(StreamloadSpacing.pillRadius),
                    onTap: () => onRetry(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      child: Text(
                        'Riprova',
                        style: StreamloadTypography.v3CtaLabel(
                          color: StreamloadColors.v3TextPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonGridSliver extends StatelessWidget {
  const _SkeletonGridSliver({required this.padding});
  final double padding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => Shimmer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: StreamloadColors.v3SurfaceGlass,
                borderRadius:
                    BorderRadius.circular(StreamloadSpacing.cardRadius),
              ),
            ),
          ),
          // Pass 2E: bump to 24 cells so the empty + loading state fills
          // a Netflix-sized viewport instead of looking sparse.
          // Pass 2F: each cell shimmers individually for the wet 'load'
          // feel — heavy in tests but smooth on real GPUs.
          childCount: 24,
        ),
      ),
    );
  }
}

/// Non-sliver variant of the skeleton grid for embedding inside the
/// "Ricerche di tendenza" section before TMDB resolves. Same shimmer
/// treatment as the sliver variant.
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid({required this.padding, required this.cells});
  final double padding;
  final int cells;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemCount: cells,
        itemBuilder: (_, __) => Shimmer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: StreamloadColors.v3SurfaceGlass,
              borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultsGridSliver extends StatelessWidget {
  const _ResultsGridSliver({required this.padding, required this.items});
  final double padding;
  final List<MediaSummary> items;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.55,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final m = items[i];
            return PosterCard(
              summary: m,
              width: 180,
              onTap: () => context.go(
                '/title/${m.tmdbId}?media_type=${m.mediaType}',
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
