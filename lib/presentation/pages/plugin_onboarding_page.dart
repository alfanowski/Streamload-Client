// lib/presentation/pages/plugin_onboarding_page.dart
//
// Single-screen GitHub device-flow onboarding. After Phase I1 this page wears
// the v3 Netflix-black chrome: gradient bg → centered 480px column → big
// "STREAMLOAD" wordmark → glass card containing the state-machine view. All
// existing OAuth + auth-handoff logic is untouched; only the chrome moved.
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../plugins/github_oauth.dart';
import '../../plugins/github_oauth_config.dart';
import '../../state/auth_provider.dart';
import '../../state/github_token_provider.dart';
import '../../state/plugins_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/primary_pill.dart';

typedef OAuthFactory = GithubOAuth Function();

GithubOAuth _defaultFactory() => GithubOAuth(clientId: kGithubOAuthClientId);

enum _OnboardingState { idle, awaitingUser, error }

class PluginOnboardingPage extends ConsumerStatefulWidget {
  const PluginOnboardingPage({super.key, this.oauthFactory = _defaultFactory});
  final OAuthFactory oauthFactory;

  @override
  ConsumerState<PluginOnboardingPage> createState() =>
      _PluginOnboardingPageState();
}

class _PluginOnboardingPageState extends ConsumerState<PluginOnboardingPage> {
  _OnboardingState _state = _OnboardingState.idle;
  DeviceCodeRequest? _device;
  String? _error;
  bool _starting = false;

  Future<void> _start() async {
    setState(() {
      _state = _OnboardingState.awaitingUser;
      _starting = true;
      _error = null;
      _device = null;
    });
    final oauth = widget.oauthFactory();
    try {
      final dev = await oauth.requestDeviceCode();
      if (!mounted) return;
      setState(() {
        _device = dev;
        _starting = false;
      });
      // Open the verification page in the browser to nudge the user.
      // Wrap in try/catch — some test platforms don't have url_launcher binding.
      try {
        await launchUrl(
          Uri.parse(dev.verificationUri),
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        // Proceed even if the browser launch fails (e.g., in tests).
      }
      // Begin polling.
      final token = await oauth.pollForToken(
        deviceCode: dev.deviceCode,
        interval: dev.pollInterval,
        timeout: dev.expiresIn,
      );
      if (!mounted) return;
      // Save the token.
      await ref.read(githubTokenProvider.notifier).save(token);
      // Exchange the GitHub token for a backend session.
      final user = await ref.read(authProvider.notifier).loginWithGithub(token);
      // Plugin refresh in background regardless.
      // ignore: unawaited_futures
      unawaited(ref.read(pluginRefreshControllerProvider.notifier).refresh());
      if (!mounted) return;
      context.go(user.profileComplete ? '/home' : '/onboarding/profile');
    } on DeviceFlowDenied {
      _setError("Hai annullato l'accesso. Riprova quando vuoi.");
    } on DeviceFlowExpired {
      _setError('Il codice è scaduto. Riprova.');
    } catch (e) {
      _setError('Errore: $e');
    }
  }

  void _setError(String msg) {
    if (!mounted) return;
    setState(() {
      _state = _OnboardingState.error;
      _starting = false;
      _error = msg;
    });
  }

  Future<void> _copyCode() async {
    if (_device == null) return;
    try {
      await Clipboard.setData(ClipboardData(text: _device!.userCode));
    } catch (_) {
      // Proceed even if clipboard is unavailable (e.g., in some test envs).
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Codice copiato')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final hPad = isPhone
        ? StreamloadSpacing.pagePaddingPhone.horizontal / 2
        : 32.0;
    return Scaffold(
      backgroundColor: StreamloadColors.v3BgBase,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              StreamloadColors.v3BgGradientStart,
              StreamloadColors.v3BgGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _Wordmark(),
                    const SizedBox(height: 32),
                    _GlassCard(
                      child: switch (_state) {
                        _OnboardingState.idle => _IdleView(
                            busy: _starting,
                            onStart: _start,
                          ),
                        _OnboardingState.awaitingUser => _AwaitingView(
                            device: _device,
                            onCopy: _copyCode,
                          ),
                        _OnboardingState.error => _ErrorView(
                            message: _error ?? '',
                            onRetry: () {
                              setState(() {
                                _state = _OnboardingState.idle;
                                _starting = false;
                                _error = null;
                                _device = null;
                              });
                            },
                          ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Big white STREAMLOAD wordmark — Inter ExtraBold / tight tracking, the same
/// brand glyph the top nav uses but scaled up for the onboarding hero slot.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'STREAMLOAD',
        style: StreamloadTypography.v3CtaLabel(
          color: StreamloadColors.v3TextPrimary,
        ).copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

/// Translucent card with rounded corners + a backdrop blur. Mirrors the
/// settings page _SectionCard surface so onboarding feels like the same UI.
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
            padding: const EdgeInsets.all(28),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: StreamloadTypography.v3LabelMono(),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.busy, required this.onStart});

  final bool busy;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Eyebrow('Pacchetto plugin'),
        const SizedBox(height: 12),
        Text(
          'Accedi con GitHub',
          style: StreamloadTypography.v3DisplayPage(),
        ),
        const SizedBox(height: 12),
        Text(
          'Streamload usa GitHub per autenticarti e — se sei stato invitato — '
          'scaricare il pacchetto plugin. Se non hai invito, '
          'potrai comunque sfogliare il catalogo.',
          style: StreamloadTypography.v3Body(
            fontSize: 13,
            color: StreamloadColors.v3TextMuted,
          ),
        ),
        const SizedBox(height: 24),
        PrimaryPill(
          key: const Key('onboarding.github_login'),
          label: 'Accedi con GitHub',
          busy: busy,
          onPressed: busy ? null : onStart,
        ),
      ],
    );
  }
}

class _AwaitingView extends StatelessWidget {
  const _AwaitingView({required this.device, required this.onCopy});

  final DeviceCodeRequest? device;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    if (device == null) {
      // Brief moment between "tap accedi" and "device code arrives". Keep
      // the glass card sized so the layout doesn't snap.
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Eyebrow('Autorizzazione'),
        const SizedBox(height: 12),
        Text(
          'Inserisci il codice',
          style: StreamloadTypography.v3DisplayPage(),
        ),
        const SizedBox(height: 12),
        Text(
          'Apri ${device!.verificationUri} (dovrebbe già essersi aperto) '
          'e incolla questo codice:',
          style: StreamloadTypography.v3Body(
            fontSize: 13,
            color: StreamloadColors.v3TextMuted,
          ),
        ),
        const SizedBox(height: 20),
        // Code chip — sharp dark surface, white monospace, wide letter
        // spacing so the operator can read the 8-char code aloud easily.
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF000000).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(StreamloadSpacing.chipRadius),
            border: Border.all(color: StreamloadColors.v3BorderGlass),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Center(
              child: Text(
                device!.userCode,
                key: const Key('onboarding.user_code'),
                style: StreamloadTypography.v3MetaMono(
                  color: StreamloadColors.v3TextPrimary,
                ).copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Copy button — secondary glass pill, distinct from the primary
        // CTA so the operator doesn't confuse it for "Continua".
        Align(
          alignment: Alignment.center,
          child: TextButton.icon(
            key: const Key('onboarding.copy_code'),
            onPressed: onCopy,
            icon: Icon(
              Icons.copy,
              size: 14,
              color: StreamloadColors.v3TextSecondary,
            ),
            label: Text(
              'Copia codice',
              style: StreamloadTypography.v3CtaLabel(
                color: StreamloadColors.v3TextSecondary,
              ),
            ),
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'In attesa di autorizzazione…',
          textAlign: TextAlign.center,
          style: StreamloadTypography.v3MetaMono(),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Eyebrow('Errore'),
        const SizedBox(height: 12),
        Text(
          message,
          style: StreamloadTypography.v3Body(
            fontSize: 14,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 24),
        PrimaryPill(
          key: const Key('onboarding.retry'),
          label: 'Riprova',
          onPressed: onRetry,
        ),
      ],
    );
  }
}
