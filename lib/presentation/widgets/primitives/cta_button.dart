// lib/presentation/widgets/primitives/cta_button.dart
//
// The app's pill CTA, matching the approved "Cinematic Premium" mockup:
//   - filled   → cream-white fill (#F5F2EC) + near-black label (primary Play)
//   - ghost    → transparent + hairline border (secondary, e.g. La mia lista)
//
// PressFeedback squeeze on tap; dims + goes inert when onTap is null.
import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../press_feedback.dart';

class CtaButton extends StatelessWidget {
  const CtaButton({
    super.key,
    required this.label,
    this.leading,
    this.onTap,
    this.filled = true,
    this.block = false,
  });

  final String label;

  /// Optional leading glyph (e.g. '▶' or '＋').
  final String? leading;
  final VoidCallback? onTap;
  final bool filled;

  /// Full-width with centered content (used for stacked mobile CTAs).
  final bool block;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = filled ? StreamloadTokens.ctaPrimaryFg : StreamloadTokens.textPrimary;

    final content = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          block ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (leading != null) ...[
          Text(
            leading!,
            style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );

    final pill = Container(
      key: ValueKey(filled ? 'cta-fill' : 'cta-ghost'),
      width: block ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: filled ? StreamloadTokens.ctaPrimaryBg : Colors.transparent,
        borderRadius: BorderRadius.circular(StreamloadTokens.radiusPill),
        border: filled ? null : Border.all(color: StreamloadTokens.borderStrong),
      ),
      child: content,
    );

    return PressFeedback(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(opacity: enabled ? 1.0 : 0.45, child: pill),
      ),
    );
  }
}
