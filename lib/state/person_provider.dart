// lib/state/person_provider.dart
//
// Pass 3 CAST-2 — autoDispose family providers keyed by tmdbId so
// navigating between actor pages doesn't keep stale futures around.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/endpoints/person_api.dart';
import '../domain/models/media_summary.dart';
import '../domain/models/person.dart';
import 'api_client_provider.dart';

final personApiProvider = FutureProvider<PersonApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return HttpPersonApi(c);
});

/// Bio for a single person (TMDB id).
final personProvider =
    FutureProvider.autoDispose.family<Person, int>((ref, id) async {
  final api = await ref.watch(personApiProvider.future);
  return api.get(id);
});

/// Combined filmography for a single person. Sorted desc by popularity
/// at the backend so the row already opens on the most recognisable
/// titles.
final personCreditsProvider = FutureProvider.autoDispose
    .family<List<MediaSummary>, int>((ref, id) async {
  final api = await ref.watch(personApiProvider.future);
  return api.credits(id);
});
