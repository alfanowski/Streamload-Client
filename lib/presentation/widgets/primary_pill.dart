// lib/presentation/widgets/primary_pill.dart
//
// v3 primary submit pill — the form-flow sibling of [PlayCta]. PlayCta
// became a typographic TextCta wrapper in CM-4 (Cinema Magazine pivot),
// but onboarding submits ("Verifica", "Salva", "Continua") deliberately
// KEEP the pill chrome. Why:
//
//   1. Onboarding is a one-way commitment moment — the user has filled a
//      form and needs an unambiguous "tap this to proceed" surface. A
//      typographic underline reads as a tertiary link in form contexts;
//      a pill reads as the obvious next step.
//   2. The editorial pivot quiets BROWSE surfaces (hero CTAs, row links,
//      card decorations). Onboarding is a transactional surface, not an
//      editorial one — different palette of affordances applies.
//   3. PrimaryPill still uses v3CtaPrimaryBg / v3CtaPrimaryFg, which the
//      CM-1 rebind moved to the warm amber #D4A574. The pill therefore
//      already wears the editorial palette, just in a chunkier shape.
//
// Behavior stays tiny: caller passes a label + onPressed + optional busy
// flag. Busy swaps the label for a spinner the same way PlayCta did
// before it was rewritten.
//
// Used in: PluginOnboardingPage (Verifica / Riprova), ProfileCompletionPage
// (Continua / Salvataggio…). Future onboarding-adjacent flows should reach
// for this widget instead of building a one-off FilledButton.
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'press_feedback.dart';

class PrimaryPill extends StatelessWidget {
  const PrimaryPill({
    super.key,
    required this.label,
    this.onPressed,
    this.busy = false,
    this.leadingIcon,
  });

  /// Label shown in the pill when not [busy]. Keep it short — single word
  /// or short verb phrase ("Verifica", "Salva", "Continua").
  final String label;

  /// Fired on tap. Pill becomes non-tappable + dimmed when null or when
  /// [busy] is true.
  final VoidCallback? onPressed;

  /// True swaps the label for a centered spinner the same height as the
  /// label, and disables tap input. Use during async submit.
  final bool busy;

  /// Optional leading icon (e.g. GitHub logo for the device-flow login
  /// button). Hidden while [busy].
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final disabled = busy || onPressed == null;
    final bg = disabled
        ? StreamloadColors.v3CtaUnavailableBg
        : StreamloadColors.v3CtaPrimaryBg;
    final fg = disabled
        ? StreamloadColors.v3CtaUnavailableFg
        : StreamloadColors.v3CtaPrimaryFg;

    final pill = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: _content(fg),
          ),
        ),
      ),
    );

    // Only the tappable idle state gets the press-down squeeze; busy /
    // disabled should look static and unresponsive.
    return disabled ? pill : PressFeedback(child: pill);
  }

  Widget _content(Color fg) {
    if (busy) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(fg),
        ),
      );
    }
    final text = Text(
      label,
      style: StreamloadTypography.v3CtaLabel(color: fg),
    );
    if (leadingIcon == null) return Center(child: text);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(leadingIcon, size: 16, color: fg),
        const SizedBox(width: 10),
        text,
      ],
    );
  }
}
