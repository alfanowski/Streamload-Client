// lib/presentation/widgets/bottom_tab_bar.dart
//
// Phone bottom navigation — Apple Music / iOS 26 layout (2026-05-30):
// a floating liquid-glass CAPSULE with three tabs (Home · Lista · Profilo,
// icon + label) and a SEPARATE circular Cerca button beside it. On iOS the
// two glass shapes are native LiquidGlassContainers placed close together,
// so iOS 26 blends them like liquid (metaball). On macOS/Android the shader
// recreation is used; in tests, BackdropFilter fallback (via GlassSurface).
//
// The active tab is marked by a highlight pill that SLIDES smoothly between
// the three capsule slots (super-smooth section change).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';
import 'primitives/glass_surface.dart';

class StreamloadBottomTabBar extends ConsumerWidget {
  const StreamloadBottomTabBar({super.key});

  // The three capsule tabs. Search lives in its own circle (Apple style).
  static const List<({IconData icon, String label, String path})> _tabs = [
    (icon: Icons.home_outlined, label: 'Home', path: '/home'),
    (icon: Icons.bookmark_outline, label: 'Lista', path: '/list'),
    (icon: Icons.person_outline, label: 'Profilo', path: '/profile'),
  ];

  static const double _barHeight = 64;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = GoRouterState.of(context).matchedLocation;
    final activeIndex = _activeCapsuleIndex(current);
    final searchActive = current == '/search';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Row(
          children: [
            // ── Capsule with the three tabs + sliding highlight ──────────
            Expanded(
              child: GlassSurface(
                capsule: true,
                borderRadius: _barHeight / 2,
                blur: 18,
                thickness: 18,
                tint: StreamloadTokens.bg.withValues(alpha: 0.5),
                child: SizedBox(
                  height: _barHeight,
                  child: Stack(
                    children: [
                      // Sliding highlight behind the active tab.
                      if (activeIndex != null)
                        AnimatedAlign(
                          duration: StreamloadTokens.page,
                          curve: StreamloadTokens.standardCurve,
                          alignment: Alignment(
                            _tabs.length == 1
                                ? 0
                                : (activeIndex / (_tabs.length - 1)) * 2 - 1,
                            0,
                          ),
                          child: FractionallySizedBox(
                            widthFactor: 1 / _tabs.length,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: StreamloadTokens.textPrimary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                      StreamloadTokens.radiusPill),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          for (var i = 0; i < _tabs.length; i++)
                            Expanded(
                              child: _CapsuleTab(
                                icon: _tabs[i].icon,
                                label: _tabs[i].label,
                                active: activeIndex == i,
                                onTap: () => context.go(_tabs[i].path),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // ── Separate circular Cerca button ──────────────────────────
            GlassSurface(
              capsule: true,
              borderRadius: _barHeight / 2,
              blur: 18,
              thickness: 18,
              tint: StreamloadTokens.bg.withValues(alpha: 0.5),
              child: GestureDetector(
                onTap: () => context.go('/search'),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: _barHeight,
                  height: _barHeight,
                  child: Icon(
                    Icons.search,
                    size: 24,
                    color: searchActive
                        ? StreamloadTokens.textPrimary
                        : StreamloadTokens.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int? _activeCapsuleIndex(String current) {
    for (var i = 0; i < _tabs.length; i++) {
      if (current == _tabs[i].path) return i;
      if (_tabs[i].path == '/home' && current == '/') return i;
    }
    return null;
  }
}

class _CapsuleTab extends StatelessWidget {
  const _CapsuleTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        active ? StreamloadTokens.textPrimary : StreamloadTokens.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
