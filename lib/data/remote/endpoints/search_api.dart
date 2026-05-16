// lib/data/remote/endpoints/search_api.dart
import '../api_client.dart';

class SearchApi {
  SearchApi(this._client);
  final ApiClient _client;

  /// GET /api/search?q=foo&page=N
  ///
  /// Backend caps `page` at 5 (TMDB's per-page is 20 → 100 results max).
  /// Default `page=1` keeps the original behavior for live-suggestion
  /// callers (overlay, /search input) that only ever need the first
  /// batch.
  Future<Map<String, dynamic>> run(String query, {int page = 1}) async {
    return _client.getJson(
      '/api/search',
      query: {'q': query, 'page': page},
    );
  }
}
