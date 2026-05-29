// lib/presentation/widgets/primitives/glass_surface.dart
//
// Apple-style "liquid glass" surface for the app chrome (top bar + mobile
// tab bar). Three render paths, chosen at runtime:
//
//   • iOS (iPhone/iPad, iOS 26+) → the OFFICIAL Apple Liquid Glass via
//     native_liquid_glass's LiquidGlassContainer (native UIKit view).
//   • macOS / Android desktop+mobile → the liquid_glass_renderer SHADER
//     (Impeller) recreation — consistent cross-platform look.
//   • web / other / `flutter test` → the shader's lightweight FakeGlass
//     (BackdropFilter), so the build never breaks and tests don't load
//     fragment shaders.
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart' as shader;
import 'package:native_liquid_glass/native_liquid_glass.dart' as native;

import '../../theme/tokens.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 8,
    this.thickness = 14,
    this.tint,
    this.capsule = false,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final double thickness;
  final Color? tint;

  /// Fully-rounded pill shape (used by the floating mobile tab bar).
  final bool capsule;

  /// True iPhone/iPad → use the official native Apple glass.
  static bool get _isIos {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  /// Shader fallback uses FakeGlass on web / other platforms / under test.
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
    final glassTint = tint ?? StreamloadTokens.bg.withValues(alpha: 0.42);

    // ── Official Apple Liquid Glass on iOS ────────────────────────────────
    if (_isIos) {
      return native.LiquidGlassContainer(
        config: native.LiquidGlassConfig(
          effect: native.LiquidGlassEffect.regular,
          shape: capsule
              ? native.LiquidGlassEffectShape.capsule
              : native.LiquidGlassEffectShape.rect,
          cornerRadius: capsule ? null : borderRadius,
          tint: glassTint,
        ),
        child: child,
      );
    }

    // ── Shader recreation (macOS / Android) / FakeGlass (web / test) ──────
    final settings = shader.LiquidGlassSettings(
      blur: blur,
      thickness: thickness,
      glassColor: glassTint,
      lightIntensity: 0.6,
    );
    return shader.LiquidGlass.withOwnLayer(
      shape: shader.LiquidRoundedSuperellipse(borderRadius: borderRadius),
      settings: settings,
      fake: useFake(),
      glassContainsChild: false,
      child: child,
    );
  }
}
