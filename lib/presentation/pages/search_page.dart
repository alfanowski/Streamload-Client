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
// iOS26 (2026-05-30): operator wanted the phone search to feel native to
// iOS 26. The input is now a true "Liquid Glass" pill (full radius +
// BackdropFilter blur + translucent fill), the "Streamload" wordmark is
// replaced by an in-scroll large "Cerca" title (App Store / Settings
// style), and the vertical rhythm was retuned — more air under the bar,
// section headers pulled tight onto their grids.
//
// The URL is still the source of truth for the query (?q=<query>),
// the input mirrors it on mount, and submitting writes back via
// context.go so results stay shareable and survive back nav.
import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/remote/endpoints/search_api.dart';
import '../../domain/models/media_summary.dart';
import '../../domain/models/search_results.dart';
import '../../state/api_client_provider.dart';
import '../../state/home_rows_provider.dart';
import '../../state/person_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/poster_card.dart';
import '../widgets/press_feedback.dart';
import '../widgets/rows/poster_row.dart';
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
  // Netflix-style: a tight, relevant set, not a grocery list. One TMDB page
  // (ranked best-first by the backend); the grid shows only the top
  // [_maxTitles].
  static const int _maxPages = 1;
  static const int _maxTitles = 14;

  late final TextEditingController _controller;
  late final ScrollController _scrollController;
  String _activeQuery = '';

  /// Debounce for real-time search — fires ~300ms after the user stops
  /// typing so we don't hit TMDB on every keystroke.
  Timer? _debounce;

  final List<MediaSummary> _items = [];
  // People only come back on page 1 of the multi-search; TMDB doesn't
  // re-surface them on later pages, so we capture them once and keep them
  // pinned above the title grid.
  List<SearchPersonResult> _people = const [];
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
    // External URL change (e.g. opened with ?q=…). Skip when the URL is just
    // catching up to a query we already ran live, to avoid a double fetch.
    if (oldWidget.initialQuery != widget.initialQuery) {
      final q = widget.initialQuery.trim();
      if (q != _activeQuery) {
        _controller.text = widget.initialQuery;
        _activeQuery = q;
        _resetResults();
        if (q.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _runFirstPage());
        }
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _resetResults() {
    setState(() {
      _items.clear();
      _people = const [];
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
      final results = await api.search(_activeQuery, page: nextPage);
      final list = results.titles;
      if (!mounted) return;
      setState(() {
        _items.addAll(list);
        // People only ride along on page 1 — capture them once.
        if (nextPage == 1) {
          _people = results.people;
        }
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

  static const Set<String> _nameSuffixes = {
    'jr',
    'jr.',
    'sr',
    'sr.',
    'ii',
    'iii',
    'iv'
  };

  /// User-proof person detection. If the query contains a matched person's
  /// first AND last name, treat it as a person search and return that person
  /// plus any LEFTOVER words (the title part). Examples:
  ///   "angelina jolie"            → (Angelina Jolie, leftover: [])
  ///   "iron man robert downey"    → (Robert Downey Jr., leftover: [iron, man])
  /// Empty leftover → show the whole filmography (by rating); non-empty →
  /// filter the filmography to those words (title + actor combined).
  ({SearchPersonResult person, List<String> leftover})? _personQuery() {
    final q = _activeQuery.toLowerCase().trim();
    if (q.isEmpty || _people.isEmpty) return null;
    final qTokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toSet();
    for (final p in _people) {
      final nameTokens = p.name
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty && !_nameSuffixes.contains(t))
          .toList();
      if (nameTokens.isEmpty) continue;
      // First + last name both present → it's this person.
      if (qTokens.contains(nameTokens.first) &&
          qTokens.contains(nameTokens.last)) {
        final leftover = qTokens.where((t) => !nameTokens.contains(t)).toList();
        return (person: p, leftover: leftover);
      }
    }
    return null;
  }

  /// Real-time: debounce keystrokes, then run the search locally (no Enter,
  /// no per-keystroke navigation).
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _applyQuery(value),
    );
  }

  void _applyQuery(String value) {
    final v = value.trim();
    if (v == _activeQuery) return;
    setState(() => _activeQuery = v);
    if (v.isEmpty) {
      _resetResults();
    } else {
      _runFirstPage();
    }
  }

  /// Enter (or the search action) — apply immediately and stamp the URL so the
  /// query stays shareable / survives a refresh.
  void _onSubmit(String value) {
    _debounce?.cancel();
    _applyQuery(value);
    final v = value.trim();
    if (v.isNotEmpty) {
      context.go('/search?q=${Uri.encodeQueryComponent(v)}');
    }
  }

  void _onClear() {
    _debounce?.cancel();
    _controller.clear();
    _applyQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final horizontalPad = isPhone ? 12.0 : 24.0;
    final personQuery = _personQuery();
    final safeTop = MediaQuery.of(context).padding.top;
    // Phone: clear the status bar, then an in-scroll "Cerca" large title sits
    // above the (NOT pinned) search bar — iOS App Store / Settings style.
    // Desktop: just clear the floating TopNavBar.
    final topSpace = isPhone ? safeTop + 8.0 : 72.0;
    final maxWidth = isPhone ? double.infinity : 820.0;

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: StreamloadColors.v3BgBase),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: topSpace)),
                  // iOS large title — scrolls with the content (phone only;
                  // desktop has the TopNavBar wordmark instead).
                  if (isPhone)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            horizontalPad + 4, 0, horizontalPad + 4, 14),
                        child: Text(
                          'Cerca',
                          style: StreamloadTypography.v3DisplayPage(),
                        ),
                      ),
                    ),
                  // Search bar scrolls away with the content (not pinned).
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          horizontalPad, 0, horizontalPad, 16),
                      child: _MaxWidth(
                        maxWidth: maxWidth,
                        child: _GlassSearchBar(
                          controller: _controller,
                          onChanged: _onQueryChanged,
                          onSubmitted: _onSubmit,
                          onClear: _onClear,
                        ),
                      ),
                    ),
                  ),
                  // Results modes glue straight onto the bar otherwise — give
                  // them the same ~24px breathing room the "Suggeriti" header
                  // gets in empty mode (16 bar-pad + 8 here).
                  if (_activeQuery.isNotEmpty)
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  // Body branches: empty → "Suggeriti" grid;
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
                  else if (_items.isEmpty && _people.isEmpty)
                    _NoResultsSliver(
                      padding: horizontalPad,
                      query: _activeQuery,
                    )
                  else if (personQuery != null) ...[
                    // PERSON / COMBINED MODE: the matched actor + their filmography
                    // (sorted by rating), optionally filtered by the leftover words
                    // for "title + actor" queries.
                    _PeopleSectionSliver(
                      padding: horizontalPad,
                      people: [personQuery.person],
                    ),
                    _PersonFilmographySliver(
                      person: personQuery.person,
                      filterTokens: personQuery.leftover,
                      padding: horizontalPad,
                    ),
                  ] else ...[
                    // TITLE MODE: people (if any) above, then the ranked title grid
                    // capped to the top [_maxTitles] (no grocery list).
                    if (_people.isNotEmpty)
                      _PeopleSectionSliver(
                        padding: horizontalPad,
                        people: _people,
                      ),
                    if (_items.isNotEmpty) ...[
                      if (_people.isNotEmpty)
                        _SectionHeaderSliver(
                          padding: horizontalPad,
                          label: 'Titoli',
                        ),
                      _ResultsGridSliver(
                        padding: horizontalPad,
                        items: _items.take(_maxTitles).toList(growable: false),
                      ),
                      // Netflix-style: a "similar titles" row under the matches,
                      // seeded from the top result's recommendations.
                      if (_exhausted)
                        _RelatedSliver(
                          seed: _items.first,
                          excludeIds: {for (final m in _items) m.tmdbId},
                        ),
                    ],
                  ],
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
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Search field — iOS 26 "Liquid Glass" capsule. A fully-rounded pill with a
// live backdrop blur behind a translucent fill + hairline rim, so content
// blurs through the bar as it scrolls under.
// ──────────────────────────────────────────────────────────────────────────

class _GlassSearchBar extends StatelessWidget {
  const _GlassSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  static const double _height = 52;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Full pill: radius = height / 2.
      borderRadius: BorderRadius.circular(_height / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: _height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: StreamloadColors.v3SurfaceGlass,
            borderRadius: BorderRadius.circular(_height / 2),
            border: Border.all(color: StreamloadColors.v3BorderGlass, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: StreamloadColors.v3TextSecondary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  cursorColor: StreamloadColors.v3TextPrimary,
                  cursorWidth: 1.5,
                  textInputAction: TextInputAction.search,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  style: const TextStyle(
                    color: StreamloadColors.v3TextPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Film, serie TV, attori e altro…',
                    hintStyle: TextStyle(
                      color: StreamloadColors.v3TextMuted,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClear,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.close_rounded,
                        color: StreamloadColors.v3TextSecondary,
                        size: 20,
                      ),
                    ),
                  );
                },
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
        padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A single clean "Suggeriti" header, same editorial style as the
            // Home row headers — sits tight above its poster grid.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Suggeriti',
                style: StreamloadTypography.v3SectionHeader(),
              ),
            ),
            const SizedBox(height: 6),
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
        childAspectRatio: 2 / 3,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final m = items[i];
        return PosterCard(
          summary: m,
          width: 180,
          showLabel: false,
          onTap: () => context.push(
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
          childAspectRatio: 2 / 3,
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
          childAspectRatio: 2 / 3,
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

// ──────────────────────────────────────────────────────────────────────────
// People section (PS-4) — actor-first results above the title grid
// ──────────────────────────────────────────────────────────────────────────

class _PeopleSectionSliver extends StatelessWidget {
  const _PeopleSectionSliver({required this.padding, required this.people});
  final double padding;
  final List<SearchPersonResult> people;

  @override
  Widget build(BuildContext context) {
    // Up to 6 matched people, as a clean horizontal row of circular avatars
    // (Apple TV cast style) — tap routes to /person/<id>.
    final top = people.take(6).toList(growable: false);
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding + 4, 4, padding + 4, 0),
            child: Text(
              'Persone',
              style: StreamloadTypography.v3SectionHeader(),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 152,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: padding),
              itemCount: top.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) => _PersonCard(person: top[i]),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// A single person result — circular avatar + name + role. Tap → /person/:id.
class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person});
  final SearchPersonResult person;

  static const double _diameter = 92;

  @override
  Widget build(BuildContext context) {
    final role = _departmentLabel(person.department);
    return PressFeedback(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go('/person/${person.tmdbId}'),
        child: SizedBox(
          width: 100,
          child: Column(
            children: [
              Container(
                width: _diameter,
                height: _diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: StreamloadColors.v3BorderGlass,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: person.profileUrl != null
                      ? CachedNetworkImage(
                          imageUrl: person.profileUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const _AvatarFallback(),
                          errorWidget: (_, __, ___) => const _AvatarFallback(),
                        )
                      : const _AvatarFallback(),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                person.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: StreamloadColors.v3TextPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
              if (role != null) ...[
                const SizedBox(height: 2),
                Text(
                  role,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: StreamloadColors.v3TextMuted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String? _departmentLabel(String? department) {
    switch (department) {
      case 'Acting':
        return 'Interprete';
      case 'Directing':
        return 'Regia';
      case 'Writing':
        return 'Sceneggiatura';
      case 'Production':
        return 'Produzione';
      default:
        return null;
    }
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StreamloadColors.v3SurfaceGlassHi,
            StreamloadColors.v3SurfaceGlass,
          ],
        ),
      ),
      child: Icon(
        Icons.person_outline,
        color: StreamloadColors.v3TextMuted,
        size: 30,
      ),
    );
  }
}

class _SectionHeaderSliver extends StatelessWidget {
  const _SectionHeaderSliver({required this.padding, required this.label});
  final double padding;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(padding + 4, 12, padding + 4, 6),
      sliver: SliverToBoxAdapter(
        child: Text(
          label,
          style: StreamloadTypography.v3SectionHeader(),
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
          childAspectRatio: 2 / 3,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final m = items[i];
            return PosterCard(
              summary: m,
              width: 180,
              showLabel: false,
              onTap: () => context.push(
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

/// "Titoli simili a …" — a Home-style covers row under the results, seeded
/// from the top match's TMDB recommendations (the "Marvel catalogue under
/// Iron Man" idea). Renders nothing until recommendations resolve / if empty.
class _RelatedSliver extends ConsumerWidget {
  const _RelatedSliver({required this.seed, required this.excludeIds});
  final MediaSummary seed;
  final Set<int> excludeIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      recommendationsProvider(
        TmdbKey(tmdbId: seed.tmdbId, mediaType: seed.mediaType),
      ),
    );
    return async.maybeWhen(
      data: (recs) {
        final filtered = recs
            .where((r) => !excludeIds.contains(r.tmdbId))
            .take(18)
            .toList(growable: false);
        if (filtered.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: PosterRow(
              title: 'Titoli simili a "${seed.title}"',
              items: filtered,
            ),
          ),
        );
      },
      orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

/// PERSON MODE filmography — the matched person's films & shows, sorted by
/// rating on the backend. Covers-only grid under a "Film e serie" header.
class _PersonFilmographySliver extends ConsumerWidget {
  const _PersonFilmographySliver({
    required this.person,
    required this.padding,
    this.filterTokens = const <String>[],
  });
  final SearchPersonResult person;
  final double padding;

  /// Leftover query words for a "title + actor" search — when present, the
  /// filmography is filtered to titles matching them (e.g. "iron man" under
  /// Robert Downey Jr.).
  final List<String> filterTokens;

  static const int _maxFilms = 18;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(personCreditsProvider(person.tmdbId));
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 8, padding, 0),
        child: async.when(
          data: (films) {
            var list = films;
            if (filterTokens.isNotEmpty) {
              bool matches(MediaSummary m, bool all) {
                final t = m.title.toLowerCase();
                return all
                    ? filterTokens.every(t.contains)
                    : filterTokens.any(t.contains);
              }

              // Prefer titles containing ALL leftover words; fall back to ANY.
              var f = films.where((m) => matches(m, true)).toList();
              if (f.isEmpty) f = films.where((m) => matches(m, false)).toList();
              list = f;
            }
            list = list.take(_maxFilms).toList(growable: false);
            if (list.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Film e serie',
                    style: StreamloadTypography.v3SectionHeader(),
                  ),
                ),
                const SizedBox(height: 16),
                _Grid(items: list),
              ],
            );
          },
          loading: () => const _SkeletonGrid(padding: 0, cells: 9),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
