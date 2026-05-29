// lib/presentation/theme/page_transitions.dart
//
// The app's page transition: a small upward slide that settles with a
// fade — "physical, settles into place" (spec §3.4) without the cheap
// scale reveal that CM-2 rejected. Extracted as a pure function so it can
// be unit-tested and reused by every route.
import 'package:flutter/material.dart';

import 'tokens.dart';

Widget streamloadPageTransition(Animation<double> animation, Widget child) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: StreamloadTokens.standardCurve,
    reverseCurve: Curves.easeIn,
  );
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.02), // ~2% of height — subtle settle
      end: Offset.zero,
    ).animate(curved),
    child: FadeTransition(opacity: curved, child: child),
  );
}
