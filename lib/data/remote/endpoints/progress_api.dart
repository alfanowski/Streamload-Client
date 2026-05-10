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
}
