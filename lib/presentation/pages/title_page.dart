// lib/presentation/pages/title_page.dart
//
// Title page — a full-screen, Netflix-style MODAL that slides up over the
// app, dismissible by the ✕ button or by dragging it down (it pulls down and
// reveals the page beneath, then pops). It reads like a standalone page, not
// a popup. Content is rebuilt in the Home's premium style: a cinematic hero
// (backdrop → black) with glass CTAs (Riproduci · La mia lista · share), then
// Trama, Cast (avatars), Info, Episodi (TV) and Titoli simili.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/catalog_item.dart';
import '../../state/availability_provider.dart';
import '../../state/continue_watching_provider.dart';
import '../../state/favorites_provider.dart';
import '../../state/home_rows_provider.dart';
import '../../state/title_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/cast/cast_card.dart';
import '../widgets/cast/cast_row.dart';
import '../widgets/hero/hero_backdrop.dart';
import '../widgets/hero/hero_cta_button.dart';
import '../widgets/title/episode_list.dart';
import '../widgets/title/similar_titles_row.dart';

class TitlePage extends ConsumerWidget {
  const TitlePage({super.key, required this.tmdbId, required this.mediaType});

  final int tmdbId;
  final String mediaType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      titleProvider(TitleKey(tmdbId: tmdbId, mediaType: mediaType)),
    );
    return _TitleModal(
      child: async.when(
        loading: () => const ColoredBox(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => ColoredBox(
          color: Colors.black,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Errore: $e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: StreamloadColors.v3TextPrimary),
              ),
            ),
          ),
        ),
        data: (item) => _TitleContent(item: item),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Dismissible modal shell — drag down to pull the page off, or tap ✕.
// ──────────────────────────────────────────────────────────────────────────

class _TitleModal extends StatefulWidget {
  const _TitleModal({required this.child});
  final Widget child;

  @override
  State<_TitleModal> createState() => _TitleModalState();
}

class _TitleModalState extends State<_TitleModal> {
  double _drag = 0; // how far the sheet is pulled down

  static const double _dismissThreshold = 110;

  void _dismiss() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (n is OverscrollNotification && n.overscroll < 0) {
      // Pulling down past the top of the content.
      setState(() => _drag = (_drag - n.overscroll).clamp(0.0, 600.0));
    } else if (n is ScrollUpdateNotification && _drag > 0) {
      // Scrolling back up while pulled → ease the sheet back.
      final delta = n.scrollDelta ?? 0;
      if (delta > 0) setState(() => _drag = (_drag - delta).clamp(0.0, 600.0));
    } else if (n is ScrollEndNotification) {
      if (_drag > _dismissThreshold) {
        _dismiss();
      } else if (_drag != 0) {
        setState(() => _drag = 0);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    // Behind-the-modal dim fades a touch as you drag it away.
    final scrimOpacity = (1 - _drag / 400).clamp(0.0, 1.0);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: Colors.black54.withValues(alpha: 0.55 * scrimOpacity)),
            ),
          ),
          AnimatedPadding(
            duration: _drag == 0
                ? const Duration(milliseconds: 240)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(top: _drag),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(_drag > 0 ? 18 : 0),
              ),
              child: ColoredBox(
                color: Colors.black,
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: widget.child,
                ),
              ),
            ),
          ),
          // ✕ close button.
          Positioned(
            top: topPad + 8 + _drag,
            right: 14,
            child: _CloseButton(onTap: _dismiss),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Content
// ──────────────────────────────────────────────────────────────────────────

class _TitleContent extends StatelessWidget {
  const _TitleContent({required this.item});
  final CatalogItemResponse item;

  void _onShare(BuildContext context) {
    final url = 'streamload://title/${item.tmdbId}?media_type=${item.mediaType}';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copiato negli appunti')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final pad = isPhone
        ? StreamloadSpacing.pagePaddingPhone
        : StreamloadSpacing.pagePaddingDesktop;
    final heroHeight = MediaQuery.sizeOf(context).height * (isPhone ? 0.62 : 0.7);

    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        SizedBox(
          height: heroHeight,
          child: _TitleHeroSection(item: item, onShare: () => _onShare(context)),
        ),
        const SizedBox(height: 8),
        // Trama
        if ((item.overview ?? '').isNotEmpty)
          Padding(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trama', style: StreamloadTypography.v3SectionHeader()),
                const SizedBox(height: 12),
                Text(
                  item.overview!,
                  style: StreamloadTypography.v3Body(fontSize: 16)
                      .copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        const SizedBox(height: 28),
        _CastSection(item: item),
        const SizedBox(height: 28),
        Padding(
          padding: pad,
          child: _InfoBlock(item: item),
        ),
        if (item.mediaType == 'tv') ...[
          const SizedBox(height: 28),
          Padding(padding: pad, child: EpisodeList(tmdbId: item.tmdbId)),
        ],
        const SizedBox(height: 32),
        SimilarTitlesRow(tmdbId: item.tmdbId, mediaType: item.mediaType),
        const SizedBox(height: 48),
      ],
    );
  }
}

// ── Hero ───────────────────────────────────────────────────────────────────

class _TitleHeroSection extends StatelessWidget {
  const _TitleHeroSection({required this.item, required this.onShare});
  final CatalogItemResponse item;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final isTablet = Responsive.isTablet(context);
    final titleSize = isPhone ? 36.0 : (isTablet ? 46.0 : 56.0);
    final hPad = isPhone ? 16.0 : 64.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        HeroBackdrop(backdropUrl: item.backdropUrl, posterUrl: item.posterUrl),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, isPhone ? 24 : 56),
            child: Align(
              alignment:
                  isPhone ? Alignment.bottomCenter : Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isPhone ? 520 : 760),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isPhone
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      textAlign: isPhone ? TextAlign.center : TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StreamloadTypography.v3DisplayHero()
                          .copyWith(fontSize: titleSize),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _metaLine(item),
                      textAlign: isPhone ? TextAlign.center : TextAlign.start,
                      style: StreamloadTypography.v3MetaMono()
                          .copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    _HeroCtas(item: item, onShare: onShare, isPhone: isPhone),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _metaLine(CatalogItemResponse item) {
    final parts = <String>[item.mediaType == 'tv' ? 'Serie TV' : 'Film'];
    if (item.year != null) parts.add('${item.year}');
    if (item.mediaType == 'tv' && item.seasonsCount != null) {
      parts.add(item.seasonsCount == 1
          ? '1 stagione'
          : '${item.seasonsCount} stagioni');
    } else if (item.mediaType == 'movie' && item.runtimeMinutes != null) {
      parts.add('${item.runtimeMinutes} min');
    }
    if (item.rating != null) parts.add('⭐ ${item.rating!.toStringAsFixed(1)}');
    return parts.join(' · ');
  }
}

class _HeroCtas extends ConsumerWidget {
  const _HeroCtas({
    required this.item,
    required this.onShare,
    required this.isPhone,
  });
  final CatalogItemResponse item;
  final VoidCallback onShare;
  final bool isPhone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = TitleKey(tmdbId: item.tmdbId, mediaType: item.mediaType);
    final isFav = ref.watch(favoritesProvider).maybeWhen(
          data: (set) => set.contains(key),
          orElse: () => false,
        );
    final resume = ref.watch(continueWatchingProvider).maybeWhen(
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

    int? season, episode;
    if (item.mediaType == 'tv') {
      season = resume?.seasonNumber ?? 1;
      episode = resume?.episodeNumber ?? 1;
    }
    final canPlay = ref
        .watch(availabilityProvider(AvailabilityKey(
          tmdbId: item.tmdbId,
          mediaType: item.mediaType,
          season: season,
          episode: episode,
        )))
        .maybeWhen(data: (a) => a, orElse: () => true);

    void goToWatch() {
      final q = StringBuffer('media_type=${item.mediaType}');
      if (item.mediaType == 'tv') {
        q.write('&season=${season ?? 1}&episode=${episode ?? 1}');
      }
      context.go('/watch/${item.tmdbId}?$q');
    }

    final playLabel = resume != null
        ? 'Riprendi'
        : (item.mediaType == 'tv' ? 'Riproduci' : 'Riproduci');

    final play = HeroCtaButton.primary(
      label: canPlay ? playLabel : 'Non disponibile',
      icon: Icons.play_arrow_rounded,
      onTap: canPlay ? goToWatch : null,
    );
    final add = HeroCtaButton.glass(
      label: isFav ? 'Nella lista' : 'La mia lista',
      icon: isFav ? Icons.check_rounded : Icons.add_rounded,
      active: isFav,
      onTap: () => ref.read(favoritesProvider.notifier).toggle(key),
    );
    final share = _ShareCircle(onTap: onShare);

    return LayoutBuilder(
      builder: (context, c) {
        final w = ((c.maxWidth - 10 - 48) / 2).clamp(0.0, 180.0);
        return Row(
          mainAxisAlignment:
              isPhone ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            SizedBox(width: w, child: play),
            const SizedBox(width: 10),
            SizedBox(width: w, child: add),
            const SizedBox(width: 10),
            share,
          ],
        );
      },
    );
  }
}

class _ShareCircle extends StatelessWidget {
  const _ShareCircle({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Info ─────────────────────────────────────────────────────────────────

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.item});
  final CatalogItemResponse item;

  @override
  Widget build(BuildContext context) {
    if (item.genres.isEmpty && item.originalTitle == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Info', style: StreamloadTypography.v3SectionHeader()),
        const SizedBox(height: 14),
        if (item.genres.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in item.genres)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: StreamloadColors.v3SurfaceGlass,
                    borderRadius: BorderRadius.circular(999),
                    border:
                        Border.all(color: StreamloadColors.v3BorderGlass),
                  ),
                  child: Text(
                    g,
                    style: StreamloadTypography.v3Body(fontSize: 13),
                  ),
                ),
            ],
          ),
        if (item.originalTitle != null &&
            item.originalTitle!.isNotEmpty &&
            item.originalTitle != item.title) ...[
          const SizedBox(height: 14),
          Text(
            'Titolo originale: ${item.originalTitle}',
            style: StreamloadTypography.v3MetaMono(
              fontSize: 12,
              color: StreamloadColors.v3TextMuted,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Cast ─────────────────────────────────────────────────────────────────

class _CastSection extends ConsumerWidget {
  const _CastSection({required this.item});
  final CatalogItemResponse item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      creditsProvider(TmdbKey(tmdbId: item.tmdbId, mediaType: item.mediaType)),
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
