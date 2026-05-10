// lib/data/remote/endpoints/episodes_api.dart
import '../api_client.dart';

class EpisodesApi {
  EpisodesApi(this._client);
  final ApiClient _client;

  /// GET /api/title/{tmdb_id}/episodes — seasons + episodes for a TV title.
  Future<Map<String, dynamic>> list(int tmdbId) async {
    return _client.getJson('/api/title/$tmdbId/episodes');
  }
}
