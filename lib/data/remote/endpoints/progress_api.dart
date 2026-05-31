// lib/data/remote/endpoints/progress_api.dart
import '../api_client.dart';

class ProgressApi {
  ProgressApi(this._client);
  final ApiClient _client;

  /// POST /api/progress
  Future<Map<String, dynamic>> post({
    required int tmdbId,
    required String mediaType,
    int? seasonNumber,
    int? episodeNumber,
    required int positionSeconds,
    required int durationSeconds,
  }) async {
    return _client.postJson('/api/progress', body: {
      'tmdb_id': tmdbId,
      'media_type': mediaType,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      'position_seconds': positionSeconds,
      'duration_seconds': durationSeconds,
    });
  }

  /// GET /api/progress/continue-watching
  Future<Map<String, dynamic>> continueWatching() async {
    return _client.getJson('/api/progress/continue-watching');
  }

  /// GET /api/progress/{tmdb_id} — the saved position for ONE exact
  /// title/episode (server-side resume, cross-device). Returns null when
  /// there's nothing saved (the backend replies 204 → empty map).
  Future<Map<String, dynamic>?> resume({
    required int tmdbId,
    required String mediaType,
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    final raw = await _client.getJson('/api/progress/$tmdbId', query: {
      'media_type': mediaType,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
    });
    if (raw.isEmpty || raw['position_seconds'] == null) return null;
    return raw;
  }

  /// DELETE /api/progress/continue-watching/{tmdb_id}?media_type=
  /// Removes a title from the "Continua a guardare" row.
  Future<void> removeContinueWatching(int tmdbId, String mediaType) async {
    await _client.delete(
      '/api/progress/continue-watching/$tmdbId',
      query: {'media_type': mediaType},
    );
  }

  /// GET /api/progress/title/{tmdb_id} — EVERY saved episode's progress for a
  /// title, for the title page's per-episode watch bars + watched ticks.
  Future<List<Map<String, dynamic>>> titleProgress(
    int tmdbId,
    String mediaType,
  ) async {
    final raw = await _client.getJson(
      '/api/progress/title/$tmdbId',
      query: {'media_type': mediaType},
    );
    final items = raw['items'];
    if (items is! List) return const [];
    return items.cast<Map<String, dynamic>>();
  }
}
