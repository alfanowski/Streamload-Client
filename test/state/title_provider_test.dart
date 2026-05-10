// test/state/title_provider_test.dart
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_api.dart';
import 'package:streamload_client/domain/models/catalog_item.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/database_provider.dart';
import 'package:streamload_client/state/title_provider.dart';

class _CatalogApiMock extends Mock implements CatalogApi {}

void main() {
  test('titleProvider fetches from api, upserts to drift, returns response',
      () async {
    final api = _CatalogApiMock();
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    const response = CatalogItemResponse(
      tmdbId: 42,
      mediaType: 'movie',
      title: 'Dune: Part Two',
      year: 2024,
      overview: 'A sequel.',
    );

    when(() => api.get(42, mediaType: 'movie'))
        .thenAnswer((_) async => response);

    final container = ProviderContainer(overrides: [
      catalogApiProvider.overrideWith((_) async => api),
      databaseProvider.overrideWith((_) => db),
    ]);
    addTearDown(container.dispose);

    final result = await container.read(
      titleProvider(
        const TitleKey(tmdbId: 42, mediaType: 'movie'),
      ).future,
    );

    expect(result.title, 'Dune: Part Two');
    expect(result.year, 2024);

    // Verify upsert landed in drift.
    final row = await db.catalogDao.get(42, 'movie');
    expect(row, isNotNull);
    expect(row!.title, 'Dune: Part Two');
  });
}
