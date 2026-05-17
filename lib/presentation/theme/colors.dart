// Cinematic Editorial color tokens, ported from v2 SvelteKit app.css.
// Surfaces are warm-tinted near-blacks; text is warm off-white; accent is amber.
//
// 2026-05-16: extended with Netflix×AppleTV refactor tokens (bgBase,
// surfaceGlass*, ctaPrimary*, ctaUnavailable*) — additive, the v2 cinematic
// editorial tokens above stay so existing widgets don't break during the
// gradual migration of Phase D-I.
//
// 2026-05-17 (Pass 2A): the Pass 1 white CTA pills become yellow (#FFC700)
// per operator feedback "voglio uno stile più Netflix, ma al posto del
// rosso voglio un altro colore, vorrei tipo un giallo". v3CtaPrimaryBg is
// the load-bearing token — PlayCta + PrimaryPill + filter chips all read
// it, so swapping it propagates the brand color through the whole UI
// without touching the call sites. v3CtaPrimaryFg stays black for AAA
// contrast on the bright yellow surface. The new v3AccentYellow /
// v3AccentYellowHover / v3SurfaceGlassYellow tokens give the hover + soft
// "active state" tier the same brand language without copy-pasting the
// raw hex.

import 'package:flutter/material.dart';

class StreamloadColors {
  StreamloadColors._();

  // ──────────────────────────────────────────────────────────────────────────
  // v2 Cinematic Editorial (kept for backward-compat with existing widgets)
  // ──────────────────────────────────────────────────────────────────────────

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

  // ──────────────────────────────────────────────────────────────────────────
  // v3 Netflix×AppleTV refactor tokens (Phase A1, sub-plan 8)
  //
  // 2026-05-16 (post-Phase D operator feedback): dropped the purple tint —
  // user asked for true Netflix-style cinematic black. Page bg becomes
  // Netflix's actual #141414 (slightly lifted from pure black for OLED
  // comfort + so glows/shadows don't read as cutouts), top bar scrolls
  // solid black, hero backdrops own all the color in the chrome.
  // ──────────────────────────────────────────────────────────────────────────

  // Backgrounds — Netflix-grade dark, no purple tint.
  static const Color v3BgBase = Color(0xFF141414);
  static const Color v3BgGradientStart = Color(0xFF141414);
  static const Color v3BgGradientEnd = Color(0xFF000000);
  static const Color v3BgScrolled = Color(0xFF000000);

  // Glass surfaces (used with BackdropFilter blur:20)
  static Color v3SurfaceGlass = const Color(0xFFFFFFFF).withValues(alpha: 0.06);
  static Color v3SurfaceGlassHi = const Color(0xFFFFFFFF).withValues(alpha: 0.10);
  static Color v3SurfaceGlassMax = const Color(0xFFFFFFFF).withValues(alpha: 0.15);
  static Color v3BorderGlass = const Color(0xFFFFFFFF).withValues(alpha: 0.08);
  // Stronger border for popovers / menus where we need crisper edges.
  static Color v3BorderGlassStrong =
      const Color(0xFFFFFFFF).withValues(alpha: 0.20);

  // Popover surface — near-solid dark for menus that float OVER hero
  // backdrops without a BackdropFilter blur (PopupMenu, dropdown
  // pickers). The glass tokens above wash out without blur, so popovers
  // pin a darker base for readability.
  static const Color v3PopoverBg = Color(0xFF1B1B1B);

  // Text — pure white with alpha for hierarchy (v3 is more "TV" than "editorial")
  static const Color v3TextPrimary = Color(0xFFFFFFFF);
  static Color v3TextSecondary = const Color(0xFFFFFFFF).withValues(alpha: 0.65);
  static Color v3TextMuted = const Color(0xFFFFFFFF).withValues(alpha: 0.45);

  // Brand accent — Streamload yellow. Sits between Apple's system #FFCC00
  // and a punchier amber so the pill reads "warm gold" rather than "warning
  // strip". Used as the v3CtaPrimaryBg fill and the soft "active state"
  // tint on filter chips / tabs (v3SurfaceGlassYellow). Foreground on top
  // of either tone stays black (v3CtaPrimaryFg) for AAA contrast.
  static const Color v3AccentYellow = Color(0xFFFFC700);
  static const Color v3AccentYellowHover = Color(0xFFFFDB4D);
  static Color v3SurfaceGlassYellow =
      const Color(0xFFFFC700).withValues(alpha: 0.18);

  // CTAs — primary pill is the brand yellow (Pass 2A). The Pass 1 white
  // tier is gone; if a one-off needs a white pill again, build it locally.
  static const Color v3CtaPrimaryBg = v3AccentYellow;
  static const Color v3CtaPrimaryFg = Color(0xFF000000);
  static Color v3CtaSecondaryBg = const Color(0xFFFFFFFF).withValues(alpha: 0.10);
  static Color v3CtaUnavailableBg = const Color(0xFFFFFFFF).withValues(alpha: 0.04);
  static Color v3CtaUnavailableFg = const Color(0xFFFFFFFF).withValues(alpha: 0.45);

  // Status (muted, not Netflix-red)
  static const Color v3Success = Color(0xFF9AFF9A);
  static const Color v3Warn = Color(0xFFFFD980);
}
