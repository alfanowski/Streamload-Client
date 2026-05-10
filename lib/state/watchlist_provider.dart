// lib/state/watchlist_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client_provider.dart';
import 'title_provider.dart';

class WatchlistNotifier extends AsyncNotifier<Set<TitleKey>> {
  @override
  Future<Set<TitleKey>> build() async {
    final api = await ref.watch(watchlistApiProvider.future);
    final items = await api.list();
    return items
        .map((e) => TitleKey(
              tmdbId: e['tmdb_id'] as int,
              mediaType: e['media_type'] as String,
            ))
        .toSet();
  }

  Future<void> toggle(TitleKey key) async {
    final current = state.value ?? <TitleKey>{};
    final isCurrentlyInWatchlist = current.contains(key);
    // Optimistic update.
    final next = Set<TitleKey>.from(current);
    if (isCurrentlyInWatchlist) {
      next.remove(key);
    } else {
      next.add(key);
    }
    state = AsyncData(next);

    try {
      final api = await ref.read(watchlistApiProvider.future);
      if (isCurrentlyInWatchlist) {
        await api.remove(key.tmdbId, key.mediaType);
      } else {
        await api.add(key.tmdbId, key.mediaType);
      }
    } catch (_) {
      // Roll back.
      state = AsyncData(current);
      rethrow;
    }
  }
}

final watchlistProvider =
    AsyncNotifierProvider<WatchlistNotifier, Set<TitleKey>>(
  WatchlistNotifier.new,
);
