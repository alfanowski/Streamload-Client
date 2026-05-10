// lib/presentation/pages/title_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/catalog_item.dart';
import '../../state/episodes_provider.dart';
import '../../state/plugin_access_provider.dart';
import '../../state/title_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/eyebrow.dart';
import '../widgets/primary_button.dart';

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
      appBar: AppBar(),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (item) {
          if (item.mediaType == 'tv') {
            return _TitleTvBody(tmdbId: tmdbId, item: item);
          }
          return _TitleMovieBody(tmdbId: tmdbId, item: item);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared metadata header — poster + title + year + overview
// ---------------------------------------------------------------------------

class _TitleHeader extends StatelessWidget {
  const _TitleHeader({required this.item});

  final CatalogItemResponse item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.posterUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.posterUrl!,
              height: 240,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: StreamloadColors.surface2, height: 240),
              errorWidget: (_, __, ___) =>
                  Container(color: StreamloadColors.surface2, height: 240),
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Eyebrow('Titolo'),
        const SizedBox(height: 8),
        Text(
          item.title,
          style: StreamloadTypography.display(fontSize: 36),
        ),
        if (item.year != null) ...[
          const SizedBox(height: 4),
          Text(
            '${item.year}',
            style: StreamloadTypography.mono(fontSize: 12),
          ),
        ],
        if (item.overview != null) ...[
          const SizedBox(height: 16),
          Text(item.overview!),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Movie variant — header + Watch button
// ---------------------------------------------------------------------------

class _TitleMovieBody extends ConsumerWidget {
  const _TitleMovieBody({required this.tmdbId, required this.item});

  final int tmdbId;
  final CatalogItemResponse item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(pluginAccessProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TitleHeader(item: item),
            const SizedBox(height: 24),
            if (access == PluginAccess.available)
              PrimaryButton(
                label: 'Guarda',
                onPressed: () => context.go(
                  '/watch/$tmdbId?media_type=${item.mediaType}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TV variant — header + Watch button + SeasonPicker (ChoiceChips) + episode list
// ---------------------------------------------------------------------------

class _TitleTvBody extends ConsumerStatefulWidget {
  const _TitleTvBody({required this.tmdbId, required this.item});

  final int tmdbId;
  final CatalogItemResponse item;

  @override
  ConsumerState<_TitleTvBody> createState() => _TitleTvBodyState();
}

class _TitleTvBodyState extends ConsumerState<_TitleTvBody> {
  int _seasonIdx = 0;

  @override
  Widget build(BuildContext context) {
    final ep = ref.watch(episodesProvider(widget.tmdbId));
    final access = ref.watch(pluginAccessProvider);
    return ep.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Errore episodi: $e')),
      data: (resp) {
        if (resp.seasons.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _TitleHeader(item: widget.item),
              const SizedBox(height: 24),
              if (access == PluginAccess.available)
                PrimaryButton(
                  label: 'Guarda',
                  onPressed: () => context.go(
                    '/watch/${widget.tmdbId}?media_type=tv',
                  ),
                ),
              const SizedBox(height: 24),
              const Center(child: Text('Nessuna stagione disponibile.')),
            ],
          );
        }

        final clampedIdx = _seasonIdx.clamp(0, resp.seasons.length - 1);
        final season = resp.seasons[clampedIdx];

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _TitleHeader(item: widget.item),
            const SizedBox(height: 24),
            if (access == PluginAccess.available)
              PrimaryButton(
                label: 'Guarda',
                onPressed: () => context.go(
                  '/watch/${widget.tmdbId}?media_type=tv',
                ),
              ),
            const SizedBox(height: 24),
            // Season picker
            Wrap(
              spacing: 8,
              children: List.generate(resp.seasons.length, (i) {
                final s = resp.seasons[i];
                return ChoiceChip(
                  label: Text(s.name ?? 'Stagione ${s.number}'),
                  selected: i == clampedIdx,
                  onSelected: (_) => setState(() => _seasonIdx = i),
                );
              }),
            ),
            const SizedBox(height: 16),
            // Episode list — tappable only when plugin access is available.
            for (final e in season.episodes)
              Opacity(
                opacity: access == PluginAccess.available ? 1.0 : 0.5,
                child: ListTile(
                  leading: e.stillUrl != null
                      ? SizedBox(
                          width: 96,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                e.stillUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : null,
                  title: Text('${e.episode}. ${e.title}'),
                  subtitle: e.overview != null
                      ? Text(
                          e.overview!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  onTap: access == PluginAccess.available
                      ? () => context.go(
                            '/watch/${widget.tmdbId}?media_type=tv'
                            '&season=${e.season}&episode=${e.episode}',
                          )
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}
