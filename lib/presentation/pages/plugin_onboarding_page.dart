// lib/presentation/pages/plugin_onboarding_page.dart
import 'dart:async';

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
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/eyebrow.dart';
import '../widgets/primary_button.dart';

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

  Future<void> _start() async {
    setState(() {
      _state = _OnboardingState.awaitingUser;
      _error = null;
      _device = null;
    });
    final oauth = widget.oauthFactory();
    try {
      final dev = await oauth.requestDeviceCode();
      if (!mounted) return;
      setState(() => _device = dev);
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
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: switch (_state) {
              _OnboardingState.idle => _IdleView(onStart: _start),
              _OnboardingState.awaitingUser => _AwaitingView(
                  device: _device,
                  onCopy: _copyCode,
                ),
              _OnboardingState.error => _ErrorView(
                  message: _error ?? '',
                  onRetry: () {
                    setState(() {
                      _state = _OnboardingState.idle;
                      _error = null;
                      _device = null;
                    });
                  },
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Eyebrow('Pacchetto plugin'),
        const SizedBox(height: 8),
        Text(
          'Accedi con GitHub',
          style: StreamloadTypography.display(fontSize: 36),
        ),
        const SizedBox(height: 12),
        Text(
          'Streamload usa GitHub per autenticarti e — se sei stato invitato — '
          'scaricare il pacchetto plugin. Se non hai invito, '
          'potrai comunque sfogliare il catalogo.',
          style: StreamloadTypography.body(
            fontSize: 14,
            color: StreamloadColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          key: const Key('onboarding.github_login'),
          label: 'Accedi con GitHub',
          onPressed: onStart,
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
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Eyebrow('Autorizzazione'),
        const SizedBox(height: 8),
        Text(
          'Inserisci il codice',
          style: StreamloadTypography.display(fontSize: 32),
        ),
        const SizedBox(height: 12),
        Text(
          'Apri ${device!.verificationUri} (dovrebbe già essersi aperto) '
          'e incolla questo codice:',
          style: StreamloadTypography.body(fontSize: 14),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: StreamloadColors.surface2,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            device!.userCode,
            key: const Key('onboarding.user_code'),
            style: StreamloadTypography.mono(fontSize: 32, letterSpacing: 4),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          key: const Key('onboarding.copy_code'),
          onPressed: onCopy,
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copia codice'),
        ),
        const SizedBox(height: 24),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 8),
        Text(
          'In attesa di autorizzazione…',
          textAlign: TextAlign.center,
          style: StreamloadTypography.body(
            fontSize: 12,
            color: StreamloadColors.textSecondary,
          ),
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
        const Eyebrow('Errore'),
        const SizedBox(height: 8),
        Text(
          message,
          style: StreamloadTypography.body(
            fontSize: 14,
            color: StreamloadColors.critical,
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          key: const Key('onboarding.retry'),
          label: 'Riprova',
          onPressed: onRetry,
        ),
      ],
    );
  }
}
