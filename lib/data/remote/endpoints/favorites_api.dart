// lib/data/remote/endpoints/favorites_api.dart
import '../api_client.dart';

class FavoritesApi {
  FavoritesApi(this._client);
  final ApiClient _client;

  /// GET /api/favorites
  Future<List<Map<String, dynamic>>> list() async {
    final raw = await _client.raw.get<dynamic>('/api/favorites');
    final data = raw.data;
    if (data is! List) return const [];
    return data.cast<Map<String, dynamic>>();
  }

  /// POST /api/favorites/{tmdb_id}?media_type=
  Future<void> add(int tmdbId, String mediaType) async {
    await _client.postJson(
      '/api/favorites/$tmdbId',
      query: {'media_type': mediaType},
    );
  }

  /// DELETE /api/favorites/{tmdb_id}?media_type=
  Future<void> remove(int tmdbId, String mediaType) async {
    await _client.delete(
      '/api/favorites/$tmdbId',
      query: {'media_type': mediaType},
    );
  }
}
