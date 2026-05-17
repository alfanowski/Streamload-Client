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
// rosso voglio un altro colore, vorrei tipo un giallo".
//
// 2026-05-17 (Cinema Magazine pivot, CM-1): Pass 2 went too loud. Operator
// said "pesantissima e troppo poco sobria, le animazioni sono eccessive e
// fanno cagare" and asked for "qualcosa di più editoriale e accattivante".
// We REBIND the v3 tokens to the warm magazine palette (the v2 family) so
// every existing call site automatically picks up the editorial look
// without per-widget refactors:
//
//   - v3BgBase / v3BgGradientStart  → warm-tinted near-black (#0F0E0D)
//   - v3BgGradientEnd               → pure black (subtle bottom vignette)
//   - v3BgScrolled                  → slightly deeper warm (#0A0A09)
//   - v3CtaPrimaryBg                → amber #D4A574 (the v2 accent)
//   - v3CtaPrimaryFg                → near-black so amber reads on it
//   - v3SurfaceGlass*               → warm off-white tints at low alpha
//   - v3BorderGlass*                → warm off-white at 8% (drops the
//                                      Pass 2B 20% "iOS card edge" border)
//   - v3PopoverBg                   → stays dark for popover legibility
//
// The yellow tokens (v3AccentYellow*) stay defined because PrimaryPill in
// onboarding still uses the loud accent for "submit" affordances — we
// don't want the editorial pivot to swallow form CTAs.

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
  // v3 tokens — REBOUND on 2026-05-17 (CM-1) to the warm editorial palette.
  // Naming kept as `v3*` so every existing call site (TopNavBar, PosterCard,
  // PlayCta, etc.) automatically inherits the pivot.
  // ──────────────────────────────────────────────────────────────────────────

  // Backgrounds — warm near-black instead of Netflix #141414. The 0F0E0D
  // tone is a hair warmer than the v2 `bg` so the page reads "magazine
  // newsprint at night" rather than "OLED black".
  static const Color v3BgBase = Color(0xFF0F0E0D);
  static const Color v3BgGradientStart = Color(0xFF0F0E0D);
  // Bottom of the page vignettes to pure black — keeps long lists from
  // feeling like they fade into the same warm bg they started on.
  static const Color v3BgGradientEnd = Color(0xFF000000);
  // Scrolled top-nav substrate — slightly darker than the bg so the nav
  // reads as a separate plane once the user scrolls past 80 px.
  static const Color v3BgScrolled = Color(0xFF0A0A09);

  // "Glass" surfaces — kept as solid warm-off-white tints. The widgets
  // that used to wrap these in BackdropFilter (LiquidGlass) are being
  // ripped out in CM-2, but the tokens stay because skeleton placeholders
  // / chip backgrounds / popovers still need a quiet warm fill.
  static Color v3SurfaceGlass =
      const Color(0xFFF5F2EC).withValues(alpha: 0.07);
  static Color v3SurfaceGlassHi =
      const Color(0xFFF5F2EC).withValues(alpha: 0.10);
  static Color v3SurfaceGlassMax =
      const Color(0xFFF5F2EC).withValues(alpha: 0.14);
  // Borders settle at 8% warm off-white — matches the v2 `border` token.
  // The Pass 2B `v3BorderGlassStrong` 20% was dropped in CM-1: it read as
  // an "iOS card edge" against the new warm bg. Anyone reaching for the
  // strong border still gets a hairline, just at the normal 14% tier.
  static Color v3BorderGlass =
      const Color(0xFFF5F2EC).withValues(alpha: 0.08);
  static Color v3BorderGlassStrong =
      const Color(0xFFF5F2EC).withValues(alpha: 0.14);

  // Popover surface — Pass 1 made this near-solid for menu legibility and
  // CM-1 keeps that decision. Slightly nudged to warm-tinted dark so it
  // doesn't read as a cool grey shell on the warm page bg.
  static const Color v3PopoverBg = Color(0xFF1B1B1B);

  // Text — switch to warm off-white (v2's textPrimary family) instead of
  // pure white. Reads as ink on paper rather than projected light.
  static const Color v3TextPrimary = Color(0xFFF5F2EC);
  static Color v3TextSecondary =
      const Color(0xFFF5F2EC).withValues(alpha: 0.65);
  static Color v3TextMuted =
      const Color(0xFFF5F2EC).withValues(alpha: 0.42);

  // Brand accent — Streamload yellow. Kept defined because PrimaryPill
  // (onboarding submit) still uses it as an unmistakable "tap me" affordance
  // — the editorial pivot only quiets *browse* surfaces, not form actions.
  // No widget reads v3SurfaceGlassYellow anymore after CM-2 strips the
  // hover-yellow tints; leaving it defined avoids breaking external
  // refactors mid-flight.
  static const Color v3AccentYellow = Color(0xFFFFC700);
  static const Color v3AccentYellowHover = Color(0xFFFFDB4D);
  static Color v3SurfaceGlassYellow =
      const Color(0xFFFFC700).withValues(alpha: 0.18);

  // CTAs — primary surface flips to the warm amber (#D4A574, v2 accent).
  // Foreground goes to near-black so amber reads as a tactile editorial
  // marker rather than a Netflix-y yellow shout. TextCta in CM-4 uses
  // v3TextPrimary directly (typographic underline, no pill) so this fill
  // mostly survives for PrimaryPill in onboarding now.
  static const Color v3CtaPrimaryBg = Color(0xFFD4A574);
  static const Color v3CtaPrimaryFg = Color(0xFF0F0E0D);
  static Color v3CtaSecondaryBg =
      const Color(0xFFF5F2EC).withValues(alpha: 0.10);
  static Color v3CtaUnavailableBg =
      const Color(0xFFF5F2EC).withValues(alpha: 0.04);
  static Color v3CtaUnavailableFg =
      const Color(0xFFF5F2EC).withValues(alpha: 0.42);

  // Status (muted, not Netflix-red)
  static const Color v3Success = Color(0xFF9AFF9A);
  static const Color v3Warn = Color(0xFFFFD980);
}
