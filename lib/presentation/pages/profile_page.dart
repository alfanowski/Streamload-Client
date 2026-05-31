// lib/presentation/pages/profile_page.dart
//
// Profile — the platform's account screen, in the v3 style: a GitHub avatar
// hero, structured account info, a list of (coming-soon) settings, and a clean
// "Esci". No amber.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/user.dart';
import '../../state/auth_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/modal/section_widgets.dart';
import '../widgets/press_feedback.dart';

const Color _logoutColor = Color(0xFFE5677A);

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = switch (auth) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };
    final pad = Responsive.isPhone(context)
        ? StreamloadSpacing.pagePaddingPhone
        : StreamloadSpacing.pagePaddingDesktop;

    return Scaffold(
      backgroundColor: StreamloadColors.v3BgBase,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad.left, 8, pad.right, 120),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 14),
                  child: Text(
                    'Profilo',
                    style: StreamloadTypography.display(
                            fontSize: 30, italic: false)
                        .copyWith(color: StreamloadColors.v3TextPrimary),
                  ),
                ),
                _ProfileHero(user: user),
                const SizedBox(height: 34),
                _AccountSection(user: user),
                const SizedBox(height: 36),
                const _SettingsSection(),
                const SizedBox(height: 36),
                _LogoutButton(
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/onboarding/github');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero (avatar + name) ───────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    final name = _displayName(user);
    final gh = user?.githubUsername;
    return Column(
      children: [
        _Avatar(githubUsername: gh, fallbackName: name),
        const SizedBox(height: 18),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: StreamloadTypography.v3DisplayHero().copyWith(fontSize: 26),
        ),
        if (gh != null && gh.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '@$gh',
            style: StreamloadTypography.v3Body(
              fontSize: 13.5,
              color: StreamloadColors.v3TextSecondary,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.githubUsername, required this.fallbackName});
  final String? githubUsername;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    const d = 108.0;
    final initials = _initials(fallbackName);
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StreamloadColors.v3SurfaceGlassHi,
            StreamloadColors.v3SurfaceGlass,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: StreamloadTypography.v3DisplayHero().copyWith(fontSize: 38),
        ),
      ),
    );
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: StreamloadColors.v3BorderGlass, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: (githubUsername != null && githubUsername!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: 'https://github.com/$githubUsername.png?size=220',
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    ColoredBox(color: StreamloadColors.v3SurfaceGlass),
                errorWidget: (_, __, ___) => fallback,
              )
            : fallback,
      ),
    );
  }
}

// ── Account info ───────────────────────────────────────────────────────────

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Account'),
        const SizedBox(height: 16),
        _InfoRow(label: 'Username', value: user?.username ?? '—'),
        _InfoRow(label: 'Email', value: user?.email ?? '—'),
        if ((user?.githubUsername ?? '').isNotEmpty)
          _InfoRow(label: 'GitHub', value: '@${user!.githubUsername}'),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: StreamloadTypography.v3Body(
              fontSize: 12.5,
              color: StreamloadColors.v3TextMuted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: StreamloadTypography.v3Body(fontSize: 16)
                .copyWith(color: StreamloadColors.v3TextPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Settings (coming soon) ─────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  static const _items = <(IconData, String)>[
    (Icons.notifications_none_rounded, 'Notifiche'),
    (Icons.palette_outlined, 'Aspetto'),
    (Icons.translate_rounded, 'Lingua'),
    (Icons.high_quality_outlined, 'Qualità di riproduzione'),
    (Icons.extension_outlined, 'Plugin e sorgenti'),
    (Icons.lock_outline_rounded, 'Privacy e sicurezza'),
    (Icons.info_outline_rounded, 'Aiuto e info'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Impostazioni'),
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            color: StreamloadColors.v3SurfaceGlass,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: StreamloadColors.v3BorderGlass),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    indent: 62,
                    color: StreamloadColors.v3BorderGlass,
                  ),
                _SettingRow(icon: _items[i].$1, label: _items[i].$2),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Coming soon → dimmed + a "Presto" chip, not tappable.
    return Opacity(
      opacity: 0.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: StreamloadColors.v3SurfaceGlassHi,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon,
                  color: StreamloadColors.v3TextSecondary, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: StreamloadTypography.v3Body(fontSize: 15).copyWith(
                  color: StreamloadColors.v3TextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const _SoonChip(),
          ],
        ),
      ),
    );
  }
}

class _SoonChip extends StatelessWidget {
  const _SoonChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: StreamloadColors.v3SurfaceGlassHi,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: StreamloadColors.v3BorderGlass),
      ),
      child: Text(
        'Presto',
        style: StreamloadTypography.v3Body(
          fontSize: 11,
          color: StreamloadColors.v3TextMuted,
        ).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.3),
      ),
    );
  }
}

// ── Logout ─────────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return PressFeedback(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _logoutColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _logoutColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout_rounded, color: _logoutColor, size: 19),
              const SizedBox(width: 9),
              Text(
                'Esci',
                style: StreamloadTypography.v3Body(fontSize: 16).copyWith(
                  color: _logoutColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

String _displayName(User? user) {
  if (user == null) return '—';
  final fn = (user.firstName ?? '').trim();
  final ln = (user.lastName ?? '').trim();
  final full = [fn, ln].where((s) => s.isNotEmpty).join(' ');
  if (full.isNotEmpty) return full;
  return user.username;
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}
