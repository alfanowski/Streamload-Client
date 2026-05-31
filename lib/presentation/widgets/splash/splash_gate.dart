// lib/presentation/widgets/splash/splash_gate.dart
//
// SplashGate — wraps the app (via MaterialApp.router's `builder`) and, on a cold
// start, shows a black overlay where the "Streamload" wordmark DRAWS ITSELF
// stroke-by-stroke (handwriting), then dissolves super-smoothly to reveal the
// app underneath (no hard cut — the app is already mounted behind the overlay).
//
// The wordmark is a pre-generated SVG Path (Fraunces Italic, see
// streamload_wordmark_path.dart), parsed once with path_drawing and animated
// with PathMetrics. No runtime font parsing → reliable, every glyph present.
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../theme/colors.dart';
import 'streamload_wordmark_path.dart';

/// Wrap the app content; plays the splash once then removes itself.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_done)
          Positioned.fill(
            child: _SplashOverlay(
              onFinished: () {
                if (mounted) setState(() => _done = true);
              },
            ),
          ),
      ],
    );
  }
}

class _SplashOverlay extends StatefulWidget {
  const _SplashOverlay({required this.onFinished});
  final VoidCallback onFinished;

  @override
  State<_SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<_SplashOverlay>
    with SingleTickerProviderStateMixin {
  static const _targetHeight = 58.0;

  late final AnimationController _c;
  late final Path? _wordPath; // screen-space, top-left at origin
  late final Size _wordSize;

  // Phase boundaries over the controller's 0..1.
  static const _drawEnd = 0.70; // stroke draws
  static const _holdEnd = 0.84; // brief hold; remainder = fade-out reveal

  @override
  void initState() {
    super.initState();
    final built = _buildWordPath(kStreamloadWordmarkSvgPath, _targetHeight);
    _wordPath = built?.path;
    _wordSize = built?.size ?? Size.zero;

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onFinished();
      });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final fade = t <= _holdEnd
            ? 1.0
            : 1.0 - Curves.easeInOut.transform((t - _holdEnd) / (1 - _holdEnd));
        return Opacity(
          opacity: fade.clamp(0.0, 1.0),
          child: ColoredBox(
            color: Colors.black,
            child: Center(child: _content(t)),
          ),
        );
      },
    );
  }

  Widget _content(double t) {
    // Gentle settle as it reveals.
    final settle = ((t - _holdEnd) / (1 - _holdEnd)).clamp(0.0, 1.0);
    final scale = 1.0 + 0.03 * Curves.easeInOut.transform(settle);

    if (_wordPath == null) {
      // Fallback (parse failed) — plain fading wordmark, never a black hole.
      final appear = Curves.easeOut.transform((t / _drawEnd).clamp(0.0, 1.0));
      return Opacity(
        opacity: appear,
        child: const Text(
          'Streamload',
          style: TextStyle(
            fontSize: 40,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: StreamloadColors.v3TextPrimary,
          ),
        ),
      );
    }

    final draw = (t / _drawEnd).clamp(0.0, 1.0);
    final fillT = ((draw - 0.75) / 0.25).clamp(0.0, 1.0);
    return Transform.scale(
      scale: scale,
      child: CustomPaint(
        size: _wordSize,
        painter: _WordmarkPainter(
          path: _wordPath,
          draw: Curves.easeInOut.transform(draw),
          fill: fillT,
        ),
      ),
    );
  }
}

/// Parses the SVG wordmark, scales it so the word is [targetHeight] tall, and
/// repositions its top-left to the origin. Returns null if parsing fails.
({Path path, Size size})? _buildWordPath(String svg, double targetHeight) {
  try {
    final raw = parseSvgPathData(svg);
    final rb = raw.getBounds();
    if (rb.isEmpty || rb.height == 0) return null;
    final scale = targetHeight / rb.height;
    var p = raw.transform(Matrix4.diagonal3Values(scale, scale, 1).storage);
    final sb = p.getBounds();
    p = p.transform(Matrix4.translationValues(-sb.left, -sb.top, 0).storage);
    final fb = p.getBounds();
    return (path: p, size: Size(fb.width, fb.height));
  } catch (_) {
    return null;
  }
}

class _WordmarkPainter extends CustomPainter {
  _WordmarkPainter({required this.path, required this.draw, required this.fill});

  final Path path;
  final double draw; // 0..1 stroke progress
  final double fill; // 0..1 fill opacity

  @override
  void paint(Canvas canvas, Size size) {
    // Progressive stroke across all contours, in path order (≈ left-to-right).
    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (s, m) => s + m.length);
    final target = total * draw;

    final stroked = Path();
    var acc = 0.0;
    for (final m in metrics) {
      if (acc >= target) break;
      final remaining = target - acc;
      final take = remaining >= m.length ? m.length : remaining;
      stroked.addPath(m.extractPath(0, take), Offset.zero);
      acc += m.length;
    }

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = StreamloadColors.v3TextPrimary;
    canvas.drawPath(stroked, strokePaint);

    if (fill > 0) {
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = StreamloadColors.v3TextPrimary.withValues(alpha: fill);
      canvas.drawPath(path, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WordmarkPainter old) =>
      old.draw != draw || old.fill != fill || old.path != path;
}
