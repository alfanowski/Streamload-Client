// lib/data/remote/endpoints/person_api.dart
//
// Pass 3 CAST-2 — Person bio + combined filmography. Kept separate from
// CatalogApi because /person/* is a sibling resource (not a sub-resource
// of a catalog item) and the typed surface stays smaller / easier to
// fake. Same dio underneath, same cookie session, same baseUrl.
import '../../../domain/models/media_summary.dart';
import '../../../domain/models/person.dart';
import '../api_client.dart';

abstract class PersonApi {
  /// GET /api/person/{id} — bio + identity.
  Future<Person> get(int personId);

  /// GET /api/person/{id}/credits — combined movie + tv filmography,
  /// sorted by popularity desc (backend handles the sort + dedup +
  /// quality filter).
  Future<List<MediaSummary>> credits(int personId);
}

class HttpPersonApi implements PersonApi {
  HttpPersonApi(this._client);
  final ApiClient _client;

  @override
  Future<Person> get(int personId) async {
    final resp = await _client.raw.get<dynamic>('/api/person/$personId');
    final body = resp.data;
    if (body is! Map<String, dynamic>) {
      throw StateError('Unexpected /api/person/$personId body: $body');
    }
    return Person.fromJson(body);
  }

  @override
  Future<List<MediaSummary>> credits(int personId) async {
    final resp = await _client.raw.get<dynamic>(
      '/api/person/$personId/credits',
    );
    final body = resp.data;
    if (body is! List) return const <MediaSummary>[];
    return body
        .whereType<Map<String, dynamic>>()
        .map(MediaSummary.fromJson)
        .toList(growable: false);
  }
}
