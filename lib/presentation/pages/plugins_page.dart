// lib/presentation/pages/plugins_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../plugins/loader.dart';
import '../../state/database_provider.dart';
import '../../state/github_token_provider.dart';
import '../../state/plugins_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/eyebrow.dart';
import '../widgets/primary_button.dart';

class PluginsPage extends ConsumerWidget {
  const PluginsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  (refreshState as AsyncData).value != null) ...[
                Text(
                  'Aggiornati: ${(refreshState.value as RefreshResult).mounted.length}, '
                  'falliti: ${(refreshState.value as RefreshResult).failed.length}, '
                  'rimossi: ${(refreshState.value as RefreshResult).removed.length}.',
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
                  if (context.mounted) context.go('/onboarding/plugins');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
