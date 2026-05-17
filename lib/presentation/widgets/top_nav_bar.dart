// lib/presentation/widgets/top_nav_bar.dart
//
// v3 Netflix×AppleTV refactor — desktop + tablet top navigation bar.
//
// Floats over page content (the AppShell stacks it above the body) and
// switches its background from a warm-tinted near-black to a slightly
// deeper warm-tinted near-black once the active page reports that the
// user has scrolled past ~80px via navScrolledProvider. Pages own that
// listener — see HomePage / TitlePage body wiring in Phases D / E.
//
// Layout (left → right):
//   logo "STREAMLOAD" · Home · Film · Serie TV · Anime · La mia lista
//   · [spacer] · 🔍 · avatar
//
// Phone variant is the StreamloadBottomTabBar in bottom_tab_bar.dart — this
// widget is desktop / tablet only and is not used on phone.
//
// 2026-05-17 (CM-2): the Pass 2B LiquidGlass + BackdropFilter chrome was
// dropped. The nav is now a solid warm surface (v3BgBase at rest,
// v3BgScrolled after the page is scrolled past 80 px) with a single
// hairline bottom border. No blur, no wet-rim highlight, no
// transparency tricks. Editorial — the chrome stays out of the way.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/nav_scrolled_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/typography.dart';
import 'avatar_menu.dart';
import 'search_overlay.dart';

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
        : StreamloadColors.v3BgBase;
    final currentLoc = GoRouterState.of(context).matchedLocation;

    return AnimatedContainer(
      duration: StreamloadMotion.navBarFade,
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(
            color: StreamloadColors.v3BorderGlass,
            // Slightly thicker hairline once the user scrolls past so the
            // chrome separates more decisively from the page body.
            width: scrolled ? 1.0 : 0.5,
          ),
        ),
      ),
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
                            active: _isActive(currentLoc, _tabs[i].path),
                          ),
                          if (i < _tabs.length - 1)
                            SizedBox(width: tabGap),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Desktop / tablet: open the live-suggestions overlay
                // (G1). Phone is handled by the bottom tab bar, but
                // we keep the responsive branch here so resizing the
                // window to a phone width still does the right thing
                // (navigates to the dedicated /search page instead).
                _SearchButton(
                  onTap: () {
                    if (Responsive.isPhone(context)) {
                      context.go('/search');
                    } else {
                      SearchOverlay.show(context);
                    }
                  },
                ),
                const SizedBox(width: 12),
                const AvatarMenu(),
              ],
            ),
          );
        }),
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
    // CM-2: editorial wordmark — Fraunces non-italic, narrow tracking. The
    // logo carries the magazine voice into the chrome too.
    return Text(
      'STREAMLOAD',
      style: StreamloadTypography.display(
        fontSize: 16,
        italic: false,
      ).copyWith(letterSpacing: 1.5),
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
    // CM-2: the Pass 2A yellow underline + glow on the active tab is
    // gone. Editorial — the active tab reads as ink-on-paper bold; we
    // animate a hairline warm-off-white underline (no colour pop, no
    // shadow). 16 px width at rest is enough to feel like a tab marker
    // without becoming a label decoration.
    return InkWell(
      onTap: () => context.go(path),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: StreamloadTypography.body(
                fontSize: 14,
                weight: active ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: StreamloadMotion.hoverDuration,
              curve: StreamloadMotion.hoverCurve,
              height: 1,
              width: active ? 18 : 0,
              color: StreamloadColors.v3TextPrimary,
            ),
          ],
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
