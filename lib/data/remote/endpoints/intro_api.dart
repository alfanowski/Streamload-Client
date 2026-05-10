// lib/data/remote/endpoints/intro_api.dart
import '../api_client.dart';
import '../api_exception.dart';

class IntroApi {
  IntroApi(this._client);
  final ApiClient _client;

  /// GET /api/intro/{tmdb_id}/s{season} → null on 204.
  Future<Map<String, dynamic>?> get(int tmdbId, int season) async {
    try {
      return await _client.getJson('/api/intro/$tmdbId/s$season');
    } on ApiException catch (e) {
      if (e.status == 204) return null;
      rethrow;
    }
  }
}
