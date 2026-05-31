// lib/state/my_list_items_provider.dart
//
// Risolve "La mia lista" (favorites ∪ watchlist) in [LibraryItem] classificati.
// Per le righe mancanti o senza generi in cache fa backfill dal backend
// (GET /api/catalog/{id}) e le upserta, così la classificazione in 4 categorie
// è accurata. Concorrenza limitata. Errori per-item: bucket di default per
// mediaType, mai eccezioni.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/catalog_item_x.dart';
import '../domain/models/library_category.dart';
import '../domain/models/media_summary.dart';
import 'api_client_provider.dart';
import 'database_provider.dart';
import 'favorites_provider.dart';
import 'title_provider.dart';
import 'watchlist_provider.dart';

class LibraryItem {
  const LibraryItem({required this.summary, required this.category});
  final MediaSummary summary;
  final LibraryCategory category;
}

final myListItemsProvider =
    FutureProvider.autoDispose<List<LibraryItem>>((ref) async {
  // Await both so the resolve runs against the loaded sets (reading `.value`
  // synchronously would see null while they're still loading). Watching `.future`
  // keeps the list reactive to add/remove.
  final fav = await ref.watch(favoritesProvider.future);
  final wl = await ref.watch(watchlistProvider.future);
  // Dedup per TitleKey completo (tmdbId + mediaType): il mediaType guida la categoria.
  final keys = <TitleKey>{...fav, ...wl}.toList(growable: false);
  if (keys.isEmpty) return const <LibraryItem>[];

  final db = ref.watch(databaseProvider);
  final api = await ref.watch(catalogApiProvider.future);

  Future<LibraryItem> resolve(TitleKey k) async {
    var row = await db.catalogDao.get(k.tmdbId, k.mediaType);
    var genres = _parseGenres(row?.genresJson);
    if (row == null || genres.isEmpty) {
      try {
        final fresh = await api.get(k.tmdbId, mediaType: k.mediaType);
        await db.catalogDao.upsert(fresh.toCompanion());
        row = await db.catalogDao.get(k.tmdbId, k.mediaType);
        genres = fresh.genres;
      } catch (_) {
        // Lascia row/genres com'erano: la classificazione ricade sul mediaType.
      }
    }
    final summary = row != null
        ? MediaSummary(
            tmdbId: row.tmdbId,
            mediaType: row.mediaType,
            title: row.title,
            year: row.year,
            posterUrl: row.posterUrl,
            backdropUrl: row.backdropUrl,
          )
        : MediaSummary(
            tmdbId: k.tmdbId,
            mediaType: k.mediaType,
            title: '#${k.tmdbId}',
          );
    return LibraryItem(
      summary: summary,
      category: categoryFor(k.mediaType, genres),
    );
  }

  return _mapBounded(keys, 6, resolve);
});

List<String> _parseGenres(String? json) {
  if (json == null || json.isEmpty) return const [];
  try {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList(growable: false);
    }
  } catch (_) {/* malformed cache → treat as no genres */}
  return const [];
}

/// Mappa [items] con al massimo [concurrency] future in volo, preservando l'ordine.
/// Sicuro single-thread: l'indice viene preso sincronicamente prima di ogni await.
Future<List<T>> _mapBounded<S, T>(
  List<S> items,
  int concurrency,
  Future<T> Function(S) fn,
) async {
  final results = List<T?>.filled(items.length, null);
  var next = 0;
  Future<void> worker() async {
    while (true) {
      final i = next++;
      if (i >= items.length) break;
      results[i] = await fn(items[i]);
    }
  }

  final n = concurrency < items.length ? concurrency : items.length;
  await Future.wait(List.generate(n, (_) => worker()));
  return results.cast<T>();
}
