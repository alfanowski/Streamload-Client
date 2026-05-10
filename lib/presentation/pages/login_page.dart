// lib/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/eyebrow.dart';
import '../widgets/primary_button.dart';
import '../widgets/streamload_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).login(
            username: _username.text.trim(),
            password: _password.text,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = 'Credenziali non valide');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Eyebrow('Cinema privato'),
                const SizedBox(height: 8),
                Text(
                  'Streamload',
                  style: StreamloadTypography.display(fontSize: 56),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bentornato. Accedi per riprendere a guardare.',
                  style: StreamloadTypography.body(
                    fontSize: 14,
                    color: StreamloadColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                StreamloadTextField(
                  key: const Key('login.username'),
                  controller: _username,
                  label: 'Username o email',
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                StreamloadTextField(
                  key: const Key('login.password'),
                  controller: _password,
                  label: 'Password',
                  obscure: true,
                  onSubmitted: (_) => _submit(),
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
                  key: const Key('login.submit'),
                  label: _busy ? 'Accesso…' : 'Accedi',
                  busy: _busy,
                  onPressed: _busy ? null : _submit,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(
                      'Crea un account',
                      style: StreamloadTypography.body(
                        fontSize: 13,
                        color: StreamloadColors.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
