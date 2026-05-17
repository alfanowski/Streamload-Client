// lib/presentation/widgets/title/title_hero.dart
//
// TitleHero — the title page's variant of the cinematic hero stack
// (Phase E1 of sub-plan 8). Shares HeroBackdrop (backdrop + bottom
// gradient) with the Home hero, but renders its own CTA strip wired to
// favorites / watchlist toggles + a share copy.
//
// 2026-05-16 (P1 hotfix): the YouTube trailer reveal was removed per
// operator feedback — heroes now just show the static backdrop.
//
// CTAs row:
//   - Primary  : ▶ Guarda  (or "▶ Guarda S1 E1" for TV; "▶ Riprendi"
//                if continue-watching has progress for this title) —
//                state stays PlayCtaState.play for Phase E; Phase F
//                swaps in availabilityProvider to switch to
//                PlayCtaState.checking / .unavailable
//   - Secondary: ＋ La mia lista  (toggles favorites; flips to "✓
//                Nella lista" when present)
//   - Tertiary : ↗ share circle (copies a deeplink to the clipboard)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/catalog_item.dart';
import '../../../state/availability_provider.dart';
import '../../../state/continue_watching_provider.dart';
import '../../../state/favorites_provider.dart';
import '../../../state/title_provider.dart';
import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../hero/hero_backdrop.dart';
import '../play_cta.dart';
import '../text_cta.dart';

class TitleHero extends ConsumerWidget {
  const TitleHero({
    super.key,
    required this.item,
    required this.onShare,
  });

  final CatalogItemResponse item;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPhone = Responsive.isPhone(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            HeroBackdrop(
              backdropUrl: item.backdropUrl,
              posterUrl: item.posterUrl,
            ),
            Positioned.fill(
              child: _Metadata(
                item: item,
                onShare: onShare,
                availableWidth: constraints.maxWidth,
                isPhone: isPhone,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Metadata extends ConsumerWidget {
  const _Metadata({
    required this.item,
    required this.onShare,
    required this.availableWidth,
    required this.isPhone,
  });

  final CatalogItemResponse item;
  final VoidCallback onShare;
  final double availableWidth;
  final bool isPhone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CM-6 editorial sizing: big serif title that anchors the page, mono
    // meta in the band below, 32 px breathing room before the CTAs.
    final isTablet = Responsive.isTablet(context);
    final horizontalPad = isPhone ? 16.0 : 64.0;
    final align =
        isPhone ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final titleSize = isPhone
        ? 40.0
        : isTablet
            ? 52.0
            : 64.0;
    final bottomInset = isPhone
        ? 32.0
        : isTablet
            ? 64.0
            : 96.0;
    final maxBlockWidth = isPhone
        ? availableWidth - (horizontalPad * 2)
        : (availableWidth * 0.55).clamp(360.0, 800.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        0,
        horizontalPad,
        bottomInset,
      ),
      child: Align(
        alignment: isPhone ? Alignment.bottomCenter : Alignment.bottomLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBlockWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: align,
            children: [
              Text(
                'TITOLO',
                style: StreamloadTypography.v3LabelMono(
                  color: StreamloadColors.v3TextSecondary,
                ),
                textAlign: isPhone ? TextAlign.center : TextAlign.start,
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: StreamloadTypography.v3DisplayHero()
                    .copyWith(fontSize: titleSize),
                textAlign: isPhone ? TextAlign.center : TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text(
                _metaLine(item),
                style: StreamloadTypography.v3MetaMono().copyWith(fontSize: 13),
                textAlign: isPhone ? TextAlign.center : TextAlign.start,
              ),
              // CM-6: 32 px gap between meta and CTAs so the typographic
              // cluster reads as its own block, not a continuation of the
              // meta line.
              const SizedBox(height: 32),
              _Ctas(
                item: item,
                onShare: onShare,
                availableWidth: availableWidth - (horizontalPad * 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _metaLine(CatalogItemResponse item) {
    final parts = <String>[];
    if (item.year != null) parts.add('${item.year}');
    if (item.mediaType == 'tv' && item.seasonsCount != null) {
      parts.add(
        item.seasonsCount == 1 ? '1 stagione' : '${item.seasonsCount} stagioni',
      );
    } else if (item.mediaType == 'movie' && item.runtimeMinutes != null) {
      parts.add('${item.runtimeMinutes} min');
    }
    parts.add('IT');
    if (item.rating != null) {
      parts.add('⭐ ${item.rating!.toStringAsFixed(1)}');
    }
    return parts.join(' · ');
  }
}

class _Ctas extends ConsumerWidget {
  const _Ctas({
    required this.item,
    required this.onShare,
    required this.availableWidth,
  });

  final CatalogItemResponse item;
  final VoidCallback onShare;
  final double availableWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = TitleKey(tmdbId: item.tmdbId, mediaType: item.mediaType);
    final favs = ref.watch(favoritesProvider);
    final isFav = favs.maybeWhen(
      data: (set) => set.contains(key),
      orElse: () => false,
    );
    // Peek at continue_watching for a resume hint. The spec says
    // "Riprendi" when watch_progress exists, otherwise "Guarda S1 E1"
    // for TV / "Guarda" for movie.
    final cw = ref.watch(continueWatchingProvider);
    final resume = cw.maybeWhen(
      data: (items) {
        for (final p in items) {
          if (p.tmdbId == item.tmdbId && p.mediaType == item.mediaType) {
            return p;
          }
        }
        return null;
      },
      orElse: () => null,
    );

    final label = _playLabel(item, resume);

    // Drive the availability probe with the SAME season/episode the Guarda
    // button would play if tapped. Movies omit both; TV uses the resume
    // point if continue-watching has one, else s1e1. Probing s1e1 when the
    // user is on s4e7 would race the wrong episode and could flip the CTA
    // to "unavailable" even though their actual resume target is fine.
    final int? probeSeason;
    final int? probeEpisode;
    if (item.mediaType == 'tv') {
      probeSeason = resume?.seasonNumber ?? 1;
      probeEpisode = resume?.episodeNumber ?? 1;
    } else {
      probeSeason = null;
      probeEpisode = null;
    }
    final availabilityKey = AvailabilityKey(
      tmdbId: item.tmdbId,
      mediaType: item.mediaType,
      season: probeSeason,
      episode: probeEpisode,
    );

    void goToWatch() {
      final query = StringBuffer('media_type=${item.mediaType}');
      if (resume != null && item.mediaType == 'tv') {
        if (resume.seasonNumber != null) {
          query.write('&season=${resume.seasonNumber}');
        }
        if (resume.episodeNumber != null) {
          query.write('&episode=${resume.episodeNumber}');
        }
      } else if (item.mediaType == 'tv') {
        query.write('&season=1&episode=1');
      }
      context.go('/watch/${item.tmdbId}?$query');
    }

    final stackVertical = availableWidth < 380;

    // The spec wants the unavailable state to be the SINGLE source of
    // truth for "can't play this title". pluginAccessProvider still gates
    // whether the title page is reachable at all (the route redirect
    // handles that), but the Guarda CTA itself defers to availability.
    final availability = ref.watch(availabilityProvider(availabilityKey));
    final ctaPlay = availability.when(
      loading: () => const PlayCta(state: PlayCtaState.checking),
      data: (avail) => avail
          ? PlayCta(
              state: PlayCtaState.play,
              label: label,
              onTap: goToWatch,
            )
          : const PlayCta(state: PlayCtaState.unavailable),
      error: (_, __) => const PlayCta(state: PlayCtaState.unavailable),
    );

    // CM-4 / CM-6: La mia lista and Condividi become typographic TextCtas
    // — the AnimatedSwitcher between "＋ La mia lista" and "✓ Nella lista"
    // becomes a label swap on the same TextCta.
    final addLabel = isFav ? 'Nella lista' : 'La mia lista';
    final addLeading = isFav ? '✓' : '＋';
    final ctaAdd = TextCta(
      label: addLabel,
      leading: addLeading,
      // Once added the trailing arrow looks odd — leave it bare so the
      // CTA reads as "this is a state, not a destination".
      trailing: isFav ? '' : '→',
      onTap: () async {
        try {
          await ref.read(favoritesProvider.notifier).toggle(key);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore: $e')),
            );
          }
        }
      },
    );

    final ctaShare = Tooltip(
      message: 'Condividi link',
      // We use an Icon-equivalent inside a TextCta via the leading slot
      // (↗) so the share affordance reads consistently with the cluster.
      child: TextCta(
        label: 'Condividi',
        leading: '↗',
        onTap: onShare,
      ),
    );

    if (stackVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ctaPlay,
          const SizedBox(height: 12),
          ctaAdd,
          const SizedBox(height: 12),
          ctaShare,
        ],
      );
    }
    return Wrap(
      spacing: 32,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [ctaPlay, ctaAdd, ctaShare],
    );
  }

  static String _playLabel(CatalogItemResponse item, dynamic resume) {
    if (resume != null) return 'Riprendi';
    if (item.mediaType == 'tv') return 'Guarda S1 E1';
    return 'Guarda';
  }
}
