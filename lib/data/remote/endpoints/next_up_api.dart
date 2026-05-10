// lib/data/remote/endpoints/next_up_api.dart
import '../api_client.dart';
import '../api_exception.dart';

class NextUpApi {
  NextUpApi(this._client);
  final ApiClient _client;

  /// GET /api/next-up/{tmdb_id}?season=&episode= → null on 204 (end of series).
  Future<Map<String, dynamic>?> get({
    required int tmdbId,
    required int season,
    required int episode,
  }) async {
    try {
      return await _client.getJson(
        '/api/next-up/$tmdbId',
        query: {'season': season, 'episode': episode},
      );
    } on ApiException catch (e) {
      if (e.status == 204) return null;
      rethrow;
    }
  }
}
