// lib/presentation/widgets/bottom_tab_bar.dart
//
// v3 phone bottom tab bar. Renders four tabs (Home · Cerca · La mia lista ·
// Profilo) over a glass-blurred background with a 1px top border. Active
// tab gets a white icon + label; inactive uses v3TextMuted. The bar is
// only used on phone (Responsive.isPhone) — desktop / tablet use the
// TopNavBar instead.
//
// Settings + logout live behind the Profilo tab on phone (full-page
// profile screen) — no avatar popover here. That mirrors the spec's
// "no modals on phone" rule.
//
// Pass 2B (2026-05-17): the BackdropFilter + colored DecoratedBox was
// replaced with the LiquidGlass primitive so the phone bottom bar reads
// as Apple-style liquid glass — same blur, but with the wet-rim
// highlight along the top edge and the subtle diagonal tint gradient.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import 'liquid_glass.dart';

class StreamloadBottomTabBar extends ConsumerWidget {
  const StreamloadBottomTabBar({super.key});

  static const List<({IconData icon, String label, String path})> _tabs = [
    (icon: Icons.home_outlined, label: 'Home', path: '/home'),
    (icon: Icons.search, label: 'Cerca', path: '/search'),
    (icon: Icons.bookmark_outline, label: 'La mia lista', path: '/list'),
    (icon: Icons.person_outline, label: 'Profilo', path: '/profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = GoRouterState.of(context).matchedLocation;
    return LiquidGlass(
      borderRadius: BorderRadius.zero,
      // The bar sits on a pure-black page bg most of the time. Push the
      // opacity a hair higher than the top nav so labels stay legible
      // even when the user is on the Search page (which is a flat dark
      // surface, no hero backdrop to bleed through).
      opacity: 0.25,
      blur: 28,
      borderOpacity: 0.10,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: StreamloadColors.v3BgScrolled.withValues(alpha: 0.55),
          border: Border(
            top: BorderSide(color: StreamloadColors.v3BorderGlass),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final tab in _tabs)
                  _Tab(
                    icon: tab.icon,
                    label: tab.label,
                    path: tab.path,
                    active: _isActive(current, tab.path),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static bool _isActive(String current, String tabPath) {
    if (current == tabPath) return true;
    if (tabPath == '/home' && current == '/') return true;
    return false;
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.path,
    required this.active,
  });

  final IconData icon;
  final String label;
  final String path;
  final bool active;

  @override
  Widget build(BuildContext context) {
    // Brand reinforcement (Pass 2A): icon + label tint to brand yellow on
    // the active tab. Phone surface is denser than desktop nav, so we use
    // color (not an underline) to indicate selection — keeps the touch
    // target tight without adding a second hit-test layer.
    final color = active
        ? StreamloadColors.v3AccentYellow
        : StreamloadColors.v3TextMuted;
    return InkWell(
      onTap: () => context.go(path),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: StreamloadTypography.v3CtaLabel(color: color)
                  .copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
