// lib/presentation/widgets/bottom_tab_bar.dart
//
// Phone bottom navigation — "Cinematic Premium" refactor (2026-05-29).
// A FLOATING liquid-glass capsule (Apple iOS 26 style) that hovers over the
// content near the bottom edge, rather than a flat edge-to-edge bar. Each
// tab shows an icon + its section name below it (like every Apple app).
//
// Real shader on Impeller mobile; BackdropFilter fallback in tests / on
// unsupported platforms via GlassSurface. Active tab: warm off-white icon +
// label over a subtle highlight pill; inactive: muted.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';
import 'primitives/glass_surface.dart';

class StreamloadBottomTabBar extends ConsumerWidget {
  const StreamloadBottomTabBar({super.key});

  static const List<({IconData icon, String label, String path})> _tabs = [
    (icon: Icons.home_outlined, label: 'Home', path: '/home'),
    (icon: Icons.search, label: 'Cerca', path: '/search'),
    (icon: Icons.bookmark_outline, label: 'Lista', path: '/list'),
    (icon: Icons.person_outline, label: 'Profilo', path: '/profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = GoRouterState.of(context).matchedLocation;
    return SafeArea(
      top: false,
      child: Padding(
        // Floats: horizontal inset + a little lift off the bottom edge.
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: GlassSurface(
          borderRadius: 30,
          capsule: true,
          blur: 18,
          thickness: 18,
          tint: StreamloadTokens.bg.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
    final color =
        active ? StreamloadTokens.textPrimary : StreamloadTokens.textMuted;
    return GestureDetector(
      onTap: () => context.go(path),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: StreamloadTokens.hover,
        curve: StreamloadTokens.standardCurve,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? StreamloadTokens.textPrimary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(StreamloadTokens.radiusPill),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
