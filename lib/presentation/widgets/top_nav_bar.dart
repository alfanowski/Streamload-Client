// lib/presentation/widgets/top_nav_bar.dart
//
// Desktop / tablet top navigation bar — "Cinematic Premium" refactor v2
// (2026-05-30). Flat editorial disposition (NOT a segmented pill, which the
// operator found ugly): wordmark left · section tabs in a row · search pill
// + avatar right. The bar sits on a liquid-glass surface (shader on
// Impeller macOS, fallback in tests). The active tab gets a smoothly
// animated amber underline + a colour cross-fade on section change.
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
      blur: scrolled ? 18 : 10,
      thickness: 10,
      tint: StreamloadTokens.bg.withValues(alpha: scrolled ? 0.66 : 0.30),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              children: [
                const _Wordmark(),
                const SizedBox(width: 36),
                // Tabs in a flexible scroll region so they never overflow on
                // narrow tablet widths; search + avatar stay pinned right.
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final t in _tabs)
                          _NavTab(
                            label: t.label,
                            path: t.path,
                            active: _isActive(currentLoc, t.path),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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

  static bool _isActive(String currentLoc, String tabPath) {
    if (currentLoc == tabPath) return true;
    if (tabPath == '/home' && currentLoc == '/') return true;
    return false;
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Streamload',
      style: StreamloadTypography.display(fontSize: 20, italic: true)
          .copyWith(letterSpacing: -0.3, color: StreamloadTokens.textPrimary),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({required this.label, required this.path, required this.active});

  final String label;
  final String path;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(path),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: StreamloadTokens.hover,
              curve: StreamloadTokens.standardCurve,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active
                    ? StreamloadTokens.textPrimary
                    : StreamloadTokens.textSecondary,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 6),
            // Smoothly animated amber underline: grows in under the active
            // tab and shrinks out of the previous one — a soft slide-handoff.
            AnimatedContainer(
              duration: StreamloadTokens.page,
              curve: StreamloadTokens.standardCurve,
              height: 2,
              width: active ? 22 : 0,
              decoration: BoxDecoration(
                color: StreamloadTokens.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
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
