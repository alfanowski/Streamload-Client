// lib/presentation/widgets/top_nav_bar.dart
//
// Desktop / tablet top navigation bar — "Cinematic Premium" refactor
// (2026-05-29). A full-width liquid-glass bar floating over the hero:
//
//   [ Streamload ]      ( Home · Film · Serie · Anime · Lista )      ⌘K  (o)
//                         ^ centered segmented glass pill, active = cream
//
// The bar uses GlassSurface (real shader on mobile/macOS, BackdropFilter
// fallback elsewhere / in tests). The glass tint deepens once the page
// reports a scroll past ~80px (navScrolledProvider) so the chrome separates
// from the content as the user scrolls.
//
// Phone uses StreamloadBottomTabBar instead — this widget is desktop/tablet.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/nav_scrolled_provider.dart';
import '../responsive.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'avatar_menu.dart';
import 'primitives/glass_surface.dart';
import 'search_overlay.dart';

class TopNavBar extends ConsumerWidget {
  const TopNavBar({super.key});

  /// Logical height of the bar (pages pad their non-hero content by this).
  static const double height = 60;

  static const List<({String label, String path})> _tabs = [
    (label: 'Home', path: '/home'),
    (label: 'Film', path: '/film'),
    (label: 'Serie TV', path: '/serie'),
    (label: 'Anime', path: '/anime'),
    (label: 'La mia lista', path: '/list'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrolled = ref.watch(navScrolledProvider);
    final currentLoc = GoRouterState.of(context).matchedLocation;

    return GlassSurface(
      borderRadius: 0,
      blur: scrolled ? 16 : 10,
      thickness: 10,
      tint: StreamloadTokens.bg.withValues(alpha: scrolled ? 0.62 : 0.34),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const _Wordmark(),
                Expanded(
                  child: Center(
                    // Scale the pill down rather than overflow on narrow
                    // tablet widths.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _SegmentedTabs(
                        tabs: _tabs,
                        currentLoc: currentLoc,
                      ),
                    ),
                  ),
                ),
                _SearchPill(
                  onTap: () {
                    if (Responsive.isPhone(context)) {
                      context.go('/search');
                    } else {
                      SearchOverlay.show(context);
                    }
                  },
                ),
                const SizedBox(width: 14),
                const AvatarMenu(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    // Editorial Fraunces italic wordmark — the magazine voice in the chrome.
    return Text(
      'Streamload',
      style: StreamloadTypography.display(fontSize: 20, italic: true)
          .copyWith(letterSpacing: -0.3, color: StreamloadTokens.textPrimary),
    );
  }
}

/// Centered segmented capsule: a translucent rounded track holding the
/// section tabs. The active tab is a filled cream pill (Apple-style).
class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.tabs, required this.currentLoc});

  final List<({String label, String path})> tabs;
  final String currentLoc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: StreamloadTokens.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(StreamloadTokens.radiusPill),
        border: Border.all(color: StreamloadTokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final t in tabs)
            _SegTab(
              label: t.label,
              path: t.path,
              active: _isActive(currentLoc, t.path),
            ),
        ],
      ),
    );
  }

  static bool _isActive(String currentLoc, String tabPath) {
    if (currentLoc == tabPath) return true;
    if (tabPath == '/home' && currentLoc == '/') return true;
    return false;
  }
}

class _SegTab extends StatelessWidget {
  const _SegTab({required this.label, required this.path, required this.active});

  final String label;
  final String path;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(path),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: StreamloadTokens.hover,
        curve: StreamloadTokens.standardCurve,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? StreamloadTokens.ctaPrimaryBg : Colors.transparent,
          borderRadius: BorderRadius.circular(StreamloadTokens.radiusPill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active
                ? StreamloadTokens.ctaPrimaryFg
                : StreamloadTokens.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: StreamloadTokens.textPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(StreamloadTokens.radiusPill),
          border: Border.all(color: StreamloadTokens.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 17, color: StreamloadTokens.textSecondary),
            const SizedBox(width: 8),
            Text(
              '⌘K',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: StreamloadTokens.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
