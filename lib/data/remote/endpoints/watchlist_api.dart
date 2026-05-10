// lib/data/remote/endpoints/watchlist_api.dart
import '../api_client.dart';

class WatchlistApi {
  WatchlistApi(this._client);
  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list() async {
    final raw = await _client.raw.get<dynamic>('/api/watchlist');
    final data = raw.data;
    if (data is! List) return const [];
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> add(int tmdbId, String mediaType) async {
    await _client.postJson(
      '/api/watchlist/$tmdbId',
      query: {'media_type': mediaType},
    );
  }

  Future<void> remove(int tmdbId, String mediaType) async {
    await _client.delete(
      '/api/watchlist/$tmdbId',
      query: {'media_type': mediaType},
    );
  }
}
