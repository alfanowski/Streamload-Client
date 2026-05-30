// lib/presentation/pages/title_page.dart
//
// Title page — a full-screen, Netflix-style MODAL that slides up over the app.
// The hero behaves like the Home's: pulling DOWN at the top stretches/zooms it
// (SliverAppBar stretch), and pulling past a threshold closes the panel. A
// native Liquid Glass ✕ also closes it. It reads like a standalone page.
//
// Content (Home's premium style): a cinematic hero (official title logo or
// big serif title + clean meta) with glass CTAs (Riproduci + La mia lista),
// then Trama (expandable), Cast (bigger avatars), Info, Episodi (TV) and
// Titoli simili.
import 'package:flutter/material.dart';
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
import '../widgets/primitives/glass_surface.dart';
import '../widgets/title/season_episodes.dart';
import '../widgets/title/similar_grid.dart';

class TitlePage extends ConsumerWidget {
  const TitlePage({
    super.key,
    required this.tmdbId,
    required this.mediaType,
    this.heroTag,
  });

  final int tmdbId;
  final String mediaType;

  /// Shared-element tag of the poster the user tapped — the hero animates
  /// open FROM that poster (and back to it on close). Null → plain fade.
  final Object? heroTag;

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
// Dismissible modal shell — pull the hero down past a threshold, or tap ✕.
// ──────────────────────────────────────────────────────────────────────────

class _TitleModal extends StatefulWidget {
  const _TitleModal({required this.child});
  final Widget child;

  @override
  State<_TitleModal> createState() => _TitleModalState();
}

class _TitleModalState extends State<_TitleModal> {
  bool _dismissing = false;
  static const double _closeThreshold = 130;

  void _dismiss() {
    if (_dismissing) return;
    _dismissing = true;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
  }

  bool _onScroll(ScrollNotification n) {
    // Overscroll at the very top (pixels below the min extent) → the hero
    // zooms via the SliverAppBar; pulling past the threshold closes the panel.
    if (n is ScrollUpdateNotification || n is OverscrollNotification) {
      final pull = n.metrics.minScrollExtent - n.metrics.pixels;
      if (pull > _closeThreshold && !_dismissing) _dismiss();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: widget.child,
              ),
            ),
            // Native iOS Liquid Glass close button.
            Positioned(
              top: topPad + 8,
              right: 14,
              child: _GlassClose(onTap: _dismiss),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassClose extends StatelessWidget {
  const _GlassClose({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const GlassSurface(
        capsule: true,
        borderRadius: 19,
        blur: 14,
        thickness: 14,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(Icons.close_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Content — CustomScrollView with a stretchy SliverAppBar hero.
// ──────────────────────────────────────────────────────────────────────────

class _TitleContent extends StatelessWidget {
  const _TitleContent({required this.item});
  final CatalogItemResponse item;

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final pad = isPhone
        ? StreamloadSpacing.pagePaddingPhone
        : StreamloadSpacing.pagePaddingDesktop;
    final heroHeight = MediaQuery.sizeOf(context).height * (isPhone ? 0.6 : 0.7);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          expandedHeight: heroHeight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          collapsedHeight: 0,
          pinned: false,
          floating: false,
          stretch: true,
          stretchTriggerOffset: 40,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: _TitleHeroSection(item: item),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 16),
            // Trama — justified body, no header.
            if ((item.overview ?? '').isNotEmpty)
              Padding(padding: pad, child: _ExpandableText(item.overview!)),
            const SizedBox(height: 28),
            _CastSection(item: item),
            const SizedBox(height: 28),
            Padding(padding: pad, child: _InfoBlock(item: item)),
            const SizedBox(height: 30),
            // TV → Episodi / Simili tabs; Movie → Titoli simili grid at the
            // bottom (no tab).
            Padding(
              padding: pad,
              child: item.mediaType == 'tv'
                  ? _TvTabs(item: item)
                  : SimilarGrid(
                      tmdbId: item.tmdbId,
                      mediaType: item.mediaType,
                      showHeader: true,
                    ),
            ),
            const SizedBox(height: 56),
          ]),
        ),
      ],
    );
  }
}

// ── Shared bits ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: StreamloadTypography.display(fontSize: 22, italic: false)
          .copyWith(color: StreamloadColors.v3TextPrimary),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText(this.text);
  final String text;
  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final style =
        StreamloadTypography.v3Body(fontSize: 16).copyWith(height: 1.6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Text(
            widget.text,
            style: style,
            textAlign: TextAlign.justify,
            maxLines: _expanded ? null : 5,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Text(
            _expanded ? 'Riduci' : 'Altro',
            style: StreamloadTypography.v3Body(
              fontSize: 14,
              color: StreamloadColors.v3TextSecondary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ── Hero ───────────────────────────────────────────────────────────────────

class _TitleHeroSection extends ConsumerWidget {
  const _TitleHeroSection({required this.item});
  final CatalogItemResponse item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPhone = Responsive.isPhone(context);
    final isTablet = Responsive.isTablet(context);
    final hPad = isPhone ? 16.0 : 64.0;
    final logoUrl = ref
        .watch(titleLogoProvider(
          TmdbKey(tmdbId: item.tmdbId, mediaType: item.mediaType),
        ))
        .maybeWhen(data: (u) => u, orElse: () => null);

    final titleSize = isPhone ? 40.0 : (isTablet ? 52.0 : 64.0);
    // TMDB logos vary wildly in aspect ratio. Keep the HEIGHT modest so most
    // are height-bound (→ render at the same height = consistent), and cap the
    // WIDTH so a wide one can't blow out. Same discipline as the Home hero.
    final logoMaxH = isPhone ? 54.0 : (isTablet ? 70.0 : 86.0);
    final logoMaxW = isPhone ? 280.0 : (isTablet ? 400.0 : 500.0);

    final Widget titleVisual = (logoUrl != null && logoUrl.isNotEmpty)
        ? LayoutBuilder(
            builder: (context, c) {
              final boxW = (c.maxWidth.isFinite ? c.maxWidth : logoMaxW)
                  .clamp(0.0, logoMaxW);
              return SizedBox(
                width: boxW,
                height: logoMaxH,
                child: Image.network(
                  logoUrl,
                  fit: BoxFit.contain,
                  alignment: isPhone
                      ? Alignment.bottomCenter
                      : Alignment.bottomLeft,
                  errorBuilder: (_, __, ___) => _titleText(titleSize, isPhone),
                ),
              );
            },
          )
        : _titleText(titleSize, isPhone);

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
                constraints: BoxConstraints(maxWidth: isPhone ? 540 : 780),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isPhone
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    titleVisual,
                    const SizedBox(height: 14),
                    _MetaLine(item: item, isPhone: isPhone),
                    const SizedBox(height: 22),
                    _HeroCtas(item: item, isPhone: isPhone),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _titleText(double size, bool isPhone) {
    return Text(
      item.title,
      textAlign: isPhone ? TextAlign.center : TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: StreamloadTypography.v3DisplayHero().copyWith(fontSize: size),
    );
  }
}

/// Clean meta line: a rating badge + dot-separated facts, in body type (no
/// mono). Reads as editorial metadata, not code.
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.item, required this.isPhone});
  final CatalogItemResponse item;
  final bool isPhone;

  @override
  Widget build(BuildContext context) {
    final facts = <String>[item.mediaType == 'tv' ? 'Serie TV' : 'Film'];
    if (item.year != null) facts.add('${item.year}');
    if (item.mediaType == 'tv' && item.seasonsCount != null) {
      facts.add(item.seasonsCount == 1
          ? '1 stagione'
          : '${item.seasonsCount} stagioni');
    } else if (item.mediaType == 'movie' && item.runtimeMinutes != null) {
      facts.add(_fmtRuntime(item.runtimeMinutes!));
    }

    final style = StreamloadTypography.v3Body(
      fontSize: 13,
      color: StreamloadColors.v3TextSecondary,
    ).copyWith(fontWeight: FontWeight.w500);

    return Wrap(
      alignment: isPhone ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        if (item.rating != null) _RatingBadge(rating: item.rating!),
        for (var i = 0; i < facts.length; i++) ...[
          if (i > 0 || item.rating != null)
            Text('·', style: style.copyWith(
              color: StreamloadColors.v3TextMuted,
            )),
          Text(facts[i], style: style),
        ],
      ],
    );
  }

  static String _fmtRuntime(int min) {
    final h = min ~/ 60;
    final m = min % 60;
    if (h == 0) return '${m}min';
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});
  final double rating;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: StreamloadColors.accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded,
              color: StreamloadColors.accent, size: 14),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: StreamloadTypography.v3Body(
              fontSize: 12.5,
              color: StreamloadColors.accent,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HeroCtas extends ConsumerWidget {
  const _HeroCtas({required this.item, required this.isPhone});
  final CatalogItemResponse item;
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

    final play = HeroCtaButton.primary(
      label: canPlay ? (resume != null ? 'Riprendi' : 'Riproduci') : 'Non disponibile',
      icon: Icons.play_arrow_rounded,
      onTap: canPlay ? goToWatch : null,
    );
    final add = HeroCtaButton.glass(
      label: isFav ? 'Nella lista' : 'La mia lista',
      icon: isFav ? Icons.check_rounded : Icons.add_rounded,
      active: isFav,
      onTap: () => ref.read(favoritesProvider.notifier).toggle(key),
    );

    return LayoutBuilder(
      builder: (context, c) {
        final w = ((c.maxWidth - 12) / 2).clamp(0.0, 190.0);
        return Row(
          mainAxisAlignment:
              isPhone ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            SizedBox(width: w, child: play),
            const SizedBox(width: 12),
            SizedBox(width: w, child: add),
          ],
        );
      },
    );
  }
}

// ── Info ─────────────────────────────────────────────────────────────────

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.item});
  final CatalogItemResponse item;

  @override
  Widget build(BuildContext context) {
    final hasOriginal = item.originalTitle != null &&
        item.originalTitle!.isNotEmpty &&
        item.originalTitle != item.title;
    if (item.genres.isEmpty && !hasOriginal) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Info'),
        const SizedBox(height: 16),
        if (item.genres.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in item.genres)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: StreamloadColors.v3SurfaceGlass,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: StreamloadColors.v3BorderGlass),
                  ),
                  child: Text(g,
                      style: StreamloadTypography.v3Body(fontSize: 13)),
                ),
            ],
          ),
        if (hasOriginal) ...[
          const SizedBox(height: 16),
          Text(
            'Titolo originale',
            style: StreamloadTypography.v3Body(
              fontSize: 12.5,
              color: StreamloadColors.v3TextMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.originalTitle!,
            style: StreamloadTypography.v3Body(fontSize: 15)
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }
}

// ── TV tabs (Episodi / Simili) ─────────────────────────────────────────────

class _TvTabs extends StatefulWidget {
  const _TvTabs({required this.item});
  final CatalogItemResponse item;
  @override
  State<_TvTabs> createState() => _TvTabsState();
}

class _TvTabsState extends State<_TvTabs> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SegmentedControl(
          labels: const ['Episodi', 'Simili'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 22),
        if (_tab == 0)
          SeasonEpisodes(tmdbId: widget.item.tmdbId)
        else
          SimilarGrid(
            tmdbId: widget.item.tmdbId,
            mediaType: widget.item.mediaType,
          ),
      ],
    );
  }
}

/// iOS-style segmented control — a pill with an animated selected segment.
class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.labels,
    required this.index,
    required this.onChanged,
  });
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final n = labels.length;
        final segW = (c.maxWidth - 8) / n;
        return Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: StreamloadColors.v3SurfaceGlass,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: StreamloadColors.v3BorderGlass),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment(n == 1 ? 0 : (index / (n - 1)) * 2 - 1, 0),
                child: Container(
                  width: segW,
                  height: 36,
                  decoration: BoxDecoration(
                    color: StreamloadColors.v3SurfaceGlassMax,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: StreamloadColors.v3BorderGlass),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < n; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: Center(
                          child: Text(
                            labels[i],
                            style: StreamloadTypography.v3Body(fontSize: 14)
                                .copyWith(
                              fontWeight: i == index
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: i == index
                                  ? StreamloadColors.v3TextPrimary
                                  : StreamloadColors.v3TextSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
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
