// lib/presentation/pages/plugins_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../plugins/loader.dart';
import '../../state/database_provider.dart';
import '../../state/github_token_provider.dart';
import '../../state/plugin_access_provider.dart';
import '../../state/plugins_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/eyebrow.dart';
import '../widgets/primary_button.dart';

class PluginsPage extends ConsumerWidget {
  const PluginsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(pluginAccessProvider);

    // ── noAccess empty-state ─────────────────────────────────────────────────
    if (access == PluginAccess.noAccess) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/settings'),
          ),
          title: const Text('Plugin'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Pacchetto plugin non disponibile',
                  style: StreamloadTypography.display(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Il tuo account GitHub non ha accesso al pacchetto plugin '
                  'di Streamload. Senza il pacchetto puoi sfogliare il '
                  'catalogo, ma non avviare la riproduzione. Contatta '
                  "l'amministratore per chiedere l'invito.",
                  textAlign: TextAlign.center,
                  style: StreamloadTypography.body(
                    fontSize: 14,
                    color: StreamloadColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(githubTokenProvider.notifier).clear();
                    if (context.mounted) context.go('/onboarding/github');
                  },
                  child: const Text('Cambia account GitHub'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── networkError empty-state ─────────────────────────────────────────────
    if (access == PluginAccess.networkError) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/settings'),
          ),
          title: const Text('Plugin'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Errore di rete',
                  style: StreamloadTypography.display(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Impossibile raggiungere il registro dei plugin. '
                  'Verifica la connessione e riprova.',
                  textAlign: TextAlign.center,
                  style: StreamloadTypography.body(
                    fontSize: 14,
                    color: StreamloadColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => ref
                      .read(pluginRefreshControllerProvider.notifier)
                      .refresh(),
                  child: const Text('Riprova'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── existing implementation (available / unknown / loading) ──────────────
    final installed = ref.watch(installedPluginsProvider);
    final refreshState = ref.watch(pluginRefreshControllerProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: const Text('Plugin'),
        actions: [
          IconButton(
            tooltip: 'Aggiorna',
            icon: const Icon(Icons.refresh),
            onPressed: refreshState is AsyncLoading
                ? null
                : () => ref
                    .read(pluginRefreshControllerProvider.notifier)
                    .refresh(),
          ),
        ],
      ),
      body: installed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (rows) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Eyebrow('Pacchetto plugin'),
              const SizedBox(height: 12),
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Nessun plugin installato. Premi "Aggiorna" per scaricare il pacchetto.',
                    style: StreamloadTypography.body(
                      fontSize: 14,
                      color: StreamloadColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...rows.map((p) => Card(
                      color: StreamloadColors.surface2,
                      child: ListTile(
                        title: Text(
                          p.shortName,
                          style: StreamloadTypography.body(
                            fontSize: 16,
                            weight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'v${p.version}',
                          style: StreamloadTypography.mono(fontSize: 11),
                        ),
                        trailing: Switch(
                          value: p.enabled,
                          onChanged: (v) =>
                              db.installedPluginsDao.setEnabled(p.shortName, v),
                        ),
                      ),
                    )),
              const SizedBox(height: 24),
              if (refreshState is AsyncError)
                Text(
                  'Aggiornamento fallito: ${refreshState.error}',
                  style: StreamloadTypography.body(
                    fontSize: 13,
                    color: StreamloadColors.critical,
                  ),
                ),
              if (refreshState is AsyncData &&
                  (refreshState as AsyncData<RefreshSummary>).value.outcome ==
                      RefreshOutcome.success) ...[
                Text(
                  'Aggiornati: ${refreshState.value.mounted.length}, '
                  'falliti: ${refreshState.value.failed.length}, '
                  'rimossi: ${refreshState.value.removed.length}.',
                  style: StreamloadTypography.body(
                    fontSize: 13,
                    color: StreamloadColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Cambia token GitHub',
                onPressed: () async {
                  await ref.read(githubTokenProvider.notifier).clear();
                  if (context.mounted) context.go('/onboarding/github');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
