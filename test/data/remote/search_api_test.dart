// test/data/remote/search_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/endpoints/search_api.dart';

class _ClientMock extends Mock implements ApiClient {}

void main() {
  test('search hits /api/search with the q + page params (default page=1)',
      () async {
    final client = _ClientMock();
    when(() => client.getJson('/api/search',
            query: {'q': 'inception', 'page': 1}))
        .thenAnswer((_) async => {
              'query': 'inception',
              'results': <Map<String, dynamic>>[],
            });
    final api = SearchApi(client);
    final out = await api.run('inception');
    expect(out['query'], 'inception');
    verify(() =>
            client.getJson('/api/search', query: {'q': 'inception', 'page': 1}))
        .called(1);
  });

  test('page param is forwarded for infinite-scroll pagination', () async {
    final client = _ClientMock();
    when(() => client.getJson('/api/search', query: {'q': 'dune', 'page': 3}))
        .thenAnswer((_) async => {
              'query': 'dune',
              'results': <Map<String, dynamic>>[],
            });
    final api = SearchApi(client);
    await api.run('dune', page: 3);
    verify(() => client.getJson('/api/search', query: {'q': 'dune', 'page': 3}))
        .called(1);
  });

  test('search() parses titles + people into typed SearchResults', () async {
    final client = _ClientMock();
    when(() => client.getJson('/api/search',
            query: {'q': 'brad', 'page': 1}))
        .thenAnswer((_) async => {
              'query': 'brad',
              'results': <Map<String, dynamic>>[
                {
                  'tmdb_id': 9,
                  'media_type': 'movie',
                  'title': 'Fight Club',
                  'year': 1999,
                  'poster_url': 'https://img/p.jpg',
                },
              ],
              'people': <Map<String, dynamic>>[
                {
                  'tmdb_id': 287,
                  'name': 'Brad Pitt',
                  'profile_url': 'https://img/bp.jpg',
                  'department': 'Acting',
                  'known_for': ['World War Z', 'Fight Club'],
                },
              ],
            });
    final api = SearchApi(client);
    final out = await api.search('brad');
    expect(out.titles, hasLength(1));
    expect(out.titles.first.title, 'Fight Club');
    expect(out.people, hasLength(1));
    expect(out.people.first.tmdbId, 287);
    expect(out.people.first.name, 'Brad Pitt');
    expect(out.people.first.department, 'Acting');
    expect(out.people.first.knownFor, ['World War Z', 'Fight Club']);
    expect(out.people.first.profileUrl, 'https://img/bp.jpg');
  });

  test('search() tolerates a missing people array (back-compat)', () async {
    final client = _ClientMock();
    when(() => client.getJson('/api/search', query: {'q': 'x', 'page': 1}))
        .thenAnswer((_) async => {
              'query': 'x',
              'results': <Map<String, dynamic>>[],
            });
    final api = SearchApi(client);
    final out = await api.search('x');
    expect(out.titles, isEmpty);
    expect(out.people, isEmpty);
  });
}
