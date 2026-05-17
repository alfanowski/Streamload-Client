// lib/presentation/widgets/text_cta.dart
//
// Typographic CTA — the Cinema Magazine replacement for pill-shaped
// PlayCta / "＋ La mia lista". Renders a plain text label (optionally
// prefixed by a leading glyph like "▶" / "＋" / "↗") with an underline
// that grows from 0 → full width on hover (250 ms ease-out) and a
// PressFeedback squeeze on tap.
//
// States:
//   - enabled (onTap != null)    : label in v3TextPrimary; hover grows
//                                   underline; PressFeedback active.
//   - busy (busy: true)          : 12 px CircularProgressIndicator before
//                                   the label; non-tappable; underline
//                                   doesn't animate (it's busy).
//   - disabled (enabled: false)  : label dimmed to v3TextMuted; no hover
//                                   underline; non-tappable.
//
// On phones (Responsive.isMobile) there's no MouseRegion hover so the
// underline lives at its full width permanently — keeps a touch-target
// affordance that desktop users get on hover.
//
// Used by HeroSlide / TitleHero CTAs (CM-4, CM-5, CM-6). Onboarding
// kept PrimaryPill because submit-affordance is more legible as a
// chunky pill than a typographic line.
import 'package:flutter/material.dart';

import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'press_feedback.dart';

class TextCta extends StatefulWidget {
  const TextCta({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.enabled = true,
    this.busy = false,
    this.dimWhenDisabled = true,
    this.trailing = '→',
  });

  /// Visible label text. Keep it short — "Guarda", "Riprendi",
  /// "La mia lista", "Condividi".
  final String label;

  /// Tap handler. When null OR [enabled] is false the CTA is
  /// non-tappable + the underline doesn't animate.
  final VoidCallback? onTap;

  /// Optional leading glyph (e.g. "▶" / "＋" / "↗" / "✓"). Rendered
  /// before the label with an 8 px gap. Pass null for no leading.
  final String? leading;

  /// When false the label is dimmed to [StreamloadColors.v3TextMuted]
  /// (if [dimWhenDisabled]) and the CTA is non-tappable.
  final bool enabled;

  /// When true a tiny inline spinner renders before the label and the
  /// CTA is non-tappable. Use for "availability probe loading" hints —
  /// the hero CTA shows this while the probe is in flight.
  final bool busy;

  /// When false a disabled CTA keeps the primary text color. Useful for
  /// CTAs that need to read as "still meaningful, just not tappable".
  final bool dimWhenDisabled;

  /// Optional trailing glyph appended to the label. Defaults to a
  /// right-arrow because most editorial CTAs benefit from a directional
  /// hint. Pass empty string ('') to suppress.
  final String trailing;

  @override
  State<TextCta> createState() => _TextCtaState();
}

class _TextCtaState extends State<TextCta> {
  bool _hovering = false;

  bool get _interactive =>
      widget.enabled && !widget.busy && widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    // On mobile the underline lives at its full width — there's no
    // hover event to grow it. Editorial still, no animation.
    final showFullUnderline = _interactive && (isMobile || _hovering);

    final color = !widget.enabled && widget.dimWhenDisabled
        ? StreamloadColors.v3TextMuted
        : StreamloadColors.v3TextPrimary;

    final label = widget.trailing.isEmpty
        ? widget.label
        : '${widget.label} ${widget.trailing}';

    final children = <Widget>[];
    if (widget.busy) {
      children.add(SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ));
      children.add(const SizedBox(width: 10));
    } else if (widget.leading != null && widget.leading!.isNotEmpty) {
      children.add(Text(
        widget.leading!,
        style: StreamloadTypography.body(
          fontSize: 14,
          weight: FontWeight.w500,
          color: color,
        ),
      ));
      children.add(const SizedBox(width: 8));
    }
    children.add(Flexible(
      child: Text(
        label,
        style: StreamloadTypography.body(
          fontSize: 14,
          weight: FontWeight.w500,
          color: color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ));

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        // The underline lives under the WHOLE row (leading + label +
        // trailing). We can't measure the row's exact width without an
        // overflow guard, so we let it stretch to the row's intrinsic
        // width via a Column[Row, Underline] pattern.
        return IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
              const SizedBox(height: 4),
              // The underline. Grows from a 0-width centered bar to a
              // full-width hairline on hover. Disabled / busy CTAs hide
              // it entirely (no growth animation runs).
              AnimatedAlign(
                alignment: Alignment.centerLeft,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  height: 1,
                  width: showFullUnderline ? double.infinity : 0,
                  color: color.withValues(
                    alpha: !widget.enabled && widget.dimWhenDisabled ? 0 : 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!_interactive) {
      // Wrap in MouseRegion only to surface the not-allowed cursor on
      // disabled/busy states — keeps the affordance honest.
      return MouseRegion(
        cursor: widget.busy
            ? SystemMouseCursors.progress
            : SystemMouseCursors.basic,
        child: content,
      );
    }

    content = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!_hovering) setState(() => _hovering = true);
      },
      onExit: (_) {
        if (_hovering) setState(() => _hovering = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: content,
      ),
    );
    return PressFeedback(child: content);
  }
}
