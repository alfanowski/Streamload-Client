// lib/presentation/pages/title_page.dart
//
// v3 Title page — Netflix×AppleTV refactor (sub-plan 8, Phase E).
//
// Composition:
//
//   - Hero (backdrop + 2s-later trailer + bottom gradient + 🔊 toggle)
//     with the title page CTAs: ▶ Guarda S1 E1 / Riprendi (primary),
//     ＋ La mia lista (toggle), ↗ share.
//   - Body branches on Responsive:
//       desktop : 2-col below the hero (synopsis 2/3 | sidebar 1/3),
//                 then full-width episodes section + similar titles row
//       tablet  : same as desktop but tighter ratios
//       phone   : single column stacked — synopsis → "Mostra dettagli"
//                 expandable (cast / created-by / genres) → episodes
//                 → similar titles row
//
// The page keeps the route + initial controllers intact; the body is
// replaced wholesale. Phase F will wire availabilityProvider into the
// PlayCta state — for E we always render PlayCtaState.play (or the
// page-level "checking" spinner while titleProvider resolves).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/catalog_item.dart';
import '../../state/home_rows_provider.dart';
import '../../state/title_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/cast/cast_card.dart';
import '../widgets/cast/cast_row.dart';
import '../widgets/title/episode_list.dart';
import '../widgets/title/similar_titles_row.dart';
import '../widgets/title/title_hero.dart';
import '../widgets/title/title_sidebar.dart';

class TitlePage extends ConsumerWidget {
  const TitlePage({
    super.key,
    required this.tmdbId,
    required this.mediaType,
  });

  final int tmdbId;
  final String mediaType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      titleProvider(TitleKey(tmdbId: tmdbId, mediaType: mediaType)),
    );
    return Scaffold(
      backgroundColor: StreamloadColors.v3BgBase,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(
            'Errore: $e',
            style: const TextStyle(color: StreamloadColors.v3TextPrimary),
          ),
        ),
        data: (item) => _TitleBody(item: item),
      ),
    );
  }
}

/// Routes between the responsive variants. Each layout owns its own
/// scaffolding (padding, column count, hero height) but shares the
/// common pieces: TitleHero, sidebar, episode list, similar row.
class _TitleBody extends ConsumerWidget {
  const _TitleBody({required this.item});
  final CatalogItemResponse item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Share helper bound to the BuildContext-free callback path. Phase G
    // will replace this with a Share sheet on mobile; for now we copy to
    // the clipboard and acknowledge with a SnackBar so the user gets
    // immediate feedback the link is in their paste buffer.
    void onShare() {
      final url = 'streamload://title/${item.tmdbId}'
          '?media_type=${item.mediaType}';
      Clipboard.setData(ClipboardData(text: url));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copiato negli appunti')),
      );
    }

    if (Responsive.isPhone(context)) {
      return _TitleMobileLayout(item: item, onShare: onShare);
    }
    if (Responsive.isTablet(context)) {
      return _TitleTabletLayout(item: item, onShare: onShare);
    }
    return _TitleDesktopLayout(item: item, onShare: onShare);
  }
}

/// Pass 3 CAST-4 — bridges creditsProvider into the photo CastRow.
/// Maps each cast member to CastCardData, keeping the row widget unaware
/// of the credits domain model. Hides itself completely when the list is
/// empty (CastRow already has the same fallback, but doing it here also
/// suppresses the surrounding SizedBox spacing the page would add).
class _CastSection extends ConsumerWidget {
  const _CastSection({required this.item});
  final CatalogItemResponse item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      creditsProvider(
        TmdbKey(tmdbId: item.tmdbId, mediaType: item.mediaType),
      ),
    );
    return async.when(
      loading: () => const CastRow(members: [], isLoading: true),
      error: (_, __) => const SizedBox.shrink(),
      data: (credits) {
        final members = credits.cast
            .map((p) => CastCardData(
                  tmdbId: p.id,
                  name: p.name,
                  character: p.character,
                  profileUrl: p.profileUrl,
                ))
            .toList(growable: false);
        return CastRow(members: members);
      },
    );
  }
}

/// Two-column "Trama" + sidebar — shared by desktop and tablet layouts.
class _SynopsisAndSidebar extends StatelessWidget {
  const _SynopsisAndSidebar({
    required this.item,
    required this.synopsisFlex,
    required this.sidebarFlex,
  });

  final CatalogItemResponse item;
  final int synopsisFlex;
  final int sidebarFlex;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: synopsisFlex,
          // CM-6: constrain the reading column to ~720 px max so the
          // synopsis stays in magazine-readable line length on wide
          // monitors. ConstrainedBox lives INSIDE the Expanded so the
          // flex layout still gets its share of the row, we just don't
          // stretch the text across the entire share.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRAMA',
                  style: StreamloadTypography.v3LabelMono(),
                ),
                const SizedBox(height: 12),
                if ((item.overview ?? '').isNotEmpty)
                  Text(
                    item.overview!,
                    // CM-6: Inter 16 + 1.6 line-height — magazine body.
                    style: StreamloadTypography.v3Body(fontSize: 16).copyWith(
                      height: 1.6,
                    ),
                  )
                else
                  Text(
                    'Sinossi non disponibile.',
                    style: StreamloadTypography.v3Body(
                      fontSize: 16,
                      color: StreamloadColors.v3TextMuted,
                    ).copyWith(height: 1.6),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 48),
        Expanded(
          flex: sidebarFlex,
          child: TitleSidebar(item: item),
        ),
      ],
    );
  }
}

class _TitleDesktopLayout extends StatelessWidget {
  const _TitleDesktopLayout({required this.item, required this.onShare});
  final CatalogItemResponse item;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    // Pass 2D (2026-05-17): hero bumped 440 → 560 on desktop so the
    // backdrop feels majestic instead of cramped. Capped at 70% of the
    // viewport so the rest of the page (synopsis + episodes) still has
    // breathing room above the fold on shorter monitors.
    final viewportH = MediaQuery.sizeOf(context).height;
    final heroHeight = (viewportH * 0.70).clamp(520.0, 660.0);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: heroHeight,
          child: TitleHero(item: item, onShare: onShare),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: StreamloadSpacing.pagePaddingDesktop,
          child: _SynopsisAndSidebar(
            item: item,
            synopsisFlex: 2,
            sidebarFlex: 1,
          ),
        ),
        // CAST-4: photo cast row spans the full page width (NOT inside the
        // 2/3 synopsis column). Sits above episodes for both desktop and
        // tablet so the reader meets the faces before the episode grid.
        const SizedBox(height: 32),
        _CastSection(item: item),
        if (item.mediaType == 'tv') ...[
          const SizedBox(height: 32),
          Padding(
            padding: StreamloadSpacing.pagePaddingDesktop,
            child: EpisodeList(tmdbId: item.tmdbId),
          ),
        ],
        const SizedBox(height: 40),
        SimilarTitlesRow(tmdbId: item.tmdbId, mediaType: item.mediaType),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _TitleTabletLayout extends StatelessWidget {
  const _TitleTabletLayout({required this.item, required this.onShare});
  final CatalogItemResponse item;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    // Pass 2D: hero bumped 360 → 440 on tablet (clamped within a
    // viewport-relative range so portrait + landscape iPads both feel
    // cinematic without burying the row content).
    final viewportH = MediaQuery.sizeOf(context).height;
    final heroHeight = (viewportH * 0.55).clamp(400.0, 520.0);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: heroHeight,
          child: TitleHero(item: item, onShare: onShare),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: StreamloadSpacing.pagePaddingTablet,
          child: _SynopsisAndSidebar(
            item: item,
            // Tighter ratio on tablet so the synopsis doesn't get pinched.
            synopsisFlex: 3,
            sidebarFlex: 2,
          ),
        ),
        // CAST-4: photo cast row spans full width above episodes.
        const SizedBox(height: 32),
        _CastSection(item: item),
        if (item.mediaType == 'tv') ...[
          const SizedBox(height: 32),
          Padding(
            padding: StreamloadSpacing.pagePaddingTablet,
            child: EpisodeList(tmdbId: item.tmdbId),
          ),
        ],
        const SizedBox(height: 40),
        SimilarTitlesRow(tmdbId: item.tmdbId, mediaType: item.mediaType),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _TitleMobileLayout extends StatelessWidget {
  const _TitleMobileLayout({required this.item, required this.onShare});
  final CatalogItemResponse item;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context).height;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: viewport * 0.65,
          child: TitleHero(item: item, onShare: onShare),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: StreamloadSpacing.pagePaddingPhone,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRAMA',
                style: StreamloadTypography.v3LabelMono(),
              ),
              const SizedBox(height: 12),
              if ((item.overview ?? '').isNotEmpty)
                Text(
                  item.overview!,
                  // CM-6: same Inter 16 + 1.6 line-height on phone — the
                  // constrained 720 px max doesn't bite at phone widths.
                  style: StreamloadTypography.v3Body(fontSize: 16).copyWith(
                    height: 1.6,
                  ),
                )
              else
                Text(
                  'Sinossi non disponibile.',
                  style: StreamloadTypography.v3Body(
                    fontSize: 16,
                    color: StreamloadColors.v3TextMuted,
                  ).copyWith(height: 1.6),
                ),
              const SizedBox(height: 24),
              TitleSidebarExpandable(item: item),
            ],
          ),
        ),
        // CAST-4: cast row sits OUTSIDE the page padding so it spans full
        // width like the home rows. The row itself injects the phone
        // page padding on its inner list.
        const SizedBox(height: 24),
        _CastSection(item: item),
        if (item.mediaType == 'tv') ...[
          const SizedBox(height: 24),
          Padding(
            padding: StreamloadSpacing.pagePaddingPhone,
            child: EpisodeList(tmdbId: item.tmdbId),
          ),
        ],
        const SizedBox(height: 32),
        SimilarTitlesRow(tmdbId: item.tmdbId, mediaType: item.mediaType),
        const SizedBox(height: 40),
      ],
    );
  }
}
