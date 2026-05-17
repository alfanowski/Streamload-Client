// lib/presentation/pages/home_page.dart
//
// v3 Home page — hero carousel + 8-10 horizontally scrollable rows
// (sub-plan 8, Phase D5). Composes:
//
//   - HeroCarousel  : top 5 of trendingWeek with autoplay trailers
//   - BackdropRow   : Continua a guardare (hidden if empty)
//   - PosterRow x N : Tendenze oggi / Nuove uscite / per-genere rows /
//                    La mia lista (hidden if empty) / Top di sempre
//   - BackdropRow   : Visti di recente (completed watch_progress; hidden
//                    if empty)
//
// Each row is its own Consumer so a slow / failing provider doesn't
// block the rest of the page. A row that errors renders an inline
// "Errore di caricamento" text instead of crashing.
//
// HomePage also owns the scroll listener that flips navScrolledProvider
// once the page is past 80px so the floating TopNavBar swaps glass →
// solid background.
//
// The optional [filter] parameter (null / movie / tv / anime) is passed
// from the /film, /serie, /anime routes — it narrows the row composition
// to the relevant subset. The top nav (TopNavBar) is the single source
// of truth for the active filter — Pass 2C dropped the redundant filter
// chip row below the hero per operator feedback ("le chips in basso non
// mi piacciono").
//
// 2026-05-17 (Cinema Magazine pivot, CM-8): the default Home row count
// dropped 9 → 6 (Tendenze oggi + Continua + Nuove uscite + La mia lista
// + Visti di recente + Top di sempre). Operator wants less density —
// "less is more" in editorial. The /film, /serie, /anime filter
// catalogs keep their fuller compositions because they're the BROWSE
// pages — there the user is explicitly looking for variety.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/media_summary.dart';
import '../../state/continue_watching_provider.dart';
import '../../state/database_provider.dart';
import '../../state/favorites_provider.dart';
import '../../state/home_rows_provider.dart';
import '../../state/nav_scrolled_provider.dart';
import '../../state/plugin_access_provider.dart';
import '../../state/title_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/hero/hero_carousel.dart';
import '../widgets/rows/poster_row.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, this.filter});

  /// `null` = everything, otherwise `'movie'` / `'tv'` / `'anime'`.
  /// The /film, /serie, /anime routes pass the matching value.
  final String? filter;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final ScrollController _scrollController;
  bool _lastSentScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 80;
    if (scrolled != _lastSentScrolled) {
      _lastSentScrolled = scrolled;
      ref.read(navScrolledProvider.notifier).state = scrolled;
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = widget.filter;
    final heroHeight = _heroHeightFor(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            StreamloadColors.v3BgGradientStart,
            StreamloadColors.v3BgGradientEnd,
          ],
        ),
      ),
      child: ListView(
        controller: _scrollController,
        // Push the hero down on desktop / tablet so it doesn't render
        // behind the notched MacOS title bar / phone top inset. On phone
        // the AppShell already adds SafeArea(top: true).
        padding: EdgeInsets.zero,
        children: [
          // Hero carousel — autoDispose so reopening Home gets fresh
          // trending titles. On loading / error, we render a backdrop
          // placeholder of the same height.
          _HeroSection(height: heroHeight),
          // Pass 2C: the per-page filter chip row was dropped per
          // operator feedback. The TopNavBar already exposes Home /
          // Film / Serie TV / Anime / La mia lista — duplicating those
          // choices below the hero was visual noise without adding
          // affordance. The filter routing still works via the top nav
          // tabs.
          const SizedBox(height: 24),
          // Rows section. Each row is hidden when the filter excludes it.
          ..._buildRows(context, filter),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  List<Widget> _buildRows(BuildContext context, String? filter) {
    // P2 (2026-05-17): /film and /serie were showing only 3-4 rows — the
    // operator wanted a full Netflix-style catalog. Each filter now
    // composes a dedicated row set with multiple genre rows so the
    // browse pages feel populated.
    if (filter == 'movie') return _buildMovieRows();
    if (filter == 'tv') return _buildTvRows();
    if (filter == 'anime') return _buildAnimeRows();
    return _buildDefaultRows();
  }

  // ──────────────────────────────────────────────────────────────────
  // Row builders, one per filter. Helpers below keep the .addAll
  // boilerplate (row + spacer) out of every call site.
  // ──────────────────────────────────────────────────────────────────

  List<Widget> _buildDefaultRows() {
    // CM-8 (2026-05-17): trimmed to 6 rows — Tendenze oggi + Continua +
    // Nuove uscite + La mia lista + Visti di recente + Top di sempre.
    // The previous genre rows (Crime & Thriller / Commedie italiane /
    // Anime / Documentari) moved off Home: the filter catalogs
    // (/film, /serie, /anime) carry them. Editorial /home is a curated
    // landing page, not a catalog browser.
    final rows = <Widget>[];
    _addRow(rows,
        _RowConsumer(title: 'Tendenze oggi', provider: trendingDayProvider));
    _addRow(rows, const _ContinueWatchingRow());
    _addRow(
      rows,
      _RowConsumer(
        title: 'Nuove uscite',
        provider: newReleasesAllProvider,
      ),
    );
    _addRow(rows, const _MyListRow());
    _addRow(rows, const _RecentlyWatchedRow());
    _addRow(rows,
        _RowConsumer(title: 'Top di sempre', provider: topRatedAllProvider));
    return rows;
  }

  List<Widget> _buildMovieRows() {
    // /film — Netflix-style movie catalog. Multiple genre rows so the
    // page has 10+ horizontal scrollers.
    final rows = <Widget>[];
    _addRow(
      rows,
      _RowConsumer(
        title: 'Tendenze film oggi',
        provider: trendingDayMoviesProvider,
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Nuove uscite',
        provider: newReleasesProvider('movie'),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Azione',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [28],
          mediaType: 'movie',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Commedie',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [35],
          mediaType: 'movie',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Drama',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [18],
          mediaType: 'movie',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Crime & Thriller',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [80, 53],
          mediaType: 'movie',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Horror',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [27],
          mediaType: 'movie',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Sci-Fi & Fantasy',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [878, 14],
          mediaType: 'movie',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Romance',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [10749],
          mediaType: 'movie',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Avventura & Family',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [12, 10751],
          mediaType: 'movie',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Commedie italiane',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [35],
          mediaType: 'movie',
          originalLanguage: 'it',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Top di sempre',
        provider: topRatedProvider('movie'),
      ),
    );
    return rows;
  }

  List<Widget> _buildTvRows() {
    // /serie — TV-only equivalent. TV uses different genre IDs than
    // movies (e.g. 10759 "Action & Adventure" instead of 28 "Action").
    final rows = <Widget>[];
    _addRow(
      rows,
      _RowConsumer(
        title: 'Tendenze serie TV oggi',
        provider: trendingDayTvProvider,
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Nuove uscite',
        provider: newReleasesProvider('tv'),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Drama',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [18],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Crime',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [80],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Commedie',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [35],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Sci-Fi & Fantasy',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [10765],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Mystery',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [9648],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Action & Adventure',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [10759],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Reality',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [10764],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Documentari',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [99],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Top di sempre',
        provider: topRatedProvider('tv'),
      ),
    );
    return rows;
  }

  List<Widget> _buildAnimeRows() {
    // /anime — anime is TV with genre 16 (Animation) and origin JP.
    // We approximate sub-categories with extra genres + the existing
    // discoverAnime endpoint (origin-country filter).
    final rows = <Widget>[];
    _addRow(
      rows,
      _RowConsumer(
        title: 'Anime',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [16],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Anime · Azione & Avventura',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [16, 10759],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Anime · Sci-Fi & Fantasy',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [16, 10765],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Anime · Commedia',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [16, 35],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Anime · Drama',
        provider: byGenreProvider(const GenreRowKey(
          genreIds: [16, 18],
          mediaType: 'tv',
        )),
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Tendenze TV oggi',
        provider: trendingDayTvProvider,
      ),
    );
    _addRow(
      rows,
      _RowConsumer(
        title: 'Top serie TV',
        provider: topRatedProvider('tv'),
      ),
    );
    return rows;
  }

  /// Push a row + its trailing spacer to the list in one call. The
  /// spacer height is per-breakpoint (CM-8): 56 desktop / 32 tablet /
  /// 24 phone — editorial breathing room on big screens, tighter on
  /// the phone where scroll-distance budget is precious.
  void _addRow(List<Widget> rows, Widget row) {
    rows.add(row);
    rows.add(SizedBox(height: _rowGapFor(context)));
  }

  double _rowGapFor(BuildContext context) {
    if (Responsive.isPhone(context)) return StreamloadSpacing.rowGapPhone;
    if (Responsive.isTablet(context)) return StreamloadSpacing.rowGapTablet;
    return StreamloadSpacing.rowGapDesktop;
  }

  double _heroHeightFor(BuildContext context) {
    // Pass 2D (2026-05-17): operator said 'la hero è troppo bassa'.
    // Desktop bumps 480 → 620, tablet 360 → 480, phone stays at 65% of
    // viewport. On very tall desktop windows we still cap somewhere
    // sensible so the hero doesn't eat the entire viewport on a 27''
    // monitor — clamp at 75% of the visible height with a hard ceiling
    // of 720 px. The metadata block already aligns bottom-left so the
    // extra headroom reads as cinematic, not as a void.
    if (Responsive.isPhone(context)) {
      return MediaQuery.sizeOf(context).height * 0.65;
    }
    final viewportH = MediaQuery.sizeOf(context).height;
    if (Responsive.isTablet(context)) {
      return (viewportH * 0.70).clamp(420.0, 560.0);
    }
    return (viewportH * 0.75).clamp(560.0, 720.0);
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Hero section
// ──────────────────────────────────────────────────────────────────────────

class _HeroSection extends ConsumerWidget {
  const _HeroSection({required this.height});
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(heroSlidesProvider);
    return async.when(
      data: (slides) {
        if (slides.isEmpty) {
          return _HeroPlaceholder(
            height: height,
            label: 'Nessun titolo in evidenza',
            onRetry: () => ref.invalidate(heroSlidesProvider),
          );
        }
        // Bind navigation + favorites toggles at render time so they
        // capture the live BuildContext / WidgetRef.
        final wired = slides
            .map((s) => HeroSlideData(
                  title: s.title,
                  mediaType: s.mediaType,
                  tmdbId: s.tmdbId,
                  year: s.year,
                  runtimeMinutes: s.runtimeMinutes,
                  episodeCount: s.episodeCount,
                  rating: s.rating,
                  synopsis: s.synopsis,
                  backdropUrl: s.backdropUrl,
                  posterUrl: s.posterUrl,
                  videoId: s.videoId,
                  languageCode: s.languageCode,
                  onPlay: s.tmdbId == null
                      ? null
                      : () => context.go(
                            '/title/${s.tmdbId}?media_type=${s.mediaType}',
                          ),
                  onAdd: s.tmdbId == null
                      ? null
                      : () {
                          ref.read(favoritesProvider.notifier).toggle(
                                TitleKey(
                                  tmdbId: s.tmdbId!,
                                  mediaType: s.mediaType,
                                ),
                              );
                        },
                ))
            .toList(growable: false);
        return HeroCarousel(slides: wired, height: height);
      },
      loading: () => _HeroPlaceholder(
        height: height,
        label: 'Caricamento…',
      ),
      // FAIL LOUD: if hero data 404s / 500s, surface the failure with a
      // visible retry instead of pretending nothing's wrong. The page
      // can never be silently empty.
      error: (_, __) => _HeroPlaceholder(
        height: height,
        label: 'Errore di caricamento',
        onRetry: () => ref.invalidate(heroSlidesProvider),
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({
    required this.height,
    required this.label,
    this.onRetry,
  });
  final double height;
  final String label;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: StreamloadColors.v3SurfaceGlass,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 56,
            color: StreamloadColors.v3TextMuted,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: StreamloadTypography.v3MetaMono(
              color: StreamloadColors.v3TextMuted,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: onRetry,
              borderRadius:
                  BorderRadius.circular(StreamloadSpacing.chipRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  'Riprova',
                  style: StreamloadTypography.v3CtaLabel(
                    color: StreamloadColors.v3TextPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Row consumers
// ──────────────────────────────────────────────────────────────────────────

/// Generic row Consumer that watches a FutureProvider<List<MediaSummary>>
/// and renders PosterRow with loading / data / error states.
///
/// 2026-05-16 (P0 hotfix): the previous version returned
/// `SizedBox.shrink()` when items was empty, which made the entire Home
/// page look blank if every backend row endpoint 404'd. The page must
/// FAIL LOUD — every row now renders SOMETHING (loading shimmer,
/// header + error message, or header + "Nessun titolo"), so we can
/// never silently render nothing again.
class _RowConsumer extends ConsumerWidget {
  const _RowConsumer({
    required this.title,
    required this.provider,
  });
  final String title;
  // We accept a `ProviderListenable` for ref.watch + a `ProviderOrFamily`
  // for ref.invalidate via the same object. Every FutureProvider /
  // AutoDispose family element satisfies both, so a single field works.
  final ProviderListenable<AsyncValue<List<MediaSummary>>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(provider);
    return async.when(
      data: (items) {
        if (items.isEmpty) {
          return _RowEmpty(title: title);
        }
        return PosterRow(title: title, items: items);
      },
      loading: () => PosterRow(
        title: title,
        items: const [],
        isLoading: true,
      ),
      error: (err, _) => _RowError(
        title: title,
        error: err,
        // Tapping the row's "Riprova" reinvalidates this exact provider
        // so a backend hiccup doesn't kill the row until the user leaves
        // and re-enters Home.
        onRetry: () {
          // Every concrete provider passed to _RowConsumer (FutureProvider
          // / AutoDispose family element) subtypes ProviderBase, which
          // extends ProviderOrFamily — but the field type is the wider
          // ProviderListenable interface so a single field works for
          // both plain providers and family elements. The dynamic cast
          // is safe because the constructor signature precludes anything
          // else.
          final dynamic p = provider;
          if (p is ProviderOrFamily) {
            ref.invalidate(p);
          }
        },
      ),
    );
  }
}

class _RowError extends StatelessWidget {
  const _RowError({
    required this.title,
    required this.error,
    required this.onRetry,
  });
  final String title;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final pagePad = Responsive.isPhone(context)
        ? StreamloadSpacing.pagePaddingPhone
        : Responsive.isTablet(context)
            ? StreamloadSpacing.pagePaddingTablet
            : StreamloadSpacing.pagePaddingDesktop;
    return Padding(
      padding: pagePad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: StreamloadTypography.v3SectionHeader()),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: StreamloadColors.v3TextMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Errore di caricamento',
                  style: StreamloadTypography.v3MetaMono(
                    color: StreamloadColors.v3TextMuted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onRetry,
                borderRadius:
                    BorderRadius.circular(StreamloadSpacing.chipRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    'Riprova',
                    style: StreamloadTypography.v3MetaMono(
                      color: StreamloadColors.v3TextSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quiet "no items" state — header stays visible so the user knows the
/// row exists even when TMDB returned nothing for this query. The
/// original implementation returned SizedBox.shrink() here, which is
/// indistinguishable from "the row was never built" and was the root
/// cause of the May-16 "home is empty" report.
class _RowEmpty extends StatelessWidget {
  const _RowEmpty({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final pagePad = Responsive.isPhone(context)
        ? StreamloadSpacing.pagePaddingPhone
        : Responsive.isTablet(context)
            ? StreamloadSpacing.pagePaddingTablet
            : StreamloadSpacing.pagePaddingDesktop;
    return Padding(
      padding: pagePad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: StreamloadTypography.v3SectionHeader()),
          const SizedBox(height: 6),
          Text(
            'Nessun titolo disponibile',
            style: StreamloadTypography.v3MetaMono(
              color: StreamloadColors.v3TextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Continua a guardare — same 2:3 PosterRow as the other rows (per user
// preference), with a progress bar overlay on each card. Subtitle on the
// card replaces the year line with the season/episode pointer so the user
// knows what they were last watching.
// ──────────────────────────────────────────────────────────────────────────

class _ContinueWatchingRow extends ConsumerWidget {
  const _ContinueWatchingRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(pluginAccessProvider);
    if (access != PluginAccess.available) return const SizedBox.shrink();
    final async = ref.watch(continueWatchingProvider);
    return async.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final summaries = <MediaSummary>[];
        final progress = <int, double>{};
        final subtitles = <int, String>{};
        for (final i in items) {
          summaries.add(MediaSummary(
            tmdbId: i.tmdbId,
            mediaType: i.mediaType,
            title: i.title,
            year: null,
            posterUrl: i.posterUrl,
          ));
          if (i.durationSeconds > 0) {
            progress[i.tmdbId] = i.positionSeconds / i.durationSeconds;
          }
          if (i.seasonNumber != null && i.episodeNumber != null) {
            subtitles[i.tmdbId] = 'S${i.seasonNumber} · E${i.episodeNumber}';
          }
        }
        return PosterRow(
          title: 'Continua a guardare',
          items: summaries,
          progressByTmdbId: progress,
          subtitleByTmdbId: subtitles,
        );
      },
      loading: () => const PosterRow(
        title: 'Continua a guardare',
        items: [],
        isLoading: true,
      ),
      error: (err, _) => _RowError(
        title: 'Continua a guardare',
        error: err,
        onRetry: () => ref.invalidate(continueWatchingProvider),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// "La mia lista" — favorites ∪ watchlist, resolved against the local
// drift catalog cache for poster + title. Items never opened locally
// fall back to a placeholder card with the tmdbId only.
// ──────────────────────────────────────────────────────────────────────────

class _MyListRow extends ConsumerWidget {
  const _MyListRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keys = ref.watch(myListKeysProvider);
    if (keys.isEmpty) return const SizedBox.shrink();
    return FutureBuilder<List<MediaSummary>>(
      future: _resolve(ref, keys),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const PosterRow(
            title: 'La mia lista',
            items: [],
            isLoading: true,
          );
        }
        final items = snap.data ?? const <MediaSummary>[];
        if (items.isEmpty) return const SizedBox.shrink();
        return PosterRow(
          title: 'La mia lista',
          items: items,
          seeAllTo: '/list',
        );
      },
    );
  }

  Future<List<MediaSummary>> _resolve(WidgetRef ref, List<TitleKey> keys) async {
    final db = ref.read(databaseProvider);
    final out = <MediaSummary>[];
    for (final k in keys) {
      final row = await db.catalogDao.get(k.tmdbId, k.mediaType);
      if (row != null) {
        out.add(MediaSummary(
          tmdbId: row.tmdbId,
          mediaType: row.mediaType,
          title: row.title,
          year: row.year,
          posterUrl: row.posterUrl,
          backdropUrl: row.backdropUrl,
        ));
      } else {
        // Unknown locally — render a minimal card with the tmdbId; the
        // user can tap it to load the title page which will populate the
        // cache for next time.
        out.add(MediaSummary(
          tmdbId: k.tmdbId,
          mediaType: k.mediaType,
          title: '#${k.tmdbId}',
        ));
      }
    }
    return out;
  }
}

// ──────────────────────────────────────────────────────────────────────────
// "Visti di recente" — completed watch_progress items
// (progress fraction >= 0.95). Falls back to empty if nothing qualifies.
// ──────────────────────────────────────────────────────────────────────────

class _RecentlyWatchedRow extends ConsumerWidget {
  const _RecentlyWatchedRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(pluginAccessProvider);
    if (access != PluginAccess.available) return const SizedBox.shrink();
    final async = ref.watch(continueWatchingProvider);
    return async.when(
      data: (items) {
        final completed = items
            .where((i) =>
                i.durationSeconds > 0 &&
                i.positionSeconds / i.durationSeconds >= 0.95)
            .toList(growable: false);
        if (completed.isEmpty) return const SizedBox.shrink();
        // Same 2:3 PosterRow as the other rows for visual consistency.
        final summaries = completed
            .map((i) => MediaSummary(
                  tmdbId: i.tmdbId,
                  mediaType: i.mediaType,
                  title: i.title,
                  year: null,
                  posterUrl: i.posterUrl,
                ))
            .toList(growable: false);
        return PosterRow(
          title: 'Visti di recente',
          items: summaries,
        );
      },
      // No loading / error state — this row is best-effort.
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

