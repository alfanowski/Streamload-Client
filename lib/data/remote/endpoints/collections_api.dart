// lib/data/remote/endpoints/collections_api.dart
import '../api_client.dart';

class CollectionsApi {
  CollectionsApi(this._client);
  final ApiClient _client;

  /// GET /api/collections — list all collection summaries.
  Future<List<Map<String, dynamic>>> list() async {
    final raw = await _client.raw.get<dynamic>('/api/collections');
    final data = raw.data;
    if (data is! List) return const [];
    return data.cast<Map<String, dynamic>>();
  }

  /// GET /api/collections/{id} — collection detail with items.
  Future<Map<String, dynamic>> get(String id) async {
    return _client.getJson('/api/collections/$id');
  }
}
