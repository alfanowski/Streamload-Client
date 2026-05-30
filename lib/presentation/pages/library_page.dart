// lib/presentation/pages/library_page.dart
//
// "La mia lista" — the user's personal collection. Routed from both
// /list (primary) and /library (kept for back-compat with any old
// bookmark / deeplink).
//
// 2026-05-17 (P3 hotfix): the previous implementation queried
// /api/library, which is the SERVER-SIDE catalog cache — that surfaced
// random titles other users had opened, NOT the current user's saved
// items. The operator reported "la mia lista al contrario mi fa vedere
// film e serie a caso". This page now reads the union of:
//   - favoritesProvider  (heart icon ON title pages)
//   - watchlistProvider  (＋ La mia lista pill)
// deduped by tmdbId, resolved against the local drift catalog cache for
// poster + title metadata, and split into Film / Serie TV tabs.
//
// Empty state: a friendly call-to-action pointing the user at the ＋ pill
// instead of just "Nessun risultato.". The page never falls back to the
// backend library endpoint anymore — that's a separate "catalog cache"
// concern and lives on the backend side only.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/media_summary.dart';
import '../../state/database_provider.dart';
import '../../state/favorites_provider.dart';
import '../../state/title_provider.dart';
import '../../state/watchlist_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../view_models/media_card_vm.dart';
import '../widgets/primitives/async_state_view.dart';
import '../widgets/primitives/media_poster_card.dart';
import '../widgets/primitives/responsive_grid.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _ctrl;

  static const _types = ['movie', 'tv'];
  static const _labels = ['Film', 'Serie TV'];

  @override
  void initState() {
    super.initState();
    _ctrl = TabController(length: _types.length, vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favAsync = ref.watch(favoritesProvider);
    final wlAsync = ref.watch(watchlistProvider);

    // Compose the deduped key set once per build; both providers carry
    // their own AsyncValue so we treat them as a coupled async state.
    final loading = favAsync.isLoading || wlAsync.isLoading;
    final error = favAsync.error ?? wlAsync.error;
    final fav = favAsync.value ?? const <TitleKey>{};
    final wl = wlAsync.value ?? const <TitleKey>{};
    final keys = <TitleKey>{...fav, ...wl}.toList(growable: false);

    return Scaffold(
      backgroundColor: StreamloadColors.v3BgBase,
      appBar: AppBar(
        backgroundColor: StreamloadColors.v3BgScrolled,
        title: const Text('La mia lista'),
        bottom: TabBar(
          controller: _ctrl,
          labelColor: StreamloadColors.v3TextPrimary,
          unselectedLabelColor: StreamloadColors.v3TextMuted,
          indicatorColor: StreamloadColors.v3TextPrimary,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: () {
        if (loading && keys.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (error != null) {
          return StreamloadErrorState(
            onRetry: () {
              ref.invalidate(favoritesProvider);
              ref.invalidate(watchlistProvider);
            },
          );
        }
        if (keys.isEmpty) {
          return const _EmptyState();
        }
        return TabBarView(
          controller: _ctrl,
          children: _types.map((t) {
            final keysForType =
                keys.where((k) => k.mediaType == t).toList(growable: false);
            return _ResolvedGrid(keys: keysForType);
          }).toList(),
        );
      }(),
    );
  }
}

/// Empty state — no favorites, no watchlist. Friendly CTA pointing the
/// user at the ＋ pill on title pages.
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

/// Resolves a list of TitleKey to MediaSummary records via the local
/// drift catalog cache (populated by titleProvider on any title-page
/// visit). Keys the user has never opened a title page for fall back to
/// a placeholder card with just the tmdbId — tapping it loads the title
/// page which populates the cache for next time.
class _ResolvedGrid extends ConsumerWidget {
  const _ResolvedGrid({required this.keys});
  final List<TitleKey> keys;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (keys.isEmpty) {
      return Center(
        child: Text(
          'Nessun titolo in questa sezione.',
          style: StreamloadTypography.v3Body(
            color: StreamloadColors.v3TextMuted,
          ),
        ),
      );
    }
    return FutureBuilder<List<MediaSummary>>(
      future: _resolve(ref),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? const <MediaSummary>[];
        if (items.isEmpty) {
          return Center(
            child: Text(
              'Nessun titolo in questa sezione.',
              style: StreamloadTypography.v3Body(
                color: StreamloadColors.v3TextMuted,
              ),
            ),
          );
        }
        final pad = Responsive.isPhone(context)
            ? StreamloadSpacing.pagePaddingPhone
            : Responsive.isTablet(context)
                ? StreamloadSpacing.pagePaddingTablet
                : StreamloadSpacing.pagePaddingDesktop;
        return SingleChildScrollView(
          padding: pad.copyWith(top: 16, bottom: 32),
          child: ResponsiveGrid(
            itemCount: items.length,
            itemAspectRatio: 0.55,
            itemBuilder: (context, i) {
              final vm = MediaCardVm.fromSummary(items[i]);
              return MediaPosterCard(
                item: vm,
                onTap: () => context.push(
                  '/title/${vm.tmdbId}?media_type=${vm.mediaType}',
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<List<MediaSummary>> _resolve(WidgetRef ref) async {
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
        // Local cache miss — render a minimal card. Tapping it opens the
        // title page which populates the cache, so next visit fills in
        // the poster / year.
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
