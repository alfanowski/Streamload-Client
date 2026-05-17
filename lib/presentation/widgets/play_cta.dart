// lib/presentation/widgets/play_cta.dart
//
// v3 primary CTA — renders one of three states:
//   - checking      : tiny spinner before the label, ~800ms typical
//                     lifetime while ProviderRouter.probeAvailability
//                     runs.
//   - play          : typographic CTA, label "Guarda →" (or custom);
//                     tappable.
//   - unavailable   : dimmed label "Al momento non disponibile" + no
//                     underline animation; non-tappable.
//
// 2026-05-17 (CM-2 / CM-4): PlayCta is now a thin wrapper around TextCta
// (the Cinema Magazine typographic CTA primitive). The pill shape +
// AnimatedContainer + InkWell + PressFeedback all live inside TextCta
// now. Callers don't need to change — the API is the same.
//
// Used in: title page header (Phase E), home hero CTA (Phase D), continue-
// watching card overlay (Phase E).
import 'package:flutter/material.dart';

import 'text_cta.dart';

enum PlayCtaState { checking, play, unavailable }

class PlayCta extends StatelessWidget {
  const PlayCta({
    super.key,
    required this.state,
    this.label = 'Guarda',
    this.onTap,
  });

  /// One of the three lifecycle states.
  final PlayCtaState state;

  /// Used only in [PlayCtaState.play]. NO leading prefix — the typographic
  /// CTA appends a trailing arrow on its own, and the play arrow is no
  /// longer baked in (editorial wants the label to read as text).
  /// Pass e.g. "Guarda", "Riprendi", "Guarda S1 E1".
  final String label;

  /// Fired in [PlayCtaState.play] only — ignored otherwise.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case PlayCtaState.checking:
        return TextCta(
          label: label,
          busy: true,
          // Don't render the trailing arrow while loading — the spinner
          // reads as the affordance for "we're working on it".
          trailing: '',
          // Busy makes TextCta non-tappable regardless of onTap.
          onTap: onTap,
        );
      case PlayCtaState.play:
        return TextCta(
          label: label,
          onTap: onTap,
        );
      case PlayCtaState.unavailable:
        return const TextCta(
          label: 'Al momento non disponibile',
          enabled: false,
          trailing: '',
        );
    }
  }
}
