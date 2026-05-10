// lib/presentation/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/search_provider.dart';
import '../widgets/media_grid.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cerca')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Titolo, anno, regista…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  ref.read(searchControllerProvider.notifier).setQuery(v),
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Errore: $e')),
              data: (items) => MediaGrid(
                items: items,
                onTap: (m) => context.go(
                  '/title/${m.tmdbId}?media_type=${m.mediaType}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
