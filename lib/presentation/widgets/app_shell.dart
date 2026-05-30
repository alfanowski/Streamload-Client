// lib/presentation/widgets/app_shell.dart
//
// v3 responsive shell that replaces AuthenticatedShell. On desktop / tablet
// it stacks a floating TopNavBar over the page body so heroes can render
// edge-to-edge behind the bar (the bar's bg is glass over the hero, solid
// once the page scrolls). On phone, it switches to a bottom-anchored
// StreamloadBottomTabBar — there is no top bar on phone (the spec's
// "phone shrinks the top bar" is moot once Phase D wires the per-page
// phone variants; the Profilo tab handles avatar / settings access).
//
// Note: the body content is responsible for its own top padding (~56) on
// desktop / tablet to clear the floating bar. The shell intentionally does
// not insert that padding because Home / Title pages want their hero to
// extend behind the bar; pages without a hero pad themselves explicitly.
// The phone branch wraps `child` in SafeArea(top: true) so phone pages
// don't slip under the notch.
//
// Kept side-by-side with the legacy AuthenticatedShell for now; cleanup
// removes the old one once nothing else references it.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../responsive.dart';
import '../theme/colors.dart';
import 'bottom_tab_bar.dart';
import 'mobile_top_bar.dart';
import 'search_overlay.dart';
import 'top_nav_bar.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPhone = Responsive.isPhone(context);
    if (isPhone) {
      // The player is immersive (forced landscape) — no chrome there.
      final loc = GoRouterState.of(context).matchedLocation;
      if (loc.startsWith('/watch')) {
        return Scaffold(
          backgroundColor: StreamloadColors.v3BgBase,
          body: child,
        );
      }
      return Scaffold(
        backgroundColor: StreamloadColors.v3BgBase,
        // extendBody lets the page draw behind the FLOATING glass tab bar
        // so content blurs through it (Apple iOS 26 style).
        extendBody: true,
        // Both bars FLOAT (glass): the page fills the stack and scrolls
        // under them. Pages add a top inset = StreamloadMobileTopBar.height
        // so their first elements start below the bar (then blur under it).
        body: Stack(
          children: [
            Positioned.fill(child: child),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: StreamloadMobileTopBar(),
            ),
          ],
        ),
        bottomNavigationBar: const StreamloadBottomTabBar(),
      );
    }

    return Scaffold(
      backgroundColor: StreamloadColors.v3BgBase,
      // Cmd+K (Ctrl+K on non-Mac) opens the SearchOverlay anywhere on
      // desktop / tablet. We bind both modifiers so a user moving between
      // Mac and a Windows / Linux build doesn't notice. Phone branch
      // above intentionally has no equivalent — the Cerca tab is always
      // one tap away in the bottom bar.
      body: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
              () => SearchOverlay.show(context),
          const SingleActivator(LogicalKeyboardKey.keyK, control: true):
              () => SearchOverlay.show(context),
        },
        // Focus(autofocus:true) so the CallbackShortcuts actually picks
        // up the keystroke even before the user clicks into the body.
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              // Page content fills the whole stack. Pages own their top
              // padding (~56) so heroes can extend behind the bar.
              Positioned.fill(
                child: SafeArea(top: false, child: child),
              ),
              // Floating top bar above the body.
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
