// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/collections_provider.dart';
import '../theme/typography.dart';
import '../widgets/media_row.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
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
        data: (rows) => ListView(
          children: rows
              .map((c) => MediaRow(
                    title: c.title,
                    items: c.items,
                    onTap: (m) => context.go(
                      '/title/${m.tmdbId}?media_type=${m.mediaType}',
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
