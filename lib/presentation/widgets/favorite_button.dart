// lib/presentation/widgets/favorite_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/favorites_provider.dart';
import '../../state/title_provider.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.target});
  final TitleKey target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesProvider);
    final isFavorite = state.maybeWhen(
      data: (set) => set.contains(target),
      orElse: () => false,
    );
    return IconButton(
      tooltip: isFavorite ? 'Rimuovi dai preferiti' : 'Aggiungi ai preferiti',
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      color: isFavorite ? Colors.redAccent : null,
      onPressed: state.isLoading
          ? null
          : () async {
              try {
                await ref.read(favoritesProvider.notifier).toggle(target);
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
