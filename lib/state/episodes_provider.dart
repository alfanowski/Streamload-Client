// lib/state/episodes_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/episodes_response.dart';
import 'api_client_provider.dart';

/// Family provider keyed by [tmdbId]. Fetches TV seasons + episodes from the
/// backend endpoint GET /api/title/{tmdb_id}/episodes.
final episodesProvider =
    FutureProvider.family<EpisodesResponse, int>((ref, tmdbId) async {
  final api = await ref.watch(episodesApiProvider.future);
  final raw = await api.list(tmdbId);
  return EpisodesResponse.fromJson(raw);
});
