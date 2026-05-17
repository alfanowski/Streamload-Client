// test/state/person_provider_test.dart
//
// Pass 3 CAST-2 — personProvider + personCreditsProvider wrap the
// PersonApi with riverpod families keyed by tmdbId.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/person_api.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/domain/models/person.dart';
import 'package:streamload_client/state/person_provider.dart';

class _PersonApiMock extends Mock implements PersonApi {}

void main() {
  test('personProvider returns Person from the API for the given id',
      () async {
    final api = _PersonApiMock();
    const person = Person(
      tmdbId: 287,
      name: 'Brad Pitt',
      biography: 'American actor.',
      birthday: '1963-12-18',
    );
    when(() => api.get(287)).thenAnswer((_) async => person);

    final container = ProviderContainer(overrides: [
      personApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    final result = await container.read(personProvider(287).future);
    expect(result.tmdbId, 287);
    expect(result.name, 'Brad Pitt');
  });

  test('personCreditsProvider returns filmography for the given id',
      () async {
    final api = _PersonApiMock();
    when(() => api.credits(287)).thenAnswer((_) async => const [
          MediaSummary(
            tmdbId: 20,
            mediaType: 'movie',
            title: 'Blockbuster',
            year: 2020,
          ),
        ]);

    final container = ProviderContainer(overrides: [
      personApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    final credits = await container.read(personCreditsProvider(287).future);
    expect(credits, hasLength(1));
    expect(credits.first.title, 'Blockbuster');
  });
}
