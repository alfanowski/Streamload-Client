// lib/presentation/widgets/title_actions_sheet.dart
//
// Long-press quick actions for ANY title card: open, toggle "La mia lista",
// and (when in "Continua a guardare") remove it from that row. Rendered with
// the SAME native Liquid Glass as the navbar (GlassSurface), with a fixed dark
// backdrop so it stays reliably dark. The header shows the official TITLE LOGO
// (metadata); its box is a FIXED height so the logo loading mid-open doesn't
// make the title jump.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/media_summary.dart';
import '../../state/api_client_provider.dart';
import '../../state/continue_watching_provider.dart';
import '../../state/favorites_provider.dart';
import '../../state/home_rows_provider.dart' show TmdbKey, titleLogoProvider;
import '../../state/title_provider.dart';
import '../theme/typography.dart';
import 'primitives/glass_surface.dart';

/// Opens the long-press action sheet for [summary].
Future<void> showTitleActions(BuildContext context, MediaSummary summary) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => _TitleActionsSheet(summary: summary),
  );
}

class _TitleActionsSheet extends ConsumerWidget {
  const _TitleActionsSheet({required this.summary});
  final MediaSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = TitleKey(tmdbId: summary.tmdbId, mediaType: summary.mediaType);
    final isFav = ref.watch(favoritesProvider).maybeWhen(
          data: (set) => set.contains(key),
          orElse: () => false,
        );
    final inContinue = ref.watch(continueWatchingProvider).maybeWhen(
          data: (items) => items.any((i) =>
              i.tmdbId == summary.tmdbId && i.mediaType == summary.mediaType),
          orElse: () => false,
        );
    final logoAsync = ref.watch(titleLogoProvider(
      TmdbKey(tmdbId: summary.tmdbId, mediaType: summary.mediaType),
    ));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: GlassSurface(
          borderRadius: 30,
          blur: 22,
          thickness: 18,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(summary: summary, logoAsync: logoAsync),
                const _GlassDivider(),
                _ActionRow(
                  icon: Icons.open_in_full_rounded,
                  label: 'Apri',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(
                      '/title/${summary.tmdbId}'
                      '?media_type=${summary.mediaType}',
                    );
                  },
                ),
                _ActionRow(
                  icon: isFav ? Icons.check_rounded : Icons.add_rounded,
                  label: isFav
                      ? 'Togli da La mia lista'
                      : 'Aggiungi a La mia lista',
                  onTap: () {
                    ref.read(favoritesProvider.notifier).toggle(key);
                    Navigator.of(context).pop();
                  },
                ),
                if (inContinue)
                  _ActionRow(
                    icon: Icons.remove_circle_outline_rounded,
                    label: 'Rimuovi da Continua a guardare',
                    tint: const Color(0xFFE5677A),
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        final api = await ref.read(progressApiProvider.future);
                        await api.removeContinueWatching(
                            summary.tmdbId, summary.mediaType);
                      } finally {
                        ref.invalidate(continueWatchingProvider);
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.summary, required this.logoAsync});
  final MediaSummary summary;
  final AsyncValue<String?> logoAsync;

  @override
  Widget build(BuildContext context) {
    final url = logoAsync.valueOrNull;
    final fallback = Text(
      summary.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: StreamloadTypography.v3DisplayHero().copyWith(fontSize: 22),
    );

    Widget content;
    if (url != null && url.isNotEmpty) {
      content = Image.network(
        url,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        // Fade the logo in once decoded so it never pops mid-open.
        frameBuilder: (_, child, frame, __) => AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 180),
          child: child,
        ),
        errorBuilder: (_, __, ___) => fallback,
      );
    } else if (logoAsync.isLoading) {
      // Still resolving — keep the (fixed-height) box empty rather than flash
      // the text title and then swap to the logo (that swap was the "scatto").
      content = const SizedBox.shrink();
    } else {
      content = fallback;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      // Fixed height → the loading→logo / loading→text swap never changes the
      // header's size, so nothing jumps while the sheet is animating in.
      child: SizedBox(
        height: 40,
        child: Align(alignment: Alignment.centerLeft, child: content),
      ),
    );
  }
}

class _GlassDivider extends StatelessWidget {
  const _GlassDivider();
  @override
  Widget build(BuildContext context) => Container(
        height: 0.5,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white.withValues(alpha: 0.14),
      );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? Colors.white;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: StreamloadTypography.v3Body(fontSize: 15.5)
                    .copyWith(color: color, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
