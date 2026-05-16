// lib/presentation/widgets/press_feedback.dart
//
// Tactile press-down scale animation. Wrap any tappable widget to get an
// instant 1.0 → 0.96 squeeze on pointer down (mouse click OR touch), with
// a quick spring back on release / cancel. Sits OUTSIDE the InkWell so it
// reads as the whole control "depressing" before the ink ripple fires.
//
// Used by PosterCard, PlayCta, filter chips — anything the user taps.
// Keep the duration tight (~110ms) so feedback feels reactive, not laggy.
import 'package:flutter/widgets.dart';

class PressFeedback extends StatefulWidget {
  const PressFeedback({
    super.key,
    required this.child,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 110),
  });

  final Widget child;
  final double scale;
  final Duration duration;

  @override
  State<PressFeedback> createState() => _PressFeedbackState();
}

class _PressFeedbackState extends State<PressFeedback> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
