// lib/presentation/widgets/avatar_menu.dart
//
// v3 desktop / tablet avatar popover that sits in the right edge of the
// TopNavBar. Tapping the 24×24 gradient avatar opens a glass-surfaced
// PopupMenu with:
//   - non-tappable user header (display name + email)
//   - Impostazioni → /settings
//   - Esci (destructive red) → authNotifier.logout()
//
// The User domain model exposes `firstName` / `lastName` (set during
// onboarding) and always-present `username` / `email`. We use the full
// first+last name when it's been filled in; otherwise we fall back to
// `username` so the popover never shows an empty string. There is no
// `User.name` getter — that distinction is explicit and load-bearing.
//
// On phone this widget is unused — the Profilo tab in
// StreamloadBottomTabBar replaces it.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/user.dart';
import '../../state/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

class AvatarMenu extends ConsumerWidget {
  const AvatarMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = switch (auth) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };

    return PopupMenuButton<_AvatarAction>(
      tooltip: 'Account',
      offset: const Offset(0, 32),
      // Pass 2B (2026-05-17): PopupMenu doesn't render an underlying
      // BackdropFilter substrate, so a real LiquidGlass surface would
      // wash out without anything to blur. We keep v3PopoverBg as the
      // near-solid dark base (carries text legibility on any page) and
      // bumping the elevation + shadow + a brighter outer rim border
      // gives the same "lifted glass card" feel without the rendering
      // pitfalls. The Liquid Glass aesthetic in the spec is applied to
      // surfaces that float over a backdrop (top/bottom nav, search
      // overlay) — popovers stay opaque on purpose.
      color: StreamloadColors.v3PopoverBg,
      elevation: 24,
      shadowColor: Colors.black.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StreamloadSpacing.chipRadius),
        side: BorderSide(
          color: StreamloadColors.v3BorderGlassStrong,
          width: 1,
        ),
      ),
      padding: EdgeInsets.zero,
      itemBuilder: (context) => <PopupMenuEntry<_AvatarAction>>[
        PopupMenuItem<_AvatarAction>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _UserHeader(user: user),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_AvatarAction>(
          value: _AvatarAction.settings,
          child: Text(
            'Impostazioni',
            style: StreamloadTypography.v3Body(
              fontSize: 13,
              color: StreamloadColors.v3TextPrimary,
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_AvatarAction>(
          value: _AvatarAction.logout,
          child: Text(
            'Esci',
            style: StreamloadTypography.v3Body(
              fontSize: 13,
              color: const Color(0xFFFF6B6B),
            ),
          ),
        ),
      ],
      onSelected: (action) async {
        switch (action) {
          case _AvatarAction.settings:
            context.go('/settings');
          case _AvatarAction.logout:
            await ref.read(authProvider.notifier).logout();
        }
      },
      child: const _AvatarDot(),
    );
  }
}

enum _AvatarAction { settings, logout }

class _AvatarDot extends StatelessWidget {
  const _AvatarDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8A5CFF), Color(0xFFFF6BB5)],
        ),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});
  final User? user;

  String get _displayName {
    final u = user;
    if (u == null) return 'Ospite';
    final first = u.firstName?.trim();
    final last = u.lastName?.trim();
    if ((first?.isNotEmpty ?? false) || (last?.isNotEmpty ?? false)) {
      return [first, last]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join(' ');
    }
    return u.username;
  }

  String get _email => user?.email ?? '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _displayName,
            style: StreamloadTypography.v3Body(
              fontSize: 13,
              color: StreamloadColors.v3TextPrimary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          if (_email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              _email,
              style: StreamloadTypography.v3MetaMono(
                color: StreamloadColors.v3TextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
