// lib/presentation/widgets/search_overlay.dart
//
// v3 Netflix×AppleTV refactor — fullscreen search overlay
// (sub-plan 8, Phase G1).
//
// Used on desktop / tablet only (phone uses the dedicated /search page
// via the bottom tab). Opened via:
//   - top bar 🔍 button → SearchOverlay.show(context)
//   - Cmd+K shortcut wired in AppShell
//
// Layout:
//   - black 85% backdrop + 40px blur fills the screen
//   - centered input (~600px max) at 22px, autofocus, monospace placeholder
//     "Cerca un titolo…", no border, white caret. "Esc" hint top-right.
//   - debounced (200ms) live suggestions under the input: top 5 results
//     as rows (32×48 poster thumb + title + "Type · Year" meta line)
//   - "Mostra tutti i risultati →" row at the bottom whenever the query
//     has text — tap navigates to /search?q=<query>
//
// Dismissal:
//   - Esc key → pops the dialog
//   - tap outside the input/suggestions panel → pops
//   - tapping a suggestion → pops and context.go to title page
//
// 2026-05-17 (CM-2): the Pass 2B LiquidGlass pill input + BackdropFilter
// blur were dropped. The overlay is now a solid v3BgScrolled 95%
// backdrop with no blur, and the input is plain TextField on transparent
// with a hairline underline. Editorial — the search reads like a
// magazine search bar, not an iOS spotlight.
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/media_summary.dart';
import '../../domain/models/search_results.dart';
import '../../state/api_client_provider.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'press_feedback.dart';
import 'search/person_result_tile.dart';

/// Live search FutureProvider used by [SearchOverlay] (and reusable by
/// other call sites that want suggestion-style results). Hits the same
/// `/api/search` endpoint as [SearchController] but exposes a one-shot
/// future per (debounced) query so widgets can `ref.watch` it directly.
///
/// Empty / whitespace-only queries return an empty list without an API
/// call. Errors bubble up as AsyncError so the overlay can render a
/// gentle inline message instead of throwing.
final searchSuggestionsProvider =
    FutureProvider.autoDispose.family<SearchResults, String>(
  (ref, query) async {
    final q = query.trim();
    if (q.isEmpty) return const SearchResults();
    final api = await ref.watch(searchApiProvider.future);
    return api.search(q);
  },
);

class SearchOverlay extends ConsumerStatefulWidget {
  const SearchOverlay({super.key});

  /// Open the overlay on top of the current page. Returns when dismissed.
  /// Use this from the TopNavBar search button (desktop / tablet) and the
  /// Cmd+K shortcut wired into AppShell.
  static Future<void> show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerca',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) => const SearchOverlay(),
      transitionBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      ),
    );
  }

  @override
  ConsumerState<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<SearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  String _debouncedQuery = '';

  @override
  void initState() {
    super.initState();
    // Belt-and-braces autofocus: TextField(autofocus:true) usually wins,
    // but the overlay route's barrier sometimes steals focus first. A
    // post-frame request guarantees the caret lands in the input.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _debouncedQuery = value.trim());
    });
  }

  void _close() {
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  void _onSelectSuggestion(MediaSummary m) {
    _close();
    context.go('/title/${m.tmdbId}?media_type=${m.mediaType}');
  }

  void _onSelectPerson(SearchPersonResult p) {
    _close();
    context.go('/person/${p.tmdbId}');
  }

  void _onShowAll() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    _close();
    context.go('/search?q=${Uri.encodeQueryComponent(q)}');
  }

  void _onSubmit(String v) => _onShowAll();

  @override
  Widget build(BuildContext context) {
    final hasQuery = _debouncedQuery.isNotEmpty;
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: Focus(
        autofocus: true,
        // Material ancestor for the TextField + InkWell ripples inside
        // the suggestion rows. The dialog itself doesn't wrap us in a
        // Scaffold, so we provide our own transparent Material here.
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // Backdrop: tap-anywhere-to-close. CM-2 dropped the 40 px
              // BackdropFilter blur — the editorial pivot wants a clean
              // solid panel, not a softened iOS spotlight. v3BgScrolled
              // at 95 % alpha keeps the page glimpsing through the
              // bottom edge while the chrome reads as opaque.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _close,
                  child: Container(
                    color: StreamloadColors.v3BgScrolled
                        .withValues(alpha: 0.95),
                  ),
                ),
              ),
              // "Esc" hint pinned to the top-right.
              Positioned(
                top: 24,
                right: 28,
                child: _EscHint(onTap: _close),
              ),
              // Centered input + suggestions column. We swallow taps on this
              // surface so clicking the input area doesn't dismiss via the
              // backdrop GestureDetector underneath.
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 96),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        // Wrap in SingleChildScrollView so if the
                        // suggestions list grows beyond the viewport we
                        // scroll gracefully instead of overflowing the
                        // Column.
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SearchInput(
                                controller: _controller,
                                focusNode: _focusNode,
                                onChanged: _onChanged,
                                onSubmitted: _onSubmit,
                              ),
                              const SizedBox(height: 16),
                              if (hasQuery)
                                _SuggestionsList(
                                  query: _debouncedQuery,
                                  onSelect: _onSelectSuggestion,
                                  onSelectPerson: _onSelectPerson,
                                  onShowAll: _onShowAll,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    // CM-2 (2026-05-17): drop the LiquidGlass pill. The input is plain
    // TextField on transparent + a 1 px warm-off-white underline. The
    // leading search icon stays so the affordance still reads as a
    // search input on first glance.
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: StreamloadColors.v3BorderGlass,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: StreamloadColors.v3TextSecondary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                cursorColor: StreamloadColors.v3TextPrimary,
                cursorWidth: 1.5,
                textInputAction: TextInputAction.search,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: StreamloadTypography.display(
                  fontSize: 24,
                  italic: true,
                  color: StreamloadColors.v3TextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Cerca un titolo…',
                  hintStyle: StreamloadTypography.display(
                    fontSize: 24,
                    italic: true,
                    color: StreamloadColors.v3TextMuted,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  isCollapsed: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EscHint extends StatelessWidget {
  const _EscHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressFeedback(
      child: Material(
        color: StreamloadColors.v3SurfaceGlass,
        borderRadius: BorderRadius.circular(StreamloadSpacing.chipRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(StreamloadSpacing.chipRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              'Esc',
              style: StreamloadTypography.v3LabelMono(
                color: StreamloadColors.v3TextSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionsList extends ConsumerWidget {
  const _SuggestionsList({
    required this.query,
    required this.onSelect,
    required this.onSelectPerson,
    required this.onShowAll,
  });

  final String query;
  final ValueChanged<MediaSummary> onSelect;
  final ValueChanged<SearchPersonResult> onSelectPerson;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(searchSuggestionsProvider(query));
    return async.when(
      data: (results) {
        // PS-4: when an actor/director matches, surface the single most
        // relevant person (TMDB orders by relevance → people.first) at the
        // TOP, then a hairline divider, then the title suggestions. This
        // satisfies the operator's "l'attore come primo risultato, sotto
        // i film".
        final topPerson =
            results.people.isNotEmpty ? results.people.first : null;
        // Pass 2E (2026-05-17): the original 5-suggestion limit was a
        // hand-tuned guess from sub-plan 8 — operator wants the overlay
        // to feel as rich as Netflix's "did you mean" stack, so we bump
        // it to 8. Eight rows still fits comfortably above the fold on
        // a 13-inch laptop without scrolling the dialog.
        final top = results.titles.take(8).toList(growable: false);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (topPerson != null) ...[
              PersonResultTile(
                person: topPerson,
                onTap: () => onSelectPerson(topPerson),
              ),
              if (top.isNotEmpty)
                Divider(
                  height: 16,
                  thickness: 1,
                  color: StreamloadColors.v3BorderGlass,
                ),
            ],
            for (final m in top)
              _SuggestionRow(summary: m, onTap: () => onSelect(m)),
            _ShowAllRow(onTap: onShowAll),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Errore nella ricerca',
          style: StreamloadTypography.v3MetaMono(
            color: StreamloadColors.v3TextMuted,
          ),
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.summary, required this.onTap});
  final MediaSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typeLabel = _humanType(summary.mediaType);
    final yearLabel = summary.year?.toString();
    final meta = [typeLabel, if (yearLabel != null) yearLabel].join(' · ');
    return PressFeedback(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _Thumb(url: summary.posterUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StreamloadTypography.v3Body(
                          color: StreamloadColors.v3TextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StreamloadTypography.v3MetaMono(
                          color: StreamloadColors.v3TextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _humanType(String type) {
    switch (type) {
      case 'movie':
        return 'Film';
      case 'tv':
        return 'Serie TV';
      case 'anime':
        return 'Anime';
      default:
        return type;
    }
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    const w = 32.0;
    const h = 48.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: w,
        height: h,
        child: url != null
            ? CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: StreamloadColors.v3SurfaceGlass),
                errorWidget: (_, __, ___) => const _ThumbPlaceholder(),
              )
            : const _ThumbPlaceholder(),
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StreamloadColors.v3SurfaceGlass,
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_outlined,
        size: 14,
        color: StreamloadColors.v3TextMuted,
      ),
    );
  }
}

class _ShowAllRow extends StatelessWidget {
  const _ShowAllRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressFeedback(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              'Mostra tutti i risultati →',
              style: StreamloadTypography.v3Body(
                color: StreamloadColors.v3TextPrimary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
