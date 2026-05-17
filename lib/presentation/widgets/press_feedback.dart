// lib/presentation/widgets/press_feedback.dart
//
// Tactile press-down scale animation. Wrap any tappable widget to get an
// instant 1.0 → 0.96 squeeze on pointer down (mouse click OR touch), with
// a quick spring-back on release / cancel. Sits OUTSIDE the InkWell so it
// reads as the whole control "depressing" before the ink ripple fires.
//
// Used by PosterCard, PlayCta, filter chips — anything the user taps.
//
// Pass 2F (2026-05-17): the AnimatedScale linear ease-out was replaced
// with an AnimationController driven by a SpringSimulation (mass 1,
// stiffness 500, damping 18) so the bounce-back has the tactile feel of
// a physical button instead of a flat slide. The spring's natural
// settling time is ~250 ms — still feels reactive on the way down but
// gives a satisfying micro-overshoot on release.
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

class PressFeedback extends StatefulWidget {
  const PressFeedback({
    super.key,
    required this.child,
    this.scale = 0.96,
  });

  final Widget child;

  /// Pressed scale. Defaults to 0.96 — small enough that the control
  /// still reads as the same shape, large enough to feel responsive.
  final double scale;

  @override
  State<PressFeedback> createState() => _PressFeedbackState();
}

class _PressFeedbackState extends State<PressFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // Cached spring description — reused for every release so we don't
  // allocate during the press handler hot path.
  static const SpringDescription _spring = SpringDescription(
    mass: 1,
    stiffness: 500,
    damping: 18,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _press() {
    // Snap immediately down to the pressed scale — no easing on the
    // press, so the feedback fires the very frame the user touches.
    _controller.value = widget.scale;
  }

  void _release() {
    // Spring back to 1.0 with a small velocity so the overshoot reads
    // as 'bouncing back to rest'. Initial velocity of 4 keeps it lively
    // without making the control wobble after settling.
    final sim = SpringSimulation(_spring, _controller.value, 1.0, 4);
    _controller.animateWith(sim);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _press(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _controller.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
