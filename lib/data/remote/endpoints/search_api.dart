// lib/data/remote/endpoints/search_api.dart
import '../../../domain/models/media_summary.dart';
import '../../../domain/models/search_results.dart';
import '../api_client.dart';

class SearchApi {
  SearchApi(this._client);
  final ApiClient _client;

  /// GET /api/search?q=foo&page=N — raw map.
  ///
  /// Backend caps `page` at 5 (TMDB's per-page is 20 → 100 results max).
  /// Default `page=1` keeps the original behavior for live-suggestion
  /// callers (overlay, /search input) that only ever need the first
  /// batch.
  ///
  /// Prefer [search] for new callers — it returns the typed
  /// [SearchResults] (titles + people). `run` stays for back-compat.
  Future<Map<String, dynamic>> run(String query, {int page = 1}) async {
    return _client.getJson(
      '/api/search',
      query: {'q': query, 'page': page},
    );
  }

  /// GET /api/search?q=foo&page=N — typed.
  ///
  /// Parses the PS-1 response shape `{results: [...], people: [...]}` into
  /// [SearchResults]. People come back first in TMDB relevance order so
  /// callers can surface `people.first` as the top match.
  Future<SearchResults> search(String query, {int page = 1}) async {
    final raw = await run(query, page: page);
    final titles = (raw['results'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(MediaSummary.fromJson)
        .toList(growable: false);
    final people = (raw['people'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(SearchPersonResult.fromJson)
        .toList(growable: false);
    return SearchResults(titles: titles, people: people);
  }
}
