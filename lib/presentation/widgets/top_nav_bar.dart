// lib/presentation/widgets/top_nav_bar.dart
//
// Desktop / tablet top navigation bar — "Cinematic Premium" v3 (2026-05-30).
// Clean frosted-glass bar (BackdropFilter blur — NOT the shader, whose
// refraction rim read as an ugly outline on a full-width rectangle). One
// hairline under the bar; everything vertically centered.
//
// Layout (Apple TV+ / Netflix): wordmark + section tabs grouped LEFT,
// search pill + avatar pinned RIGHT. The active tab has a smoothly animated
// amber underline anchored to the bar's bottom edge (so it never shifts the
// label vertically).
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/nav_scrolled_provider.dart';
import '../responsive.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'avatar_menu.dart';
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

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: scrolled ? 24 : 14,
          sigmaY: scrolled ? 24 : 14,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: StreamloadTokens.bg
                .withValues(alpha: scrolled ? 0.72 : 0.32),
            border: Border(
              bottom: BorderSide(
                color: StreamloadTokens.border,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.only(left: 32, right: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _Wordmark(),
                    const SizedBox(width: 40),
                    // Tabs grouped left; the Expanded fills the gap so the
                    // search + avatar cluster pins to the right edge.
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
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
                    const SizedBox(width: 16),
                    const AvatarMenu(),
                  ],
                ),
              ),
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
      style: StreamloadTypography.display(fontSize: 21, italic: true)
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
      child: SizedBox(
        height: TopNavBar.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedDefaultTextStyle(
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
            ),
            // Underline anchored to the bottom edge — never shifts the label.
            Positioned(
              bottom: 0,
              child: AnimatedContainer(
                duration: StreamloadTokens.page,
                curve: StreamloadTokens.standardCurve,
                height: 2,
                width: active ? 22 : 0,
                decoration: const BoxDecoration(
                  color: StreamloadTokens.accent,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(2),
                  ),
                ),
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
