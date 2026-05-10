// lib/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/eyebrow.dart';
import '../widgets/primary_button.dart';
import '../widgets/streamload_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).register(
            username: _username.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = 'Registrazione fallita. Controlla i dati e riprova.');
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Eyebrow('Nuovo accesso'),
                const SizedBox(height: 8),
                Text(
                  'Crea il tuo account',
                  style: StreamloadTypography.display(fontSize: 40),
                ),
                const SizedBox(height: 32),
                StreamloadTextField(
                  key: const Key('register.username'),
                  controller: _username,
                  label: 'Username',
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                StreamloadTextField(
                  key: const Key('register.email'),
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                StreamloadTextField(
                  key: const Key('register.password'),
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
                  key: const Key('register.submit'),
                  label: _busy ? 'Creazione…' : 'Crea account',
                  busy: _busy,
                  onPressed: _busy ? null : _submit,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Hai già un account? Accedi',
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

