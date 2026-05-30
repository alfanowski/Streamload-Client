// lib/data/remote/endpoints/catalog_api.dart
import '../../../domain/models/catalog_credits.dart';
import '../../../domain/models/catalog_item.dart';
import '../../../domain/models/tmdb_video.dart';
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

  /// GET /api/catalog/{tmdb_id}/credits?media_type={movie|tv}
  ///
  /// Returns the title's curated cast (top 10) + crew (Creator /
  /// Director / Showrunner / Producer / Writer, max 6). Empty payload
  /// when TMDB has nothing for this title — never throws on 404.
  Future<CatalogCredits> credits(
    int tmdbId, {
    required String mediaType,
  }) async {
    final json = await _client.getJson(
      '/api/catalog/$tmdbId/credits',
      query: {'media_type': mediaType},
    );
    return CatalogCredits.fromJson(json);
  }

  /// GET /api/catalog/{tmdb_id}/videos?media_type={movie|tv}
  ///
  /// Returns YouTube videos only (the backend filters out other sites).
  /// Used by [HeroTrailer] to pick the best trailer / teaser for autoplay.
  /// Caller should prefer ``type == "Trailer" && official == true``.
  Future<List<TmdbVideo>> videos(
    int tmdbId, {
    required String mediaType,
  }) async {
    // We hit the raw dio because the response is a JSON list, and ApiClient
    // only knows how to unwrap object responses. The cookie session + base
    // URL still apply (raw == _dio).
    final resp = await _client.raw.get<dynamic>(
      '/api/catalog/$tmdbId/videos',
      queryParameters: {'media_type': mediaType},
    );
    final body = resp.data;
    if (body is! List) return const <TmdbVideo>[];
    return body
        .whereType<Map<String, dynamic>>()
        .map(TmdbVideo.fromJson)
        .toList(growable: false);
  }

  /// GET /api/catalog/{tmdb_id}/logo?media_type={movie|tv}
  ///
  /// Returns the title's official logo (typographic wordmark) URL, or null
  /// when TMDB has none — the hero falls back to app-typeset text. Never
  /// throws on missing art.
  Future<String?> logo(
    int tmdbId, {
    required String mediaType,
  }) async {
    final json = await _client.getJson(
      '/api/catalog/$tmdbId/logo',
      query: {'media_type': mediaType},
    );
    final url = json['logo_url'];
    return url is String && url.isNotEmpty ? url : null;
  }
}
