// lib/presentation/widgets/title_actions_sheet.dart
//
// Long-press quick actions for ANY title card: open, toggle "La mia lista",
// and (when the title is in "Continua a guardare") remove it from that row.
// Presented as a bottom sheet so it works the same everywhere a PosterCard
// appears.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/media_summary.dart';
import '../../state/api_client_provider.dart';
import '../../state/continue_watching_provider.dart';
import '../../state/favorites_provider.dart';
import '../../state/title_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Opens the long-press action sheet for [summary].
Future<void> showTitleActions(BuildContext context, MediaSummary summary) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: StreamloadColors.v3PopoverBg,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
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

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Text(
              summary.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StreamloadTypography.display(fontSize: 20, italic: false)
                  .copyWith(color: StreamloadColors.v3TextPrimary),
            ),
          ),
          _ActionTile(
            icon: Icons.open_in_full_rounded,
            label: 'Apri',
            onTap: () {
              Navigator.of(context).pop();
              context.push(
                '/title/${summary.tmdbId}?media_type=${summary.mediaType}',
              );
            },
          ),
          _ActionTile(
            icon: isFav ? Icons.check_rounded : Icons.add_rounded,
            label: isFav ? 'Togli da La mia lista' : 'Aggiungi a La mia lista',
            accent: isFav,
            onTap: () {
              ref.read(favoritesProvider.notifier).toggle(key);
              Navigator.of(context).pop();
            },
          ),
          if (inContinue)
            _ActionTile(
              icon: Icons.remove_circle_outline_rounded,
              label: 'Rimuovi da Continua a guardare',
              destructive: true,
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
    this.destructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? const Color(0xFFE5677A)
        : accent
            ? StreamloadColors.accent
            : StreamloadColors.v3TextPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: StreamloadTypography.v3Body(fontSize: 15).copyWith(
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
