// lib/data/remote/endpoints/library_api.dart
import '../api_client.dart';

class LibraryApi {
  LibraryApi(this._client);
  final ApiClient _client;

  /// GET /api/library?media_type=&page=
  Future<Map<String, dynamic>> page({
    String? mediaType,
    int page = 1,
    int perPage = 24,
  }) async {
    return _client.getJson('/api/library', query: {
      if (mediaType != null) 'media_type': mediaType,
      'page': page,
      'per_page': perPage,
    });
  }
}
