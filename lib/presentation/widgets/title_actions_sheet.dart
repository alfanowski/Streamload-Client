// lib/presentation/widgets/title_actions_sheet.dart
//
// Long-press quick actions for ANY title card: open, toggle "La mia lista",
// and (when in "Continua a guardare") remove it from that row. Presented as a
// floating native Liquid Glass card so it's coherent with the rest of the
// platform's chrome. The header shows the official TITLE LOGO (metadata),
// falling back to the title text.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/media_summary.dart';
import '../../state/api_client_provider.dart';
import '../../state/continue_watching_provider.dart';
import '../../state/favorites_provider.dart';
import '../../state/home_rows_provider.dart' show TmdbKey, titleLogoProvider;
import '../../state/title_provider.dart';
import '../theme/colors.dart';
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
    final logoUrl = ref
        .watch(titleLogoProvider(
          TmdbKey(tmdbId: summary.tmdbId, mediaType: summary.mediaType),
        ))
        .maybeWhen(data: (u) => u, orElse: () => null);

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
                _Header(summary: summary, logoUrl: logoUrl),
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
                  label:
                      isFav ? 'Togli da La mia lista' : 'Aggiungi a La mia lista',
                  tint: isFav ? StreamloadColors.accent : null,
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
  const _Header({required this.summary, this.logoUrl});
  final MediaSummary summary;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Text(
      summary.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: StreamloadTypography.v3DisplayHero().copyWith(fontSize: 22),
    );
    final Widget title = (logoUrl != null && logoUrl!.isNotEmpty)
        ? SizedBox(
            height: 40,
            child: Image.network(
              logoUrl!,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorBuilder: (_, __, ___) => fallback,
            ),
          )
        : fallback;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      child: Align(alignment: Alignment.centerLeft, child: title),
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
