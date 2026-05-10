// lib/presentation/pages/plugin_onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../plugins/github_client.dart';
import '../../state/github_pat_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/eyebrow.dart';
import '../widgets/primary_button.dart';
import '../widgets/streamload_text_field.dart';

const _kRepoOwner = 'alfanowski';
const _kRepoName = 'streamload-plugins';

typedef PatVerifier = Future<bool> Function(String token);

Future<bool> _defaultVerifier(String token) async {
  // GithubClient's own constructor wires baseUrl + Authorization + GitHub
  // headers — passing a stripped-down dio instance here would bypass all of
  // that and the request would go out without host or auth.
  final gh = GithubClient(
    owner: _kRepoOwner,
    repo: _kRepoName,
    token: token,
  );
  return gh.verifyAccess();
}

class PluginOnboardingPage extends ConsumerStatefulWidget {
  const PluginOnboardingPage({super.key, this.verifyPat = _defaultVerifier});
  final PatVerifier verifyPat;

  @override
  ConsumerState<PluginOnboardingPage> createState() =>
      _PluginOnboardingPageState();
}

class _PluginOnboardingPageState extends ConsumerState<PluginOnboardingPage> {
  final _patCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _patCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ok = await widget.verifyPat(_patCtrl.text.trim());
      if (!ok) {
        setState(() => _error = 'Token non valido o senza accesso al repo.');
        return;
      }
      await ref
          .read(githubPatProvider.notifier)
          .save(_patCtrl.text.trim());
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = 'Verifica fallita: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Eyebrow('Pacchetto plugin'),
                const SizedBox(height: 8),
                Text(
                  'Incolla il token GitHub',
                  style: StreamloadTypography.display(fontSize: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  "L'amministratore ti ha fornito un Personal Access Token con "
                  'accesso in sola lettura al repo dei plugin. Incollalo qui sotto.',
                  style: StreamloadTypography.body(
                    fontSize: 14,
                    color: StreamloadColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                StreamloadTextField(
                  key: const Key('onboarding.pat'),
                  controller: _patCtrl,
                  label: 'GitHub PAT',
                  hint: 'github_pat_…',
                  autofocus: true,
                  obscure: true,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: StreamloadTypography.body(
                      fontSize: 13,
                      color: StreamloadColors.critical,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  key: const Key('onboarding.submit'),
                  label: _busy ? 'Verifica…' : 'Verifica e installa',
                  busy: _busy,
                  onPressed: _busy ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
