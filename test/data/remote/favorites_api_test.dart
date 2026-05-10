// test/data/remote/favorites_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';

class _ClientMock extends Mock implements ApiClient {}

void main() {
  test('add posts with media_type query', () async {
    final client = _ClientMock();
    when(() => client.postJson(
          '/api/favorites/42',
          query: {'media_type': 'movie'},
        )).thenAnswer((_) async => {'status': 'added'});
    await FavoritesApi(client).add(42, 'movie');
    verify(() => client.postJson(
          '/api/favorites/42',
          query: {'media_type': 'movie'},
        )).called(1);
  });

  test('remove deletes with media_type query', () async {
    final client = _ClientMock();
    when(() => client.delete(
          '/api/favorites/42',
          query: {'media_type': 'movie'},
        )).thenAnswer((_) async {});
    await FavoritesApi(client).remove(42, 'movie');
    verify(() => client.delete(
          '/api/favorites/42',
          query: {'media_type': 'movie'},
        )).called(1);
  });
}
