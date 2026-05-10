// lib/presentation/widgets/eyebrow.dart
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// Small uppercase mono label used as a section/page eyebrow.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: StreamloadTypography.mono(
        fontSize: 11,
        color: color ?? StreamloadColors.textTertiary,
      ),
    );
  }
}
