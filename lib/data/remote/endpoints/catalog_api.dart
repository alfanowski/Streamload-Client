// lib/data/remote/endpoints/catalog_api.dart
import '../../../domain/models/catalog_item.dart';
import '../api_client.dart';

class CatalogApi {
  CatalogApi(this._client);
  final ApiClient _client;

  /// GET /api/catalog/{tmdb_id}?media_type=movie|tv
  Future<CatalogItemResponse> get(int tmdbId, {String? mediaType}) async {
    final json = await _client.getJson(
      '/api/catalog/$tmdbId',
      query: {if (mediaType != null) 'media_type': mediaType},
    );
    return CatalogItemResponse.fromJson(json);
  }
}
