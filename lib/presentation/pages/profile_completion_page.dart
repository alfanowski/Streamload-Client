// lib/presentation/pages/profile_completion_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../state/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/eyebrow.dart';
import '../widgets/primary_button.dart';
import '../widgets/streamload_text_field.dart';

const _genderOptions = [
  ('male', 'Maschio'),
  ('female', 'Femmina'),
  ('non_binary', 'Non binario'),
  ('prefer_not_to_say', 'Preferisco non dirlo'),
];

class ProfileCompletionPage extends ConsumerStatefulWidget {
  const ProfileCompletionPage({super.key});

  @override
  ConsumerState<ProfileCompletionPage> createState() =>
      _ProfileCompletionPageState();
}

class _ProfileCompletionPageState
    extends ConsumerState<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  DateTime? _birth;
  String? _gender;
  bool _busy = false;
  String? _error;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: DateTime(now.year - 25, now.month, now.day),
    );
    if (picked != null) setState(() => _birth = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birth == null || _gender == null) {
      setState(() => _error = 'Completa tutti i campi.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).updateProfile(
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            birthDate: _birth!,
            gender: _gender!,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = 'Errore: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Eyebrow('Profilo'),
                  const SizedBox(height: 8),
                  Text(
                    'Completa il tuo profilo',
                    style: StreamloadTypography.display(fontSize: 32),
                  ),
                  const SizedBox(height: 24),
                  StreamloadTextField(
                    key: const Key('profile.first_name'),
                    controller: _first,
                    label: 'Nome',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Inserisci il nome'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  StreamloadTextField(
                    key: const Key('profile.last_name'),
                    controller: _last,
                    label: 'Cognome',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Inserisci il cognome'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    key: const Key('profile.birth_date'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Data di nascita'),
                    subtitle: Text(
                      _birth == null
                          ? 'Seleziona…'
                          : DateFormat('dd/MM/yyyy').format(_birth!),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: const Key('profile.gender'),
                    decoration: const InputDecoration(
                      labelText: 'Genere',
                      border: OutlineInputBorder(),
                    ),
                    value: _gender,
                    items: [
                      for (final (value, label) in _genderOptions)
                        DropdownMenuItem(value: value, child: Text(label)),
                    ],
                    onChanged: (v) => setState(() => _gender = v),
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
                    key: const Key('profile.submit'),
                    label: _busy ? 'Salvataggio…' : 'Continua',
                    busy: _busy,
                    onPressed: _busy ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
