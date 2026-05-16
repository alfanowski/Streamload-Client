// lib/presentation/widgets/play_cta.dart
//
// v3 primary CTA pill — renders one of three states:
//   - checking      : spinner inside the pill, ~800ms typical lifetime while
//                     ProviderRouter.probeAvailability runs
//   - play          : enabled tappable pill, label "▶ Guarda" (or custom)
//   - unavailable   : dimmed non-tappable pill with localized
//                     "Al momento non disponibile" — the exact tone the user
//                     asked for instead of a clickable button that errors
//
// Used in: title page header (Phase E), home hero CTA (Phase D), continue-
// watching card overlay (Phase E).
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

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

  /// Used only in [PlayCtaState.play]. Receives a leading "▶ " prefix.
  /// Pass without prefix; e.g. "Guarda", "Riprendi", "Guarda S1 E1".
  final String label;

  /// Fired in [PlayCtaState.play] only — ignored otherwise.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isUnavailable = state == PlayCtaState.unavailable;
    final bg = isUnavailable
        ? StreamloadColors.v3CtaUnavailableBg
        : StreamloadColors.v3CtaPrimaryBg;
    final fg = isUnavailable
        ? StreamloadColors.v3CtaUnavailableFg
        : StreamloadColors.v3CtaPrimaryFg;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state == PlayCtaState.play ? onTap : null,
          borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            child: _content(fg),
          ),
        ),
      ),
    );
  }

  Widget _content(Color fg) {
    switch (state) {
      case PlayCtaState.checking:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(fg),
          ),
        );
      case PlayCtaState.play:
        return Text(
          '▶ $label',
          style: StreamloadTypography.v3CtaLabel(color: fg),
        );
      case PlayCtaState.unavailable:
        return Text(
          'Al momento non disponibile',
          style: StreamloadTypography.v3CtaLabel(color: fg),
        );
    }
  }
}
