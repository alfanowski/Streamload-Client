// lib/presentation/pages/search_page.dart
//
// v3 Netflix×AppleTV refactor — full-results /search page (Phase G2).
//
// Lives at /search?q=<query>. The URL is the source of truth for the
// query; the input mirrors the query param on mount and writes back to
// the URL via context.go on submit (Enter on desktop, keyboard search
// action on phone). That makes results shareable + survives back nav.
//
// Layout:
//   - Top input row (full-width on phone, max ~720px centered elsewhere)
//   - Filter chip row (Tutto / Film / Serie TV / Anime) — local state
//   - Below: GridView.builder of PosterCard. Uses
//     SliverGridDelegateWithMaxCrossAxisExtent so width adapts smoothly
//     (5-ish cols desktop / 3 tablet / 2 phone).
//   - Empty / no-results / error / loading variants per spec.
//   - Infinite scroll: when within 200 px of the bottom and not already
//     loading, fetches the next page (capped at 5 = 100 results).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/remote/endpoints/search_api.dart';
import '../../domain/models/media_summary.dart';
import '../../state/api_client_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/poster_card.dart';
import '../widgets/press_feedback.dart';

/// Filter the type-chip row exposes. `null` = no filter ("Tutto").
enum SearchTypeFilter { all, movie, tv, anime }

extension on SearchTypeFilter {
  String get label {
    switch (this) {
      case SearchTypeFilter.all:
        return 'Tutto';
      case SearchTypeFilter.movie:
        return 'Film';
      case SearchTypeFilter.tv:
        return 'Serie TV';
      case SearchTypeFilter.anime:
        return 'Anime';
    }
  }

  bool matches(MediaSummary m) {
    switch (this) {
      case SearchTypeFilter.all:
        return true;
      case SearchTypeFilter.movie:
        return m.mediaType == 'movie';
      case SearchTypeFilter.tv:
        return m.mediaType == 'tv';
      case SearchTypeFilter.anime:
        return m.mediaType == 'anime';
    }
  }
}

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
  // = 100 results, which is more than enough for the filter chip to
  // bite into meaningfully.
  static const int _maxPages = 5;

  late final TextEditingController _controller;
  late final ScrollController _scrollController;
  String _activeQuery = '';
  SearchTypeFilter _filter = SearchTypeFilter.all;

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
      // Defer to the first frame so ref.read works and the input is
      // present in the tree.
      WidgetsBinding.instance.addPostFrameCallback((_) => _runFirstPage());
    }
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The URL changed (user submitted a new query or hit back). Reset
    // the input + results to match.
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
        // TMDB returns up to 20 per page. Anything less means we're at
        // the tail. Either way the page cap also exhausts.
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
    // URL is the source of truth — update it and let didUpdateWidget
    // reset our state.
    context.go('/search?q=${Uri.encodeQueryComponent(v)}');
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final isTablet = Responsive.isTablet(context);
    // Reserve room for the floating TopNavBar on desktop/tablet so the
    // input doesn't slip behind it. Phone shells don't have a top bar.
    final topPad = isPhone ? 16.0 : 72.0;
    final horizontalPad = isPhone
        ? StreamloadSpacing.pagePaddingPhone.horizontal / 2
        : isTablet
            ? StreamloadSpacing.pagePaddingTablet.horizontal / 2
            : StreamloadSpacing.pagePaddingDesktop.horizontal / 2;
    final filtered = _filter == SearchTypeFilter.all
        ? _items
        : _items.where(_filter.matches).toList(growable: false);

    return Material(
      // Transparent so the AppShell's Scaffold background shows through;
      // the TextField + InkWell descendants need a Material ancestor.
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
                12,
              ),
              child: _MaxWidth(
                maxWidth: isPhone ? double.infinity : 720,
                child: _SearchInput(
                  controller: _controller,
                  onSubmitted: _onSubmit,
                ),
              ),
            ),
          ),
          // Filter chips.
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPad,
                4,
                horizontalPad,
                12,
              ),
              child: _MaxWidth(
                maxWidth: isPhone ? double.infinity : 720,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final f in SearchTypeFilter.values)
                      _Chip(
                        label: f.label,
                        selected: _filter == f,
                        onTap: () => setState(() => _filter = f),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Body: empty/loading/error/grid.
          if (_activeQuery.isEmpty)
            _EmptyPromptSliver(padding: horizontalPad)
          else if (_loading && _items.isEmpty)
            _SkeletonGridSliver(padding: horizontalPad)
          else if (_error != null && _items.isEmpty)
            _ErrorSliver(
              padding: horizontalPad,
              onRetry: _runFirstPage,
            )
          else if (filtered.isEmpty)
            _NoResultsSliver(
              padding: horizontalPad,
              query: _activeQuery,
            )
          else
            _ResultsGridSliver(
              padding: horizontalPad,
              items: filtered,
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
// Input + chips
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
      child: TextField(
        controller: controller,
        cursorColor: StreamloadColors.v3TextPrimary,
        cursorWidth: 1.5,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          color: StreamloadColors.v3TextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Cerca un titolo…',
          hintStyle: StreamloadTypography.v3MetaMono(
            color: StreamloadColors.v3TextMuted,
          ).copyWith(fontSize: 22),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0x1FFFFFFF)),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0x1FFFFFFF)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0x66FFFFFF)),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          isCollapsed: true,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? StreamloadColors.v3CtaPrimaryBg
        : StreamloadColors.v3SurfaceGlass;
    final fg = selected
        ? StreamloadColors.v3CtaPrimaryFg
        : StreamloadColors.v3TextPrimary;
    return PressFeedback(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child:
                  Text(label, style: StreamloadTypography.v3CtaLabel(color: fg)),
            ),
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
// State slivers
// ──────────────────────────────────────────────────────────────────────────

class _EmptyPromptSliver extends StatelessWidget {
  const _EmptyPromptSliver({required this.padding});
  final double padding;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Center(
          child: Text(
            'Cerca un titolo, una serie o un anime',
            textAlign: TextAlign.center,
            style: StreamloadTypography.v3Body(
              color: StreamloadColors.v3TextMuted,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

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
                  borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
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
          // 2:3 poster + a small label strip beneath.
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => DecoratedBox(
            decoration: BoxDecoration(
              color: StreamloadColors.v3SurfaceGlass,
              borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
            ),
          ),
          childCount: 12,
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
          // Same aspect as the skeleton so swap-in doesn't jolt.
          childAspectRatio: 0.55,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final m = items[i];
            return PosterCard(
              summary: m,
              width: 180, // delegate gives the real width; PosterCard
                          // sizes its children proportionally.
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
