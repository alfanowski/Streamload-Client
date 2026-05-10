// lib/presentation/widgets/watchlist_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/title_provider.dart';
import '../../state/watchlist_provider.dart';

class WatchlistButton extends ConsumerWidget {
  const WatchlistButton({super.key, required this.target});
  final TitleKey target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(watchlistProvider);
    final isInWatchlist = state.maybeWhen(
      data: (set) => set.contains(target),
      orElse: () => false,
    );
    return IconButton(
      tooltip: isInWatchlist ? 'Rimuovi dalla watchlist' : 'Aggiungi alla watchlist',
      icon: Icon(isInWatchlist ? Icons.bookmark : Icons.bookmark_border),
      color: isInWatchlist ? Colors.amber : null,
      onPressed: state.isLoading
          ? null
          : () async {
              try {
                await ref.read(watchlistProvider.notifier).toggle(target);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore: $e')),
                  );
                }
              }
            },
    );
  }
}
