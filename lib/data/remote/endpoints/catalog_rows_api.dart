// lib/data/remote/endpoints/catalog_rows_api.dart
//
// Thin client wrapper over the backend's /api/catalog/rows/* endpoints
// (sub-plan 8, Phase D1). The backend proxies TMDB so the client never
// sees the API key. Default row length is 60 items (bumped from 20 →
// 40 → 60 over two passes of operator feedback). Callers can pass a
// custom [limit] (1..100) and [page] for paginated reads.
//
// We talk to dio directly (not ApiClient.getJson) because the responses
// are JSON arrays — ApiClient only unwraps object responses. The cookie
// session + baseUrl still apply transparently (raw == _dio).
import '../../../domain/models/media_summary.dart';
import '../api_client.dart';

/// Default row length — matches the backend default. Bumped from 20 →
/// 40 (May 16) → 60 (May 17) per operator: rows still looked thin at
/// 40, 60 = 3 TMDB pages, enough for ~3 viewport-widths of scroll.
const int kDefaultRowLimit = 60;

abstract class CatalogRowsApi {
  /// Trending across both types or filtered to a single media type.
  /// [period] is `day` or `week`; [mediaType] is `all` / `movie` / `tv`.
  Future<List<MediaSummary>> trending({
    String period = 'week',
    String mediaType = 'all',
    int limit = kDefaultRowLimit,
    int page = 1,
  });

  /// Recent releases (last 60 days) for one media type.
  Future<List<MediaSummary>> newReleases({
    required String mediaType,
    int limit = kDefaultRowLimit,
    int page = 1,
  });

  /// Discover by genre IDs. Optional [originalLanguage] for filters like
  /// "Commedie italiane" (`it`).
  Future<List<MediaSummary>> byGenre({
    required List<int> genreIds,
    required String mediaType,
    String? originalLanguage,
    int limit = kDefaultRowLimit,
    int page = 1,
  });

  /// Top rated for one media type.
  Future<List<MediaSummary>> topRated({
    required String mediaType,
    int limit = kDefaultRowLimit,
    int page = 1,
  });

  /// TMDB's "similar" titles to a given tmdbId.
  Future<List<MediaSummary>> similar({
    required int tmdbId,
    required String mediaType,
    int limit = kDefaultRowLimit,
  });

  /// TMDB's "recommendations" — usually higher quality than `similar`.
  /// Used on the title page bottom row.
  Future<List<MediaSummary>> recommendations({
    required int tmdbId,
    required String mediaType,
    int limit = kDefaultRowLimit,
  });
}

class HttpCatalogRowsApi implements CatalogRowsApi {
  HttpCatalogRowsApi(this._client);
  final ApiClient _client;

  @override
  Future<List<MediaSummary>> trending({
    String period = 'week',
    String mediaType = 'all',
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async {
    return _list(
      '/api/catalog/rows/trending',
      {
        'period': period,
        'media_type': mediaType,
        'limit': limit,
        'page': page,
      },
    );
  }

  @override
  Future<List<MediaSummary>> newReleases({
    required String mediaType,
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async {
    return _list(
      '/api/catalog/rows/new-releases',
      {'media_type': mediaType, 'limit': limit, 'page': page},
    );
  }

  @override
  Future<List<MediaSummary>> byGenre({
    required List<int> genreIds,
    required String mediaType,
    String? originalLanguage,
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async {
    return _list(
      '/api/catalog/rows/by-genre',
      {
        'genre_ids': genreIds.join(','),
        'media_type': mediaType,
        if (originalLanguage != null) 'original_language': originalLanguage,
        'limit': limit,
        'page': page,
      },
    );
  }

  @override
  Future<List<MediaSummary>> topRated({
    required String mediaType,
    int limit = kDefaultRowLimit,
    int page = 1,
  }) async {
    return _list(
      '/api/catalog/rows/top-rated',
      {'media_type': mediaType, 'limit': limit, 'page': page},
    );
  }

  @override
  Future<List<MediaSummary>> similar({
    required int tmdbId,
    required String mediaType,
    int limit = kDefaultRowLimit,
  }) async {
    return _list(
      '/api/catalog/$tmdbId/similar',
      {'media_type': mediaType, 'limit': limit},
    );
  }

  @override
  Future<List<MediaSummary>> recommendations({
    required int tmdbId,
    required String mediaType,
    int limit = kDefaultRowLimit,
  }) async {
    return _list(
      '/api/catalog/$tmdbId/recommendations',
      {'media_type': mediaType, 'limit': limit},
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
