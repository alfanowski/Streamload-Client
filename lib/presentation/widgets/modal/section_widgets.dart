// lib/presentation/widgets/modal/section_widgets.dart
//
// Small editorial primitives shared by the full-screen modals (title page,
// person page): a Fraunces section header and an expandable, justified body
// paragraph ("Altro" / "Riduci").
import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: StreamloadTypography.display(fontSize: 22, italic: false)
          .copyWith(color: StreamloadColors.v3TextPrimary),
    );
  }
}

class ExpandableText extends StatefulWidget {
  const ExpandableText(this.text, {super.key, this.collapsedLines = 5});
  final String text;
  final int collapsedLines;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style =
        StreamloadTypography.v3Body(fontSize: 16).copyWith(height: 1.6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Text(
            widget.text,
            style: style,
            textAlign: TextAlign.justify,
            maxLines: _expanded ? null : widget.collapsedLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Text(
            _expanded ? 'Riduci' : 'Altro',
            style: StreamloadTypography.v3Body(
              fontSize: 14,
              color: StreamloadColors.v3TextSecondary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
