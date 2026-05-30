// lib/presentation/widgets/title/season_episodes.dart
//
// TV episodes — a "Stagione N ▾" button that opens a bottom-sheet season
// list, and a rich vertical episode list (thumbnail + number + title +
// duration + synopsis). Tapping an episode opens the player.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/episodes_response.dart';
import '../../../state/episodes_provider.dart';
import '../../../state/plugin_access_provider.dart';
import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../press_feedback.dart';

class SeasonEpisodes extends ConsumerStatefulWidget {
  const SeasonEpisodes({super.key, required this.tmdbId});
  final int tmdbId;

  @override
  ConsumerState<SeasonEpisodes> createState() => _SeasonEpisodesState();
}

class _SeasonEpisodesState extends ConsumerState<SeasonEpisodes> {
  int _seasonIdx = 0;

  Future<void> _openSheet(List<SeasonInfo> seasons, int active) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: StreamloadColors.v3PopoverBg,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'Stagioni',
                style: StreamloadTypography.display(fontSize: 20, italic: false)
                    .copyWith(color: StreamloadColors.v3TextPrimary),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: seasons.length,
                itemBuilder: (_, i) {
                  final sel = i == active;
                  return ListTile(
                    onTap: () => Navigator.of(ctx).pop(i),
                    title: Text(
                      'Stagione ${seasons[i].number}',
                      style: StreamloadTypography.v3Body(fontSize: 16).copyWith(
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: sel
                            ? StreamloadColors.v3TextPrimary
                            : StreamloadColors.v3TextSecondary,
                      ),
                    ),
                    trailing: sel
                        ? const Icon(Icons.check_rounded,
                            color: StreamloadColors.accent, size: 20)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _seasonIdx = picked);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(episodesProvider(widget.tmdbId));
    final enabled =
        ref.watch(pluginAccessProvider) == PluginAccess.available;
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('Errore episodi',
            style: StreamloadTypography.v3Body(
                color: StreamloadColors.v3TextMuted)),
      ),
      data: (resp) {
        if (resp.seasons.isEmpty) return const SizedBox.shrink();
        final idx = _seasonIdx.clamp(0, resp.seasons.length - 1);
        final season = resp.seasons[idx];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SeasonButton(
              label: 'Stagione ${season.number}',
              onTap: resp.seasons.length > 1
                  ? () => _openSheet(resp.seasons, idx)
                  : null,
            ),
            const SizedBox(height: 18),
            if (season.episodes.isEmpty)
              Text('Nessun episodio per questa stagione.',
                  style: StreamloadTypography.v3Body(
                      color: StreamloadColors.v3TextMuted))
            else
              for (final ep in season.episodes)
                _EpisodeTile(
                  tmdbId: widget.tmdbId,
                  seasonNumber: season.number,
                  episode: ep,
                  enabled: enabled,
                ),
          ],
        );
      },
    );
  }
}

class _SeasonButton extends StatelessWidget {
  const _SeasonButton({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressFeedback(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: StreamloadColors.v3SurfaceGlass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StreamloadColors.v3BorderGlass),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: StreamloadTypography.v3Body(fontSize: 15).copyWith(
                  fontWeight: FontWeight.w600,
                  color: StreamloadColors.v3TextPrimary,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: StreamloadColors.v3TextSecondary, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.tmdbId,
    required this.seasonNumber,
    required this.episode,
    required this.enabled,
  });

  final int tmdbId;
  final int seasonNumber;
  final EpisodeInfo episode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final thumbW = Responsive.isPhone(context) ? 116.0 : 150.0;
    final thumbH = thumbW * 9 / 16;
    final title = episode.title ?? 'Episodio ${episode.episode}';

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumb(url: episode.stillUrl, width: thumbW, height: thumbH),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${episode.episode}. $title',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StreamloadTypography.v3Body(fontSize: 15).copyWith(
                          fontWeight: FontWeight.w600,
                          color: StreamloadColors.v3TextPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (episode.runtimeMinutes != null) ...[
                      const SizedBox(width: 10),
                      Text(
                        '${episode.runtimeMinutes}min',
                        style: StreamloadTypography.v3Body(
                          fontSize: 12,
                          color: StreamloadColors.v3TextMuted,
                        ),
                      ),
                    ],
                  ],
                ),
                if ((episode.overview ?? '').isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    episode.overview!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: StreamloadTypography.v3Body(
                      fontSize: 13,
                      color: StreamloadColors.v3TextSecondary,
                    ).copyWith(height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: PressFeedback(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled
              ? () => context.go(
                    '/watch/$tmdbId?media_type=tv'
                    '&season=$seasonNumber&episode=${episode.episode}',
                  )
              : null,
          child: tile,
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.width, required this.height});
  final String? url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        height: height,
        child: url != null && url!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    ColoredBox(color: StreamloadColors.v3SurfaceGlass),
                errorWidget: (_, __, ___) => const _ThumbFallback(),
              )
            : const _ThumbFallback(),
      ),
    );
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: StreamloadColors.v3SurfaceGlass,
      child: Center(
        child: Icon(Icons.play_arrow_rounded,
            color: StreamloadColors.v3TextMuted, size: 26),
      ),
    );
  }
}
