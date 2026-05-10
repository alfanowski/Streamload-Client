// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/continue_watching_item.dart';
import '../../domain/models/media_summary.dart';
import '../../state/collections_provider.dart';
import '../../state/continue_watching_provider.dart';
import '../../state/plugin_access_provider.dart';
import '../theme/typography.dart';
import '../widgets/media_row.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    final access = ref.watch(pluginAccessProvider);

    // Only fetch continue-watching when plugin access is confirmed available.
    final continueWatching = access == PluginAccess.available
        ? ref.watch(continueWatchingProvider)
        : const AsyncValue<List<ContinueWatchingItem>>.data([]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Streamload',
          style: StreamloadTypography.display(fontSize: 22),
        ),
      ),
      body: collections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (rows) {
          final cwRow = continueWatching.maybeWhen(
            data: (items) => items.isNotEmpty
                ? MediaRow(
                    title: 'Continua a guardare',
                    items: items
                        .map(
                          (i) => MediaSummary(
                            tmdbId: i.tmdbId,
                            mediaType: i.mediaType,
                            title: i.title,
                            posterUrl: i.posterUrl,
                          ),
                        )
                        .toList(),
                    onTap: (m) => context.go(
                      '/title/${m.tmdbId}?media_type=${m.mediaType}',
                    ),
                  )
                : null,
            orElse: () => null,
          );

          return ListView(
            children: [
              if (cwRow != null) cwRow,
              ...rows.map(
                (c) => MediaRow(
                  title: c.title,
                  items: c.items,
                  onTap: (m) => context.go(
                    '/title/${m.tmdbId}?media_type=${m.mediaType}',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
