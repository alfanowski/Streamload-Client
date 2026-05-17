// lib/presentation/widgets/shimmer.dart
//
// Pass 2F (2026-05-17): tiny shimmer primitive for skeleton placeholders.
//
// Wraps an opaque child in an animated linear gradient that sweeps a
// brighter band left-to-right over 1.5 seconds, loops forever. Designed
// to be dropped over the dim glass-color placeholders the rest of the
// app already uses — the shimmer reads as 'we're loading' without
// shouting it.
//
// Why roll our own instead of the `shimmer` package: it's ~30 lines, no
// platform code, no transitive deps, and we get to use our own brand
// tokens (v3SurfaceGlass for the base, v3SurfaceGlassMax for the
// highlight band) which keeps the shimmer identical to the static
// skeleton tones.
//
// Use it like this:
//
//   Shimmer(
//     child: DecoratedBox(
//       decoration: BoxDecoration(
//         color: StreamloadColors.v3SurfaceGlass,
//         borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
//       ),
//     ),
//   )
//
// The child remains the source of truth for shape + base color; Shimmer
// composites a moving highlight gradient via ShaderMask.
import 'package:flutter/material.dart';

import '../theme/colors.dart';

class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.highlightColor,
  });

  /// The opaque placeholder to shimmer over. Should already have its
  /// final shape (size, border radius, base color).
  final Widget child;

  /// One full sweep of the highlight from left to right. Default 1.5 s
  /// matches the spec — short enough to feel alive, slow enough to not
  /// stress the user.
  final Duration duration;

  /// Color of the moving highlight band. Defaults to v3SurfaceGlassMax
  /// so a glass-tinted placeholder gets a brighter glass-tinted sweep.
  final Color? highlightColor;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    // In automated tests `pumpAndSettle` waits for every running ticker;
    // a forever-repeating shimmer makes every page using it time out.
    // Skip the .repeat() in tests so the placeholder still renders the
    // first frame of the gradient (looks reasonable in goldens) but
    // doesn't hold pumpAndSettle hostage.
    if (!_inTestMode) {
      _ctrl.repeat();
    }
  }

  bool get _inTestMode {
    // WidgetsFlutterBinding is the runtime binding; AutomatedTest...
    // and LiveTestWidgets... are the two test bindings. We could check
    // either by name but the simplest invariant is: in tests, the
    // binding is NOT WidgetsFlutterBinding.
    return WidgetsBinding.instance.runtimeType.toString() !=
        'WidgetsFlutterBinding';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlight =
        widget.highlightColor ?? StreamloadColors.v3SurfaceGlassMax;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        // Build a gradient that travels from x = -1 to x = 2 over the
        // animation period. The base remains transparent so the child's
        // own surface shows through; the highlight band moves across.
        final t = _ctrl.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1 + (3 * t), 0),
              end: Alignment(-0.5 + (3 * t), 0),
              colors: [
                Colors.transparent,
                highlight,
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
