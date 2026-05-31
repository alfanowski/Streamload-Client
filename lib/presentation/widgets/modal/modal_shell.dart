// lib/presentation/widgets/modal/modal_shell.dart
//
// ModalShell — the chrome shared by the full-screen, Netflix-style modals
// (title page, person page). It paints the black background, hosts a native
// iOS Liquid Glass ✕ close button, and closes on a deliberate downward drag
// at the top of the inner scroll (a flick-up-to-top's ballistic overscroll
// has no dragDetails, so it never dismisses involuntarily).
//
// The hero stretch on overscroll lives in [StretchyHeroScrollView]; this
// shell only owns the background, the close affordances and the dismiss.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../primitives/glass_surface.dart';

class ModalShell extends StatefulWidget {
  const ModalShell({super.key, required this.child});

  /// The modal's content — a scrollable (loading spinner / error / the
  /// hero scroll view). Its scroll notifications drive the pull-to-dismiss.
  final Widget child;

  @override
  State<ModalShell> createState() => _ModalShellState();
}

class _ModalShellState extends State<ModalShell> {
  bool _dismissing = false;
  static const double _closeThreshold = 130;

  void _dismiss() {
    if (_dismissing) return;
    _dismissing = true;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
  }

  bool _onScroll(ScrollNotification n) {
    // Only the primary VERTICAL scroll may dismiss. Nested scrollables (the
    // horizontal cast row, etc.) bubble notifications through here too — their
    // left-edge overscroll must NOT be read as a downward pull. depth == 0 is
    // the outermost (main) scroll; the cast row arrives at depth >= 1.
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    // Close only on a DELIBERATE downward drag at the very top — the finger
    // is down (dragDetails != null) and pulled past the threshold. The
    // ballistic overscroll from a fast flick-up-to-top has no dragDetails,
    // so it can't dismiss the panel.
    final DragUpdateDetails? drag = n is ScrollUpdateNotification
        ? n.dragDetails
        : n is OverscrollNotification
            ? n.dragDetails
            : null;
    if (drag == null || _dismissing) return false;
    final pull = n.metrics.minScrollExtent - n.metrics.pixels;
    if (pull > _closeThreshold) _dismiss();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: widget.child,
              ),
            ),
            Positioned(
              top: topPad + 8,
              right: 14,
              child: _GlassClose(onTap: _dismiss),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassClose extends StatelessWidget {
  const _GlassClose({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const GlassSurface(
        capsule: true,
        borderRadius: 19,
        blur: 14,
        thickness: 14,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(Icons.close_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
