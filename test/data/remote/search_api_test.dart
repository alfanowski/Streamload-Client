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
}
