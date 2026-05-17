// lib/presentation/widgets/press_feedback.dart
//
// Tactile press-down scale animation. Wrap any tappable widget to get an
// instant 1.0 → 0.96 squeeze on pointer down (mouse click OR touch), with
// a quick ease-out scale back on release / cancel. Sits OUTSIDE the
// InkWell so it reads as the whole control "depressing" before the ink
// ripple fires.
//
// Used by PosterCard, PlayCta, filter chips — anything the user taps.
//
// 2026-05-17 (CM-2): the Pass 2F SpringSimulation with mass/stiffness/
// damping (and the overshoot it caused) was reverted to a plain
// 110 ms ease-out AnimatedScale. The spring's micro-overshoot felt
// "cheap" against the editorial pivot — restraint is the point.
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

class _PressFeedbackState extends State<PressFeedback> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        // 110 ms is just long enough to read as a deliberate press without
        // feeling laggy on a desktop click.
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
