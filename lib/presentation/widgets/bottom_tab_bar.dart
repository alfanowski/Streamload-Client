// lib/presentation/widgets/bottom_tab_bar.dart
//
// Phone bottom navigation.
//
//   • iOS (iPhone, iOS 26+) → the OFFICIAL native Apple Liquid Glass tab bar
//     (native_liquid_glass's LiquidGlassTabBar): genuine SF Symbols, the
//     liquid morphing indicator, and the drag-to-switch gesture — exactly
//     the Apple Music behaviour, all handled natively by iOS.
//   • macOS / Android / tests → a custom glass capsule (Home · Lista ·
//     Profilo) + a separate Cerca circle, via GlassSurface.
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:native_liquid_glass/native_liquid_glass.dart';

import '../theme/tokens.dart';
import 'primitives/glass_surface.dart';

class StreamloadBottomTabBar extends ConsumerWidget {
  const StreamloadBottomTabBar({super.key});

  // Native tab order (search is a normal tab on the native bar).
  static const List<String> _nativePaths = ['/home', '/search', '/list', '/profile'];

  // Fallback capsule tabs (search is the separate circle).
  static const List<({IconData icon, String label, String path})> _capsuleTabs = [
    (icon: Icons.home_outlined, label: 'Home', path: '/home'),
    (icon: Icons.bookmark_outline, label: 'Lista', path: '/list'),
    (icon: Icons.person_outline, label: 'Profilo', path: '/profile'),
  ];

  static const double _barHeight = 64;

  static bool get _useNative {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = GoRouterState.of(context).matchedLocation;

    if (_useNative) {
      return LiquidGlassTabBar(
        currentIndex: _nativeIndex(current),
        onTabSelected: (i) => context.go(_nativePaths[i]),
        items: const [
          LiquidGlassTabItem(
            label: 'Home',
            icon: NativeLiquidGlassIcon.sfSymbol('house'),
            selectedIcon: NativeLiquidGlassIcon.sfSymbol('house.fill'),
          ),
          LiquidGlassTabItem(
            label: 'Cerca',
            icon: NativeLiquidGlassIcon.sfSymbol('magnifyingglass'),
          ),
          LiquidGlassTabItem(
            label: 'Lista',
            icon: NativeLiquidGlassIcon.sfSymbol('bookmark'),
            selectedIcon: NativeLiquidGlassIcon.sfSymbol('bookmark.fill'),
          ),
          LiquidGlassTabItem(
            label: 'Profilo',
            icon: NativeLiquidGlassIcon.sfSymbol('person'),
            selectedIcon: NativeLiquidGlassIcon.sfSymbol('person.fill'),
          ),
        ],
      );
    }

    return _CapsuleBar(current: current);
  }

  static int _nativeIndex(String current) {
    for (var i = 0; i < _nativePaths.length; i++) {
      if (current == _nativePaths[i]) return i;
      if (_nativePaths[i] == '/home' && current == '/') return i;
    }
    return 0;
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Fallback (non-iOS): custom glass capsule + separate search circle.
// ──────────────────────────────────────────────────────────────────────────

class _CapsuleBar extends StatelessWidget {
  const _CapsuleBar({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeCapsuleIndex(current);
    final searchActive = current == '/search';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: GlassSurface(
                capsule: true,
                borderRadius: StreamloadBottomTabBar._barHeight / 2,
                blur: 18,
                thickness: 18,
                tint: StreamloadTokens.bg.withValues(alpha: 0.5),
                child: SizedBox(
                  height: StreamloadBottomTabBar._barHeight,
                  child: Stack(
                    children: [
                      if (activeIndex != null)
                        AnimatedAlign(
                          duration: StreamloadTokens.page,
                          curve: StreamloadTokens.standardCurve,
                          alignment: Alignment(
                            StreamloadBottomTabBar._capsuleTabs.length == 1
                                ? 0
                                : (activeIndex /
                                            (StreamloadBottomTabBar
                                                    ._capsuleTabs.length -
                                                1)) *
                                        2 -
                                    1,
                            0,
                          ),
                          child: FractionallySizedBox(
                            widthFactor:
                                1 / StreamloadBottomTabBar._capsuleTabs.length,
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
                          for (var i = 0;
                              i < StreamloadBottomTabBar._capsuleTabs.length;
                              i++)
                            Expanded(
                              child: _CapsuleTab(
                                icon: StreamloadBottomTabBar._capsuleTabs[i].icon,
                                label:
                                    StreamloadBottomTabBar._capsuleTabs[i].label,
                                active: activeIndex == i,
                                onTap: () => context.go(
                                    StreamloadBottomTabBar._capsuleTabs[i].path),
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
            GlassSurface(
              capsule: true,
              borderRadius: StreamloadBottomTabBar._barHeight / 2,
              blur: 18,
              thickness: 18,
              tint: StreamloadTokens.bg.withValues(alpha: 0.5),
              child: GestureDetector(
                onTap: () => context.go('/search'),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: StreamloadBottomTabBar._barHeight,
                  height: StreamloadBottomTabBar._barHeight,
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
    const tabs = StreamloadBottomTabBar._capsuleTabs;
    for (var i = 0; i < tabs.length; i++) {
      if (current == tabs[i].path) return i;
      if (tabs[i].path == '/home' && current == '/') return i;
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
