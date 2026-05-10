// Cinematic Editorial color tokens, ported from v2 SvelteKit app.css.
// Surfaces are warm-tinted near-blacks; text is warm off-white; accent is amber.

import 'package:flutter/material.dart';

class StreamloadColors {
  StreamloadColors._();

  // Backgrounds
  static const Color bg = Color(0xFF08090A);
  static const Color bgElevated = Color(0xFF0E0F11);
  static const Color surface1 = Color(0xFF131316);
  static const Color surface2 = Color(0xFF1B1B1F);
  static const Color surface3 = Color(0xFF25252B);

  // Text — warm off-white with explicit alpha for tiers
  static const Color textPrimary = Color(0xFFF5F2EC);
  static const Color textSecondary = Color(0xA8F5F2EC); // 66% alpha
  static const Color textTertiary = Color(0x6BF5F2EC); // 42% alpha
  static const Color textMuted = Color(0x47F5F2EC); // 28% alpha

  // Accents
  static const Color accent = Color(0xFFD4A574);
  static const Color accentHover = Color(0xFFE2B888);
  static const Color gold = Color(0xFFF4D17C);
  static const Color critical = Color(0xFFF26B5E);
  static const Color success = Color(0xFF7CC089);

  // Borders / separators
  static const Color border = Color(0x14F5F2EC); // ~8% alpha
  static const Color borderStrong = Color(0x29F5F2EC); // ~16% alpha
}
