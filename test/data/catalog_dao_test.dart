// test/data/catalog_dao_test.dart
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/local/database.dart';

void main() {
  late StreamloadDatabase db;

  setUp(() {
    db = StreamloadDatabase.test(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('upsert + get round-trip', () async {
    await db.catalogDao.upsert(CatalogItemsCompanion.insert(
      tmdbId: 1396,
      mediaType: 'tv',
      title: 'Breaking Bad',
      year: const Value(2008),
      seasonsCount: const Value(5),
    ));
    final fetched = await db.catalogDao.get(1396, 'tv');
    expect(fetched, isNotNull);
    expect(fetched!.title, 'Breaking Bad');
    expect(fetched.year, 2008);
  });

  test('composite PK lets movie + tv with same id coexist', () async {
    await db.catalogDao.upsert(CatalogItemsCompanion.insert(
      tmdbId: 1396, mediaType: 'movie', title: 'Lo specchio',
    ));
    await db.catalogDao.upsert(CatalogItemsCompanion.insert(
      tmdbId: 1396, mediaType: 'tv', title: 'Breaking Bad',
    ));
    expect(await db.catalogDao.count(), 2);
    expect((await db.catalogDao.get(1396, 'movie'))!.title, 'Lo specchio');
    expect((await db.catalogDao.get(1396, 'tv'))!.title, 'Breaking Bad');
  });
}
