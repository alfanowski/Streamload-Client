// test/presentation/responsive_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/responsive.dart';

void main() {
  Future<({bool phone, bool tablet, bool desktop, bool mobile})> probe(
    WidgetTester tester,
    Size size,
  ) async {
    late bool phone, tablet, desktop, mobile;
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(size: size),
      child: Builder(builder: (ctx) {
        phone = Responsive.isPhone(ctx);
        tablet = Responsive.isTablet(ctx);
        desktop = Responsive.isDesktop(ctx);
        mobile = Responsive.isMobile(ctx);
        return const SizedBox();
      }),
    ));
    return (phone: phone, tablet: tablet, desktop: desktop, mobile: mobile);
  }

  testWidgets('phone (w=400) classifies as phone+mobile, not tablet/desktop',
      (t) async {
    final r = await probe(t, const Size(400, 800));
    expect(r.phone, isTrue);
    expect(r.tablet, isFalse);
    expect(r.desktop, isFalse);
    expect(r.mobile, isTrue);
  });

  testWidgets('exact phone breakpoint (w=600) classifies as tablet, not phone',
      (t) async {
    final r = await probe(t, const Size(600, 800));
    expect(r.phone, isFalse);
    expect(r.tablet, isTrue);
    expect(r.desktop, isFalse);
    expect(r.mobile, isTrue);
  });

  testWidgets('tablet mid-range (w=750) classifies as tablet+mobile', (t) async {
    final r = await probe(t, const Size(750, 1024));
    expect(r.phone, isFalse);
    expect(r.tablet, isTrue);
    expect(r.desktop, isFalse);
    expect(r.mobile, isTrue);
  });

  testWidgets('exact tablet breakpoint (w=900) classifies as desktop', (t) async {
    final r = await probe(t, const Size(900, 1024));
    expect(r.phone, isFalse);
    expect(r.tablet, isFalse);
    expect(r.desktop, isTrue);
    expect(r.mobile, isFalse);
  });

  testWidgets('desktop (w=1400) classifies as desktop only', (t) async {
    final r = await probe(t, const Size(1400, 900));
    expect(r.phone, isFalse);
    expect(r.tablet, isFalse);
    expect(r.desktop, isTrue);
    expect(r.mobile, isFalse);
  });
}
