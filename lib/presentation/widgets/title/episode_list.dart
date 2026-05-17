// lib/presentation/widgets/title/episode_list.dart
//
// Episode list for the v3 Title page (Phase E3 of sub-plan 8).
// TV-only — for movies, the parent layouts skip rendering this widget.
//
// Layout (top to bottom):
//   - Section header: "EPISODI · S{n}" mono label
//   - Season picker: horizontal chips with PressFeedback. Active chip
//     uses v3CtaPrimaryBg + dark text; inactive uses v3SurfaceGlass +
//     white text. Animates background on toggle (180ms).
//   - Episode rows: ListView.separated, each row is
//     [BackdropCard thumb] · [number bold] · [title] · [duration mono]
//     · [chevron]. Thumb width is breakpoint-aware:
//        phone   64x36
//        tablet  96x54
//        desktop 96x54
//     Tap navigates to /watch/<tmdbId>?media_type=tv&season=N&episode=M.
//
// Loading: small spinner centered.
// Error: short red-tinted text + Retry pill (rare path; backend caches
// episodes so we rarely refetch).
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/episodes_response.dart';
import '../../../state/episodes_provider.dart';
import '../../../state/plugin_access_provider.dart';
import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../press_feedback.dart';

class EpisodeList extends ConsumerStatefulWidget {
  const EpisodeList({super.key, required this.tmdbId});

  final int tmdbId;

  @override
  ConsumerState<EpisodeList> createState() => _EpisodeListState();
}

class _EpisodeListState extends ConsumerState<EpisodeList> {
  int _seasonIdx = 0;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(episodesProvider(widget.tmdbId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Errore episodi: $e',
          style: StreamloadTypography.v3Body(
            color: StreamloadColors.v3TextSecondary,
          ),
        ),
      ),
      data: (resp) {
        if (resp.seasons.isEmpty) return const SizedBox.shrink();
        final clampedIdx = _seasonIdx.clamp(0, resp.seasons.length - 1);
        final season = resp.seasons[clampedIdx];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EPISODI · S${season.number}',
              style: StreamloadTypography.v3LabelMono(),
            ),
            const SizedBox(height: 12),
            _SeasonPicker(
              seasons: resp.seasons,
              activeIdx: clampedIdx,
              onPick: (i) => setState(() => _seasonIdx = i),
            ),
            const SizedBox(height: 16),
            _EpisodesColumn(
              tmdbId: widget.tmdbId,
              season: season,
            ),
          ],
        );
      },
    );
  }
}

class _SeasonPicker extends StatelessWidget {
  const _SeasonPicker({
    required this.seasons,
    required this.activeIdx,
    required this.onPick,
  });
  final List<SeasonInfo> seasons;
  final int activeIdx;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: seasons.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: StreamloadSpacing.cardGap),
        itemBuilder: (context, i) {
          final isActive = i == activeIdx;
          return PressFeedback(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isActive
                    ? StreamloadColors.v3CtaPrimaryBg
                    : StreamloadColors.v3SurfaceGlass,
                borderRadius:
                    BorderRadius.circular(StreamloadSpacing.chipRadius),
                border: Border.all(
                  color: isActive
                      ? Colors.transparent
                      : StreamloadColors.v3BorderGlass,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(StreamloadSpacing.chipRadius),
                  onTap: () => onPick(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Text(
                      'Stagione ${seasons[i].number}',
                      style: StreamloadTypography.v3CtaLabel(
                        color: isActive
                            ? StreamloadColors.v3CtaPrimaryFg
                            : StreamloadColors.v3TextPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EpisodesColumn extends ConsumerWidget {
  const _EpisodesColumn({required this.tmdbId, required this.season});
  final int tmdbId;
  final SeasonInfo season;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(pluginAccessProvider);
    final thumbWidth = Responsive.isPhone(context) ? 64.0 : 96.0;
    final thumbHeight = thumbWidth * 9 / 16;
    if (season.episodes.isEmpty) {
      return Text(
        'Nessun episodio per questa stagione.',
        style: StreamloadTypography.v3Body(
          color: StreamloadColors.v3TextMuted,
        ),
      );
    }
    return ListView.separated(
      // Embedded inside the page's outer ListView — shrinkWrap + no
      // physics so it lays out inline.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: season.episodes.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 0.5,
        color: StreamloadColors.v3BorderGlass,
      ),
      itemBuilder: (context, i) {
        final ep = season.episodes[i];
        return _EpisodeRow(
          tmdbId: tmdbId,
          seasonNumber: season.number,
          episode: ep,
          thumbWidth: thumbWidth,
          thumbHeight: thumbHeight,
          enabled: access == PluginAccess.available,
        );
      },
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({
    required this.tmdbId,
    required this.seasonNumber,
    required this.episode,
    required this.thumbWidth,
    required this.thumbHeight,
    required this.enabled,
  });

  final int tmdbId;
  final int seasonNumber;
  final EpisodeInfo episode;
  final double thumbWidth;
  final double thumbHeight;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () => context.go(
                  '/watch/$tmdbId?media_type=tv'
                  '&season=$seasonNumber&episode=${episode.episode}',
                )
            : null,
        // CM-6: roomier episode rows — 20 px vertical padding (was 10)
        // so the list breathes like a magazine table of contents.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Thumb(
                imageUrl: episode.stillUrl,
                width: thumbWidth,
                height: thumbHeight,
              ),
              const SizedBox(width: 16),
              // Episode number — keep mono so it reads as data, not as
              // a tiny editorial display.
              Text(
                '${episode.episode}',
                style: StreamloadTypography.v3MetaMono().copyWith(
                  fontSize: 13,
                  color: StreamloadColors.v3TextSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                // CM-6: title is Fraunces italic 18 — editorial, in line
                // with row headers + small card titles.
                child: Text(
                  episode.title ?? 'Episodio ${episode.episode}',
                  style: StreamloadTypography.display(
                    fontSize: 18,
                    italic: true,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (episode.runtimeMinutes != null) ...[
                const SizedBox(width: 16),
                Text(
                  '${episode.runtimeMinutes} min',
                  style: StreamloadTypography.v3MetaMono(),
                ),
              ],
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: enabled
                    ? StreamloadColors.v3TextSecondary
                    : StreamloadColors.v3TextMuted,
              ),
            ],
          ),
        ),
      ),
    );
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: enabled ? PressFeedback(child: row) : row,
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.imageUrl,
    required this.width,
    required this.height,
  });
  final String? imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => Container(
          width: width,
          height: height,
          color: StreamloadColors.v3SurfaceGlass,
          alignment: Alignment.center,
          child: Icon(
            Icons.play_arrow,
            size: 16,
            color: StreamloadColors.v3TextMuted,
          ),
        );
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
      child: (url == null || url.isEmpty)
          ? placeholder()
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (_, __) => placeholder(),
              errorWidget: (_, __, ___) => placeholder(),
            ),
    );
  }
}
