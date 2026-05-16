// lib/state/nav_scrolled_provider.dart
//
// Tracks whether any page-level scroll view has crossed the ~80px threshold
// that switches the top nav bar from glass (translucent) to solid. Pages own
// the listener that flips this — see HomePage / TitlePage body builders
// (Phase D / E will wire those). The provider itself is a plain
// StateProvider<bool> so any widget can read/write without ceremony.
//
// Defaults to false (translucent / glass) so freshly opened pages start
// with the cinematic over-hero look until the user scrolls.
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navScrolledProvider = StateProvider<bool>((ref) => false);
