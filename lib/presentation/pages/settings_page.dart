// lib/presentation/pages/settings_page.dart
//
// v3 Settings page (Phase H1 + H2). Per spec decision #3 the page is
// completely silent about plugins — no installed-plugins list, no
// "Aggiorna pacchetto plugin" button, no "Cambia token GitHub" link.
// Plugin updates run in the background (lib/plugins/updater.dart);
// onboarding stays a first-run flow.
//
// Sections, top to bottom:
//   1. Account     — avatar + display name + email + logout
//   2. Aspetto     — Tema / Lingua, both locked ("In arrivo")
//   3. Riproduzione — Audio preferito + Sottotitoli preferiti dropdowns
//                     persisted via playbackPrefsProvider
//   4. About       — version (package_info_plus), GitHub repo link,
//                     license
//   5. Sviluppatore (conditional) — visible only when built with
//      --dart-define=DEBUG_PLUGINS=true. Releases never see it.
//
// All interactive controls are wrapped in PressFeedback per v3 spec.
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/user.dart';
import '../../state/auth_provider.dart';
import '../../state/github_token_provider.dart';
import '../../state/playback_prefs_provider.dart';
import '../../state/plugins_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/press_feedback.dart';
import '../widgets/top_nav_bar.dart';

/// Build-time flag. Set `--dart-define=DEBUG_PLUGINS=true` to surface the
/// developer section in the Settings page. Defaults to false so release
/// + most dev builds keep the UI completely silent about plugins.
const bool kDebugPlugins =
    bool.fromEnvironment('DEBUG_PLUGINS', defaultValue: false);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const String _githubRepoUrl = 'https://github.com/alfanowski/streamload';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPhone = Responsive.isPhone(context);
    // Reserve room for the floating TopNavBar on desktop / tablet so the
    // first section header doesn't slip behind it. Phone shells don't
    // have the top bar (it's a bottom tab bar instead).
    final topPad = isPhone ? 16.0 : TopNavBar.height + 24.0;
    final horizontalPad = isPhone
        ? StreamloadSpacing.pagePaddingPhone.horizontal / 2
        : StreamloadSpacing.pagePaddingDesktop.horizontal / 2;

    final auth = ref.watch(authProvider);
    final user = switch (auth) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };

    // Material(type:transparency) so the AppShell Scaffold's bg shows
    // through but child widgets (DropdownButton, InkWell) still find a
    // Material ancestor. SearchPage uses the same idiom.
    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: StreamloadColors.v3BgBase),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPad,
            topPad,
            horizontalPad,
            48,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PageTitle(),
                  const SizedBox(height: 24),
                  _AccountSection(user: user),
                  const SizedBox(height: 24),
                  const _AspettoSection(),
                  const SizedBox(height: 24),
                  const _RiproduzioneSection(),
                  const SizedBox(height: 24),
                  const _AboutSection(repoUrl: _githubRepoUrl),
                  if (kDebugPlugins) ...[
                    const SizedBox(height: 24),
                    const _SviluppatoreSection(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Page title
// ────────────────────────────────────────────────────────────────────────────

class _PageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'Impostazioni',
        style: StreamloadTypography.v3DisplayPage(),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Generic helpers — section card + header + locked row
// ────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.header, required this.children});

  final String header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            header.toUpperCase(),
            style: StreamloadTypography.v3LabelMono(),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: StreamloadColors.v3SurfaceGlass,
            borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadiusLarge),
            border: Border.all(color: StreamloadColors.v3BorderGlass),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadiusLarge),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.label, required this.subtitle});

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: StreamloadTypography.v3Body(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: StreamloadTypography.v3MetaMono(),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.lock_outline,
              size: 16,
              color: StreamloadColors.v3TextMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Account
// ────────────────────────────────────────────────────────────────────────────

class _AccountSection extends ConsumerWidget {
  const _AccountSection({required this.user});

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

  String? get _avatarUrl {
    final gh = user?.githubUsername;
    if (gh == null || gh.isEmpty) return null;
    return 'https://github.com/$gh.png?size=128';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      header: 'Account',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Avatar(url: _avatarUrl, fallbackSeed: _displayName),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName,
                    style: StreamloadTypography.v3Body(
                      fontSize: 18,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  if ((user?.email ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user!.email,
                      style: StreamloadTypography.v3MetaMono(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _LogoutButton(),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.fallbackSeed});

  final String? url;
  final String fallbackSeed;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    final fallback = _GradientCircle(seed: fallbackSeed, size: size);
    if (url == null) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}

class _GradientCircle extends StatelessWidget {
  const _GradientCircle({required this.seed, required this.size});

  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Pull two anchor colors from the seed string so the same name always
    // gets the same gradient. Keeps the avatar identifiable even with no
    // GitHub image cached.
    final hash = seed.hashCode;
    final hue1 = (hash & 0xFF) / 255.0 * 360;
    final hue2 = ((hash >> 8) & 0xFF) / 255.0 * 360;
    final c1 = HSVColor.fromAHSV(1.0, hue1, 0.5, 0.85).toColor();
    final c2 = HSVColor.fromAHSV(1.0, hue2, 0.5, 0.65).toColor();
    final initial = seed.isNotEmpty ? seed.characters.first.toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c2],
        ),
      ),
      child: Text(
        initial,
        style: StreamloadTypography.v3Body(fontSize: 22)
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PressFeedback(
      child: Material(
        color: const Color(0xFFF26B5E).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
        child: InkWell(
          // Just clear the auth state. The router's refresh listener
          // (lib/router.dart) reacts to the AuthState change and bounces
          // the user back to /onboarding/github automatically — matching
          // AvatarMenu's logout flow on desktop.
          onTap: () => ref.read(authProvider.notifier).logout(),
          borderRadius: BorderRadius.circular(StreamloadSpacing.pillRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'Esci',
                style: StreamloadTypography.v3CtaLabel(
                  color: const Color(0xFFF26B5E),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Aspetto (locked)
// ────────────────────────────────────────────────────────────────────────────

class _AspettoSection extends StatelessWidget {
  const _AspettoSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      header: 'Aspetto',
      children: [
        _LockedRow(label: 'Tema', subtitle: 'In arrivo'),
        SizedBox(height: 4),
        _LockedRow(label: 'Lingua', subtitle: 'In arrivo'),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Riproduzione (writes through playbackPrefsProvider)
// ────────────────────────────────────────────────────────────────────────────

class _RiproduzioneSection extends ConsumerWidget {
  const _RiproduzioneSection();

  static const _audioOptions = [
    ('it', 'Italiano'),
    ('en', 'Inglese'),
    ('ja', 'Giapponese'),
    ('original', 'Originale'),
    ('off', 'Disattivato'),
  ];

  static const _subtitleOptions = [
    ('off', 'Disattivati'),
    ('it', 'Italiano'),
    ('en', 'Inglese'),
    ('same', "Stesso dell'audio"),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(playbackPrefsProvider);
    return _SectionCard(
      header: 'Riproduzione',
      children: prefsAsync.when(
        loading: () => const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
        error: (e, _) => [
          Text(
            'Errore: $e',
            style: StreamloadTypography.v3Body(
              fontSize: 13,
              color: StreamloadColors.critical,
            ),
          ),
        ],
        data: (prefs) => [
          _DropdownRow(
            key: const Key('settings.audio_lang'),
            label: 'Audio preferito',
            value: prefs.audioLang,
            options: _audioOptions,
            onChanged: (v) => ref
                .read(playbackPrefsProvider.notifier)
                .setAudioLang(v),
          ),
          const SizedBox(height: 4),
          _DropdownRow(
            key: const Key('settings.subtitle_lang'),
            label: 'Sottotitoli preferiti',
            value: prefs.subtitleLang,
            options: _subtitleOptions,
            onChanged: (v) => ref
                .read(playbackPrefsProvider.notifier)
                .setSubtitleLang(v),
          ),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<(String, String)> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: StreamloadTypography.v3Body(fontSize: 14),
            ),
          ),
          PressFeedback(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                dropdownColor: const Color(0xFF1A1A1F),
                style: StreamloadTypography.v3Body(fontSize: 13),
                items: [
                  for (final (code, label) in options)
                    DropdownMenuItem(value: code, child: Text(label)),
                ],
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// About
// ────────────────────────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.repoUrl});

  final String repoUrl;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      header: 'About',
      children: [
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snap) {
            final version = snap.data?.version ?? '—';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Streamload v$version',
                style: StreamloadTypography.v3Body(fontSize: 14)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _RepoLinkRow(url: repoUrl),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Licenza MIT',
            style: StreamloadTypography.v3MetaMono(),
          ),
        ),
      ],
    );
  }
}

class _RepoLinkRow extends StatelessWidget {
  const _RepoLinkRow({required this.url});

  final String url;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(url);
    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copiato negli appunti')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PressFeedback(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Repository GitHub',
                    style: StreamloadTypography.v3Body(fontSize: 14),
                  ),
                ),
                Icon(
                  Icons.arrow_outward,
                  size: 16,
                  color: StreamloadColors.v3TextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Sviluppatore (DEBUG_PLUGINS only)
// ────────────────────────────────────────────────────────────────────────────

class _SviluppatoreSection extends ConsumerWidget {
  const _SviluppatoreSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshState = ref.watch(pluginRefreshControllerProvider);
    final tokenState = ref.watch(githubTokenProvider);
    final tokenStatus = tokenState.maybeWhen(
      data: (t) => (t != null && t.isNotEmpty) ? 'impostato' : 'non impostato',
      orElse: () => '…',
    );
    final refreshLabel = refreshState.maybeWhen(
      loading: () => 'Aggiornamento in corso…',
      data: (s) => s.toString(),
      error: (e, _) => 'Errore: $e',
      orElse: () => '—',
    );
    return _SectionCard(
      header: 'Sviluppatore',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Ultimo refresh plugin',
            style: StreamloadTypography.v3MetaMono(),
          ),
        ),
        Text(
          refreshLabel,
          style: StreamloadTypography.v3Body(fontSize: 13),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'GitHub PAT',
            style: StreamloadTypography.v3MetaMono(),
          ),
        ),
        Text(
          tokenStatus,
          style: StreamloadTypography.v3Body(fontSize: 13),
        ),
        const SizedBox(height: 16),
        PressFeedback(
          child: Material(
            color: StreamloadColors.v3CtaSecondaryBg,
            borderRadius:
                BorderRadius.circular(StreamloadSpacing.pillRadius),
            child: InkWell(
              onTap: refreshState is AsyncLoading
                  ? null
                  : () => ref
                      .read(pluginRefreshControllerProvider.notifier)
                      .refresh(),
              borderRadius:
                  BorderRadius.circular(StreamloadSpacing.pillRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Forza aggiornamento plugin',
                    style: StreamloadTypography.v3CtaLabel(
                      color: StreamloadColors.v3TextPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
