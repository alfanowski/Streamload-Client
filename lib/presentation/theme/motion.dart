// lib/presentation/theme/motion.dart
// v3 Netflix×AppleTV refactor motion tokens (sub-plan 8, Phase A1).
import 'package:flutter/animation.dart';

class StreamloadMotion {
  StreamloadMotion._();

  /// Card / button hover scale duration.
  static const Duration hoverDuration = Duration(milliseconds: 200);
  static const Curve hoverCurve = Curves.easeOut;

  /// Hero auto-rotate cadence.
  static const Duration heroRotateInterval = Duration(seconds: 30);

  /// Crossfade between hero slides.
  static const Duration heroCrossfade = Duration(milliseconds: 600);
  static const Curve heroCrossfadeCurve = Curves.easeInOut;

  /// Carousel slide every N seconds (alternative to heroRotateInterval —
  /// used when we want shorter rotations on smaller hero variants).
  static const Duration carouselSlideEvery = Duration(seconds: 7);

  /// Page transition duration.
  static const Duration pageTransition = Duration(milliseconds: 250);

  /// Trailer reveal delay — backdrop sits for this long before the YouTube
  /// iframe fades in.
  static const Duration trailerRevealDelay = Duration(seconds: 2);

  /// Background color animation on top-bar scroll transition.
  static const Duration navBarFade = Duration(milliseconds: 250);
}
