// lib/presentation/widgets/bottom_tab_bar.dart
//
// Phone bottom navigation — Apple-Music style.
//
// A glass capsule (Home · Lista · Profilo) + a DETACHED Cerca circle on the
// right. Tapping Cerca routes to /search and the bar MORPHS smoothly: the
// capsule collapses to a Home circle while the Cerca circle expands into a
// full glass search field (which autofocuses → keyboard). Everything is one
// animated custom bar built on GlassSurface, because the native tab bar can't
// collapse/expand like this — only iOS's own UITab(role: .search) does, and
// that isn't exposed to Flutter.
import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/search_query_provider.dart';
import '../theme/tokens.dart';
import 'primitives/glass_surface.dart';

class StreamloadBottomTabBar extends StatelessWidget {
  const StreamloadBottomTabBar({super.key});

  static const double _barHeight = 60;

  // Browse capsule tabs (Cerca is the separate, morphing circle).
  static const List<({IconData icon, String label, String path})> _tabs = [
    (icon: Icons.home_outlined, label: 'Home', path: '/home'),
    (icon: Icons.bookmark_outline, label: 'Lista', path: '/list'),
    (icon: Icons.person_outline, label: 'Profilo', path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) => const _MorphBar();
}

class _MorphBar extends ConsumerStatefulWidget {
  const _MorphBar();

  @override
  ConsumerState<_MorphBar> createState() => _MorphBarState();
}

class _MorphBarState extends ConsumerState<_MorphBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;
  final TextEditingController _search = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _debounce;
  bool? _searching; // last known route state, to drive the animation once

  static const double _h = StreamloadBottomTabBar._barHeight;
  static const double _gap = 10;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _search.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Drive the morph when the route enters / leaves /search (post-frame so we
  /// never mutate the controller during build).
  void _sync(bool searching) {
    if (_searching == searching) return;
    _searching = searching;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (searching) {
        _controller.forward();
        _focus.requestFocus();
      } else {
        _focus.unfocus();
        _controller.reverse();
      }
    });
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  void _clear() {
    _debounce?.cancel();
    _search.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    _focus.requestFocus();
  }

  Widget _glass({required Widget child}) {
    return GlassSurface(
      capsule: true,
      borderRadius: _h / 2,
      blur: 18,
      thickness: 18,
      tint: StreamloadTokens.bg.withValues(alpha: 0.5),
      child: SizedBox(height: _h, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).matchedLocation;
    final searching = current.startsWith('/search');
    _sync(searching);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: SizedBox(
          height: _h,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final full = w - _h - _gap; // the wide side's width
              return AnimatedBuilder(
                animation: _t,
                builder: (context, _) {
                  final t = _t.value;
                  final leftW = lerpDouble(full, _h, t)!;
                  final rightW = w - _gap - leftW;
                  return Row(
                    children: [
                      SizedBox(
                        width: leftW,
                        child: _leftGlass(t, current, searching, full),
                      ),
                      const SizedBox(width: _gap),
                      SizedBox(
                        width: rightW,
                        child: _rightGlass(t, searching, full),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Left: browse capsule (Home·Lista·Profilo) ⇄ Home circle.
  Widget _leftGlass(double t, String current, bool searching, double full) {
    return _glass(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_h / 2),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: (1 - t * 1.6).clamp(0.0, 1.0),
              child: IgnorePointer(
                ignoring: searching,
                child: OverflowBox(
                  minWidth: 0,
                  maxWidth: full,
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: full,
                    height: _h,
                    child: _CapsuleTabs(current: current),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: ((t - 0.45) / 0.55).clamp(0.0, 1.0),
              child: IgnorePointer(
                ignoring: !searching,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _focus.unfocus();
                    context.go('/home');
                  },
                  child: const Center(
                    child: Icon(
                      Icons.home_rounded,
                      size: 24,
                      color: StreamloadTokens.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Right: Cerca circle ⇄ search field.
  Widget _rightGlass(double t, bool searching, double full) {
    return _glass(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_h / 2),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: (1 - t * 1.6).clamp(0.0, 1.0),
              child: IgnorePointer(
                ignoring: searching,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.go('/search'),
                  child: Center(
                    child: Icon(
                      Icons.search,
                      size: 24,
                      color: StreamloadTokens.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: ((t - 0.45) / 0.55).clamp(0.0, 1.0),
              child: IgnorePointer(
                ignoring: !searching,
                child: OverflowBox(
                  minWidth: 0,
                  maxWidth: full,
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: full,
                    height: _h,
                    child: _searchField(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Icon(Icons.search, size: 22, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _search,
              focusNode: _focus,
              cursorColor: Colors.white,
              cursorWidth: 1.5,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                ref.read(searchQueryProvider.notifier).state = v;
              },
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Film, serie TV, attori e altro…',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _search,
            builder: (context, value, _) {
              if (value.text.isEmpty) {
                return Icon(
                  Icons.mic_none_rounded,
                  size: 22,
                  color: Colors.white.withValues(alpha: 0.6),
                );
              }
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _clear,
                child: Icon(
                  Icons.close_rounded,
                  size: 21,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The three browse tabs that fill the capsule, with a sliding active pill.
class _CapsuleTabs extends StatelessWidget {
  const _CapsuleTabs({required this.current});
  final String current;

  int? get _active {
    const tabs = StreamloadBottomTabBar._tabs;
    for (var i = 0; i < tabs.length; i++) {
      if (current == tabs[i].path) return i;
      if (tabs[i].path == '/home' && current == '/') return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const tabs = StreamloadBottomTabBar._tabs;
    final active = _active;
    return Stack(
      children: [
        if (active != null)
          AnimatedAlign(
            duration: StreamloadTokens.page,
            curve: StreamloadTokens.standardCurve,
            alignment: Alignment(
              (active / (tabs.length - 1)) * 2 - 1,
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / tabs.length,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color:
                        StreamloadTokens.textPrimary.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(StreamloadTokens.radiusPill),
                  ),
                ),
              ),
            ),
          ),
        Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: _CapsuleTab(
                  icon: tabs[i].icon,
                  label: tabs[i].label,
                  active: active == i,
                  onTap: () => context.go(tabs[i].path),
                ),
              ),
          ],
        ),
      ],
    );
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
