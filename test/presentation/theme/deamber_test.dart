// test/presentation/theme/deamber_test.dart
//
// Pin the de-amber decision (2026-05-31): nothing in the theme renders the old
// amber/yellow. Every former amber/gold/yellow token must be the cream
// off-white #F4F4F6 — and explicitly NOT the old amber #D4A574 / yellow #FFC700.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/theme/colors.dart';
import 'package:streamload_client/presentation/theme/tokens.dart';

void main() {
  const cream = Color(0xFFF4F4F6);
  const amber = Color(0xFFD4A574);
  const yellow = Color(0xFFFFC700);

  test('StreamloadColors accents are neutral cream, not amber/yellow', () {
    expect(StreamloadColors.accent, cream);
    expect(StreamloadColors.accentHover, cream);
    expect(StreamloadColors.gold, cream);
    expect(StreamloadColors.v3CtaPrimaryBg, cream);
    expect(StreamloadColors.v3AccentYellow, cream);
    expect(StreamloadColors.v3AccentYellowHover, cream);

    for (final c in [
      StreamloadColors.accent,
      StreamloadColors.accentHover,
      StreamloadColors.gold,
      StreamloadColors.v3CtaPrimaryBg,
      StreamloadColors.v3AccentYellow,
      StreamloadColors.v3AccentYellowHover,
    ]) {
      expect(c, isNot(amber));
      expect(c, isNot(yellow));
    }
  });

  test('StreamloadTokens accent is neutral cream', () {
    expect(StreamloadTokens.accent, cream);
    expect(StreamloadTokens.accentHover, cream);
    expect(StreamloadTokens.accent, isNot(amber));
  });
}
