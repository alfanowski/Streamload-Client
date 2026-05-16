// lib/presentation/widgets/top_nav_bar.dart
//
// v3 Netflix×AppleTV refactor — desktop + tablet top navigation bar.
//
// Floats over page content (the AppShell stacks it above the body) and
// switches its background from glass + blur to solid bgScrolled once the
// active page reports that the user has scrolled past ~80px via
// navScrolledProvider. Pages own that listener — see HomePage / TitlePage
// body wiring in Phases D / E.
//
// Layout (left → right):
//   logo "STREAMLOAD" · Home · Film · Serie TV · Anime · La mia lista
//   · [spacer] · 🔍 · avatar
//
// Phone variant is the StreamloadBottomTabBar in bottom_tab_bar.dart — this
// widget is desktop / tablet only and is not used on phone.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/nav_scrolled_provider.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/typography.dart';
import 'avatar_menu.dart';

class TopNavBar extends ConsumerWidget {
  const TopNavBar({super.key});

  /// Logical height of the bar. The AppShell stacks the bar above the body,
  /// and pages that don't have a hero behind them should leave this much
  /// padding at the top of their content.
  static const double height = 56;

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
    final bg = scrolled
        ? StreamloadColors.v3BgScrolled
        : StreamloadColors.v3BgScrolled.withValues(alpha: 0.85);
    final currentLoc = GoRouterState.of(context).matchedLocation;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedContainer(
          duration: StreamloadMotion.navBarFade,
          decoration: BoxDecoration(color: bg),
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(builder: (context, constraints) {
              // Tighten horizontal padding + tab gap on narrow tablet widths
              // so the 5 tabs + logo + search + avatar still fit.
              final tight = constraints.maxWidth < 1000;
              final hPad = tight ? 16.0 : 28.0;
              final tabGap = tight ? 14.0 : 22.0;
              final logoGap = tight ? 16.0 : 28.0;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
                child: Row(
                  children: [
                    const _Logo(),
                    SizedBox(width: logoGap),
                    // Tabs in a flexible scrollable region — keeps the search
                    // + avatar pinned to the right edge even at the most
                    // compressed tablet widths, and gracefully scrolls if a
                    // localization pushes labels too wide.
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < _tabs.length; i++) ...[
                              _NavTab(
                                label: _tabs[i].label,
                                path: _tabs[i].path,
                                active: _isActive(
                                    currentLoc, _tabs[i].path),
                              ),
                              if (i < _tabs.length - 1)
                                SizedBox(width: tabGap),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SearchButton(onTap: () => context.go('/search')),
                    const SizedBox(width: 12),
                    const AvatarMenu(),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  static bool _isActive(String currentLoc, String tabPath) {
    if (currentLoc == tabPath) return true;
    // Treat /home as active for the bare app root just in case.
    if (tabPath == '/home' && currentLoc == '/') return true;
    return false;
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Text(
      'STREAMLOAD',
      style: StreamloadTypography.v3CtaLabel(
        color: StreamloadColors.v3TextPrimary,
      ).copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.label,
    required this.path,
    required this.active,
  });

  final String label;
  final String path;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? StreamloadColors.v3TextPrimary
        : StreamloadColors.v3TextSecondary;
    return InkWell(
      onTap: () => context.go(path),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(
          label,
          style: StreamloadTypography.v3CtaLabel(color: color),
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.search, size: 20),
      color: StreamloadColors.v3TextPrimary,
      splashRadius: 18,
      tooltip: 'Cerca',
    );
  }
}

