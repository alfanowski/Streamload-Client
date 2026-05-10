// lib/data/remote/endpoints/search_api.dart
import '../api_client.dart';

class SearchApi {
  SearchApi(this._client);
  final ApiClient _client;

  /// GET /api/search?q=foo
  Future<Map<String, dynamic>> run(String query) async {
    return _client.getJson('/api/search', query: {'q': query});
  }
}
