// lib/presentation/pages/library_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/library_provider.dart';
import '../widgets/media_grid.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _ctrl;

  static const _types = ['movie', 'tv'];
  static const _labels = ['Film', 'Serie TV'];

  @override
  void initState() {
    super.initState();
    _ctrl = TabController(length: _types.length, vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libreria'),
        bottom: TabBar(
          controller: _ctrl,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _ctrl,
        children: _types.map((t) {
          final async =
              ref.watch(libraryProvider(LibraryQuery(mediaType: t)));
          return async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Errore: $e')),
            data: (page) => MediaGrid(
              items: page.items,
              onTap: (m) => context.go(
                '/title/${m.tmdbId}?media_type=${m.mediaType}',
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
