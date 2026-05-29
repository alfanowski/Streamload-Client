// lib/presentation/widgets/primitives/glass_surface.dart
//
// Apple-style "liquid glass" surface, used for the app chrome (desktop top
// bar + mobile floating tab bar). Wraps liquid_glass_renderer's LiquidGlass
// with its own layer.
//
// Performance + safety: the real shader runs only on Impeller-backed mobile
// / macOS. On web / other desktops and inside `flutter test` it falls back
// to the package's lightweight FakeGlass (BackdropFilter) via `fake: true`,
// so the build never breaks and tests don't try to load fragment shaders.
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../theme/tokens.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 8,
    this.thickness = 14,
    this.tint,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final double thickness;
  final Color? tint;

  /// Real shader only on Impeller mobile/macOS; FakeGlass everywhere else
  /// (web, other desktops) and under `flutter test`.
  static bool useFake() {
    if (kIsWeb) return true;
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return true;
      return !(Platform.isIOS || Platform.isAndroid || Platform.isMacOS);
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = LiquidGlassSettings(
      blur: blur,
      thickness: thickness,
      glassColor: tint ?? StreamloadTokens.bg.withValues(alpha: 0.42),
      lightIntensity: 0.6,
    );
    return LiquidGlass.withOwnLayer(
      shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
      settings: settings,
      fake: useFake(),
      glassContainsChild: false,
      child: child,
    );
  }
}
