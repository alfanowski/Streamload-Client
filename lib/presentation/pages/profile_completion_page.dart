// lib/presentation/pages/profile_completion_page.dart
//
// First-run profile completion form. Phase I1 restyles it to share the same
// Netflix-black gradient + STREAMLOAD wordmark + glass card as the plugin
// onboarding screen so the two onboarding steps read as one flow. Form
// logic / validation / submit handler / updateProfile call are unchanged.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../state/auth_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/primary_pill.dart';

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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _Eyebrow('Profilo'),
                            const SizedBox(height: 12),
                            Text(
                              'Completa il tuo profilo',
                              style: StreamloadTypography.v3DisplayPage(),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Bastano due secondi: nome, cognome, data di '
                              'nascita e genere. Servono per personalizzare '
                              "l'esperienza e nient'altro.",
                              style: StreamloadTypography.v3Body(
                                fontSize: 13,
                                color: StreamloadColors.v3TextMuted,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _GlassTextField(
                              key: const Key('profile.first_name'),
                              controller: _first,
                              label: 'Nome',
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Inserisci il nome'
                                      : null,
                            ),
                            const SizedBox(height: 14),
                            _GlassTextField(
                              key: const Key('profile.last_name'),
                              controller: _last,
                              label: 'Cognome',
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Inserisci il cognome'
                                      : null,
                            ),
                            const SizedBox(height: 14),
                            _DateField(
                              key: const Key('profile.birth_date'),
                              label: 'Data di nascita',
                              value: _birth,
                              onTap: _pickDate,
                            ),
                            const SizedBox(height: 14),
                            _GenderDropdown(
                              key: const Key('profile.gender'),
                              value: _gender,
                              onChanged: (v) => setState(() => _gender = v),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _error!,
                                style: StreamloadTypography.v3Body(
                                  fontSize: 13,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            PrimaryPill(
                              key: const Key('profile.submit'),
                              label: _busy ? 'Salvataggio…' : 'Continua',
                              busy: _busy,
                              onPressed: _busy ? null : _submit,
                            ),
                          ],
                        ),
                      ),
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

/// v3 text field — glass background, white text, mono label.
class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      cursorColor: StreamloadColors.v3TextPrimary,
      style: StreamloadTypography.v3Body(fontSize: 14),
      decoration: _glassInputDecoration(label: label),
    );
  }
}

/// Tap-to-pick birth date field. Renders like a text field for visual
/// consistency, but shows the formatted date or a placeholder. Stays an
/// InkWell so the system date picker fires on tap.
class _DateField extends StatelessWidget {
  const _DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final placeholder = value == null
        ? 'Seleziona…'
        : DateFormat('dd/MM/yyyy').format(value!);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(StreamloadSpacing.chipRadius),
      child: InputDecorator(
        decoration: _glassInputDecoration(label: label).copyWith(
          suffixIcon: Icon(
            Icons.calendar_today,
            size: 16,
            color: StreamloadColors.v3TextMuted,
          ),
        ),
        child: Text(
          placeholder,
          style: StreamloadTypography.v3Body(
            fontSize: 14,
            color: value == null
                ? StreamloadColors.v3TextMuted
                : StreamloadColors.v3TextPrimary,
          ),
        ),
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  const _GenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      isExpanded: true,
      style: StreamloadTypography.v3Body(fontSize: 14),
      dropdownColor: const Color(0xFF1A1A1A),
      iconEnabledColor: StreamloadColors.v3TextSecondary,
      decoration: _glassInputDecoration(label: 'Genere'),
      items: [
        for (final (value, label) in _genderOptions)
          DropdownMenuItem(
            value: value,
            child: Text(
              label,
              style: StreamloadTypography.v3Body(fontSize: 14),
            ),
          ),
      ],
    );
  }
}

/// One InputDecoration shape so every field reads as the same family.
/// chipRadius (14px) borders, glass fill, mono-style label, muted hint.
InputDecoration _glassInputDecoration({required String label}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(StreamloadSpacing.chipRadius),
    borderSide: BorderSide(color: StreamloadColors.v3BorderGlass),
  );
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: StreamloadColors.v3SurfaceGlassHi,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    labelStyle: StreamloadTypography.v3MetaMono(),
    floatingLabelStyle: StreamloadTypography.v3LabelMono(
      color: StreamloadColors.v3TextSecondary,
    ),
    hintStyle: StreamloadTypography.v3Body(
      fontSize: 14,
      color: StreamloadColors.v3TextMuted,
    ),
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(StreamloadSpacing.chipRadius),
      borderSide: BorderSide(color: StreamloadColors.v3TextSecondary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(StreamloadSpacing.chipRadius),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(StreamloadSpacing.chipRadius),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    errorStyle: StreamloadTypography.v3Body(
      fontSize: 12,
      color: Colors.redAccent,
    ),
  );
}
