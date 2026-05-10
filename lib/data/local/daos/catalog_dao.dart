// lib/data/local/daos/catalog_dao.dart
import 'package:drift/drift.dart';

import '../database.dart';
import '../schema/catalog_items.dart';

part 'catalog_dao.g.dart';

@DriftAccessor(tables: [CatalogItems])
class CatalogDao extends DatabaseAccessor<StreamloadDatabase> with _$CatalogDaoMixin {
  CatalogDao(super.db);

  Future<CatalogItemRow?> get(int tmdbId, String mediaType) {
    return (select(catalogItems)
          ..where((t) => t.tmdbId.equals(tmdbId) & t.mediaType.equals(mediaType)))
        .getSingleOrNull();
  }

  Future<void> upsert(CatalogItemsCompanion entry) async {
    await into(catalogItems).insertOnConflictUpdate(entry);
  }

  Stream<CatalogItemRow?> watchByKey(int tmdbId, String mediaType) {
    return (select(catalogItems)
          ..where((t) => t.tmdbId.equals(tmdbId) & t.mediaType.equals(mediaType)))
        .watchSingleOrNull();
  }

  Future<int> count() async {
    return await catalogItems.count().getSingle();
  }
}
