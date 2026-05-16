// lib/data/remote/endpoints/catalog_rows_api.dart
//
// Thin client wrapper over the backend's /api/catalog/rows/* endpoints
// (sub-plan 8, Phase D1). The backend proxies TMDB so the client never
// sees the API key. Each method returns at most 20 MediaSummary items —
// the backend caps the response, but we also tolerate any length here.
//
// We talk to dio directly (not ApiClient.getJson) because the responses
// are JSON arrays — ApiClient only unwraps object responses. The cookie
// session + baseUrl still apply transparently (raw == _dio).
import '../../../domain/models/media_summary.dart';
import '../api_client.dart';

abstract class CatalogRowsApi {
  /// Trending across both types or filtered to a single media type.
  /// [period] is `day` or `week`; [mediaType] is `all` / `movie` / `tv`.
  Future<List<MediaSummary>> trending({
    String period = 'week',
    String mediaType = 'all',
  });

  /// Recent releases (last 60 days) for one media type.
  Future<List<MediaSummary>> newReleases({required String mediaType});

  /// Discover by genre IDs. Optional [originalLanguage] for filters like
  /// "Commedie italiane" (`it`).
  Future<List<MediaSummary>> byGenre({
    required List<int> genreIds,
    required String mediaType,
    String? originalLanguage,
  });

  /// Top rated for one media type.
  Future<List<MediaSummary>> topRated({required String mediaType});

  /// TMDB's "similar" titles to a given tmdbId.
  Future<List<MediaSummary>> similar({
    required int tmdbId,
    required String mediaType,
  });

  /// TMDB's "recommendations" — usually higher quality than `similar`.
  /// Used on the title page bottom row.
  Future<List<MediaSummary>> recommendations({
    required int tmdbId,
    required String mediaType,
  });
}

class HttpCatalogRowsApi implements CatalogRowsApi {
  HttpCatalogRowsApi(this._client);
  final ApiClient _client;

  @override
  Future<List<MediaSummary>> trending({
    String period = 'week',
    String mediaType = 'all',
  }) async {
    return _list(
      '/api/catalog/rows/trending',
      {'period': period, 'media_type': mediaType},
    );
  }

  @override
  Future<List<MediaSummary>> newReleases({required String mediaType}) async {
    return _list(
      '/api/catalog/rows/new-releases',
      {'media_type': mediaType},
    );
  }

  @override
  Future<List<MediaSummary>> byGenre({
    required List<int> genreIds,
    required String mediaType,
    String? originalLanguage,
  }) async {
    return _list(
      '/api/catalog/rows/by-genre',
      {
        'genre_ids': genreIds.join(','),
        'media_type': mediaType,
        if (originalLanguage != null) 'original_language': originalLanguage,
      },
    );
  }

  @override
  Future<List<MediaSummary>> topRated({required String mediaType}) async {
    return _list(
      '/api/catalog/rows/top-rated',
      {'media_type': mediaType},
    );
  }

  @override
  Future<List<MediaSummary>> similar({
    required int tmdbId,
    required String mediaType,
  }) async {
    return _list(
      '/api/catalog/$tmdbId/similar',
      {'media_type': mediaType},
    );
  }

  @override
  Future<List<MediaSummary>> recommendations({
    required int tmdbId,
    required String mediaType,
  }) async {
    return _list(
      '/api/catalog/$tmdbId/recommendations',
      {'media_type': mediaType},
    );
  }

  Future<List<MediaSummary>> _list(
    String path,
    Map<String, dynamic> query,
  ) async {
    final resp = await _client.raw.get<dynamic>(
      path,
      queryParameters: query,
    );
    final body = resp.data;
    if (body is! List) return const <MediaSummary>[];
    return body
        .whereType<Map<String, dynamic>>()
        .map(MediaSummary.fromJson)
        .toList(growable: false);
  }
}
