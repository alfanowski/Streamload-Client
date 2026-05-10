// lib/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/settings.dart';
import '../../state/settings_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/eyebrow.dart';
import '../widgets/primary_button.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  UserSettingsModel? _draft;
  bool _busy = false;

  Future<void> _save() async {
    if (_draft == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(settingsControllerProvider.notifier).save(_draft!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impostazioni salvate')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Impostazioni'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Errore: $e',
              style: StreamloadTypography.body(
                fontSize: 14,
                color: StreamloadColors.critical,
              )),
        ),
        data: (settings) {
          _draft ??= settings;
          return ListView(
            padding: const EdgeInsets.all(32),
            children: [
              const Eyebrow('Riproduzione'),
              const SizedBox(height: 12),
              _languageRow(
                label: 'Audio preferito',
                value: _draft!.audioPrefLang,
                onChanged: (v) => setState(() =>
                    _draft = _draft!.copyWith(audioPrefLang: v)),
              ),
              _languageRow(
                label: 'Sottotitoli preferiti',
                value: _draft!.subsPrefLang,
                onChanged: (v) => setState(() =>
                    _draft = _draft!.copyWith(subsPrefLang: v)),
              ),
              _qualityRow(),
              SwitchListTile(
                title: const Text('Auto-play episodio successivo'),
                value: _draft!.autoplayNextEpisode,
                onChanged: (v) => setState(() =>
                    _draft = _draft!.copyWith(autoplayNextEpisode: v)),
              ),
              SwitchListTile(
                title: const Text('Salta sigla automaticamente'),
                value: _draft!.skipIntro,
                onChanged: (v) => setState(() =>
                    _draft = _draft!.copyWith(skipIntro: v)),
              ),
              const SizedBox(height: 24),
              const Eyebrow('Aspetto'),
              const SizedBox(height: 12),
              _themeRow(),
              const SizedBox(height: 32),
              PrimaryButton(
                key: const Key('settings.save'),
                label: _busy ? 'Salvataggio…' : 'Salva',
                busy: _busy,
                onPressed: _busy ? null : _save,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _languageRow({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label,
              style: StreamloadTypography.body(fontSize: 14))),
          DropdownButton<String>(
            value: value,
            items: const [
              DropdownMenuItem(value: 'ita', child: Text('ita')),
              DropdownMenuItem(value: 'eng', child: Text('eng')),
              DropdownMenuItem(value: 'jpn', child: Text('jpn')),
            ],
            onChanged: (v) => v != null ? onChanged(v) : null,
          ),
        ],
      ),
    );
  }

  Widget _qualityRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text('Qualità massima',
              style: StreamloadTypography.body(fontSize: 14))),
          DropdownButton<int?>(
            value: _draft!.qualityCapHeight,
            items: const [
              DropdownMenuItem(value: null, child: Text('senza limite')),
              DropdownMenuItem(value: 480, child: Text('480p')),
              DropdownMenuItem(value: 720, child: Text('720p')),
              DropdownMenuItem(value: 1080, child: Text('1080p')),
              DropdownMenuItem(value: 2160, child: Text('2160p')),
            ],
            onChanged: (v) => setState(() =>
                _draft = _draft!.copyWith(qualityCapHeight: v)),
          ),
        ],
      ),
    );
  }

  Widget _themeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text('Tema',
              style: StreamloadTypography.body(fontSize: 14))),
          DropdownButton<String>(
            value: _draft!.theme,
            items: const [
              DropdownMenuItem(value: 'auto', child: Text('Automatico')),
              DropdownMenuItem(value: 'light', child: Text('Chiaro')),
              DropdownMenuItem(value: 'dark', child: Text('Scuro')),
            ],
            onChanged: (v) => v != null
                ? setState(() => _draft = _draft!.copyWith(theme: v))
                : null,
          ),
        ],
      ),
    );
  }
}
