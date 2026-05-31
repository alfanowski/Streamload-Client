// lib/presentation/theme/page_transitions.dart
//
// The app's page transition: a smooth CROSS-FADE with a barely-there scale
// settle. The old version slid up ~2% of the screen, which read as an abrupt
// vertical "push" when switching tabs (Home ↔ Cerca). A pure fade + a 0.985→1
// scale glides instead — both the outgoing and incoming pages fade through
// each other (the Navigator drives the outgoing page's animation in reverse),
// so lateral tab switches feel seamless. Pure function so it stays testable.
import 'package:flutter/material.dart';

import 'tokens.dart';

Widget streamloadPageTransition(Animation<double> animation, Widget child) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: StreamloadTokens.standardCurve,
    reverseCurve: Curves.easeInCubic,
  );
  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
      child: child,
    ),
  );
}
