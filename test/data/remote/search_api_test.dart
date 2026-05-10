// test/data/remote/search_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/endpoints/search_api.dart';

class _ClientMock extends Mock implements ApiClient {}

void main() {
  test('search hits /api/search with the q param', () async {
    final client = _ClientMock();
    when(() => client.getJson('/api/search', query: {'q': 'inception'}))
        .thenAnswer((_) async => {
              'query': 'inception',
              'results': <Map<String, dynamic>>[],
            });
    final api = SearchApi(client);
    final out = await api.run('inception');
    expect(out['query'], 'inception');
  });
}
