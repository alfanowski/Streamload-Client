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
import '../../state/title_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/title/episode_list.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRAMA',
                style: StreamloadTypography.v3LabelMono(),
              ),
              const SizedBox(height: 8),
              if ((item.overview ?? '').isNotEmpty)
                Text(
                  item.overview!,
                  style: StreamloadTypography.v3Body(),
                )
              else
                Text(
                  'Sinossi non disponibile.',
                  style: StreamloadTypography.v3Body(
                    color: StreamloadColors.v3TextMuted,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 32),
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
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 440,
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
        if (item.mediaType == 'tv') ...[
          const SizedBox(height: 32),
          Padding(
            padding: StreamloadSpacing.pagePaddingDesktop,
            child: EpisodeList(tmdbId: item.tmdbId),
          ),
        ],
        const SizedBox(height: 32),
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
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 360,
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
        if (item.mediaType == 'tv') ...[
          const SizedBox(height: 32),
          Padding(
            padding: StreamloadSpacing.pagePaddingTablet,
            child: EpisodeList(tmdbId: item.tmdbId),
          ),
        ],
        const SizedBox(height: 32),
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
              const SizedBox(height: 8),
              if ((item.overview ?? '').isNotEmpty)
                Text(
                  item.overview!,
                  style: StreamloadTypography.v3Body(),
                )
              else
                Text(
                  'Sinossi non disponibile.',
                  style: StreamloadTypography.v3Body(
                    color: StreamloadColors.v3TextMuted,
                  ),
                ),
              const SizedBox(height: 16),
              TitleSidebarExpandable(item: item),
              if (item.mediaType == 'tv') ...[
                const SizedBox(height: 24),
                EpisodeList(tmdbId: item.tmdbId),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
