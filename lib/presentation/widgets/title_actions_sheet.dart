// lib/presentation/widgets/title_actions_sheet.dart
//
// Long-press quick actions for ANY title card: open, toggle "La mia lista",
// and (when in "Continua a guardare") remove it from that row.
//
// A clean SOLID bottom sheet (no platform-view glass — that stuttered while
// animating). Dark rounded panel, a grabber, the official TITLE LOGO as the
// header (metadata, fixed-height so it never jumps), and tactile rows with an
// icon chip + label.
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

const Color _destructive = Color(0xFFE5677A);

/// Opens the long-press action sheet for [summary].
Future<void> showTitleActions(BuildContext context, MediaSummary summary) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: StreamloadColors.v3PopoverBg,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
    final logoAsync = ref.watch(titleLogoProvider(
      TmdbKey(tmdbId: summary.tmdbId, mediaType: summary.mediaType),
    ));

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 10, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(summary: summary, logoAsync: logoAsync),
            const SizedBox(height: 6),
            _ActionRow(
              icon: Icons.open_in_full_rounded,
              label: 'Apri',
              onTap: () {
                Navigator.of(context).pop();
                context.push(
                  '/title/${summary.tmdbId}?media_type=${summary.mediaType}',
                );
              },
            ),
            _ActionRow(
              icon: isFav ? Icons.check_rounded : Icons.add_rounded,
              label:
                  isFav ? 'Togli da La mia lista' : 'Aggiungi a La mia lista',
              onTap: () {
                ref.read(favoritesProvider.notifier).toggle(key);
                Navigator.of(context).pop();
              },
            ),
            if (inContinue)
              _ActionRow(
                icon: Icons.remove_circle_outline_rounded,
                label: 'Rimuovi da Continua a guardare',
                tint: _destructive,
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
      textAlign: TextAlign.center,
      style: StreamloadTypography.v3DisplayHero().copyWith(fontSize: 24),
    );

    Widget content;
    if (url != null && url.isNotEmpty) {
      content = Image.network(
        url,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        frameBuilder: (_, child, frame, __) => AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 180),
          child: child,
        ),
        errorBuilder: (_, __, ___) => fallback,
      );
    } else if (logoAsync.isLoading) {
      // Keep the fixed-height box empty while resolving rather than flash the
      // text and swap to the logo (that swap made the title "jump").
      content = const SizedBox.shrink();
    } else {
      content = fallback;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      child: SizedBox(
        height: 44,
        child: Align(alignment: Alignment.center, child: content),
      ),
    );
  }
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
    final destructive = tint != null;
    final fg = tint ?? StreamloadColors.v3TextPrimary;
    final chipBg = destructive
        ? _destructive.withValues(alpha: 0.14)
        : StreamloadColors.v3SurfaceGlass;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        enableFeedback: false,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StreamloadColors.v3BorderGlass),
                ),
                child: Icon(icon, color: fg, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: StreamloadTypography.v3Body(fontSize: 15.5).copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
