import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/theme/tokens.dart';

void main() {
  group('StreamloadTokens', () {
    test('primary CTA is neutral off-white, accent is the discreet amber', () {
      expect(StreamloadTokens.ctaPrimaryBg, const Color(0xFFF4F4F6));
      expect(StreamloadTokens.ctaPrimaryFg, const Color(0xFF0E0E10));
      expect(StreamloadTokens.accent, const Color(0xFFD4A574));
    });

    test('background is neutral near-black', () {
      expect(StreamloadTokens.bg, const Color(0xFF0E0E10));
    });

    test('canonical breakpoints: phone 600, desktop 1024', () {
      expect(StreamloadTokens.bpPhone, 600);
      expect(StreamloadTokens.bpDesktop, 1024);
    });

    test('spacing follows a 4pt scale', () {
      expect(StreamloadTokens.space2, 8);
      expect(StreamloadTokens.space4, 16);
      expect(StreamloadTokens.space16, 64);
    });

    test('motion exposes a tactile spring curve and durations', () {
      expect(StreamloadTokens.springCurve, isA<Curve>());
      expect(StreamloadTokens.tap, const Duration(milliseconds: 110));
    });
  });
}
