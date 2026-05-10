// lib/state/title_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/catalog_item.dart';
import '../domain/models/catalog_item_x.dart';
import 'api_client_provider.dart';
import 'database_provider.dart';

class TitleKey {
  const TitleKey({required this.tmdbId, required this.mediaType});
  final int tmdbId;
  final String mediaType;

  @override
  bool operator ==(Object other) =>
      other is TitleKey &&
      other.tmdbId == tmdbId &&
      other.mediaType == mediaType;

  @override
  int get hashCode => Object.hash(tmdbId, mediaType);
}

/// Fetches title metadata from the backend, upserts into the local drift cache,
/// and returns the fresh [CatalogItemResponse].
final titleProvider =
    FutureProvider.family<CatalogItemResponse, TitleKey>((ref, k) async {
  final api = await ref.watch(catalogApiProvider.future);
  final db = ref.watch(databaseProvider);
  final fresh = await api.get(k.tmdbId, mediaType: k.mediaType);
  await db.catalogDao.upsert(fresh.toCompanion());
  return fresh;
});
