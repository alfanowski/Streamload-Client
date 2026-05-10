// test/data/remote/api_client_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/api_exception.dart';

class _DioMock extends Mock implements Dio {}

class _FakeOptions extends Fake implements RequestOptions {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeOptions()));

  test('GET decodes JSON body on 200', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>(any(), queryParameters: any(named: 'queryParameters')))
        .thenAnswer((_) async => Response<dynamic>(
              data: {'ok': true},
              statusCode: 200,
              requestOptions: RequestOptions(path: '/x'),
            ));
    final client = ApiClient.test(dio);
    final out = await client.getJson('/x');
    expect(out, {'ok': true});
  });

  test('non-2xx maps to ApiException', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>(any(), queryParameters: any(named: 'queryParameters')))
        .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/x'),
          response: Response(
            statusCode: 401,
            data: {'detail': 'not authenticated'},
            requestOptions: RequestOptions(path: '/x'),
          ),
          type: DioExceptionType.badResponse,
        ));
    final client = ApiClient.test(dio);
    expect(
      () => client.getJson('/x'),
      throwsA(isA<ApiException>()
          .having((e) => e.status, 'status', 401)
          .having((e) => e.message, 'message', 'not authenticated')),
    );
  });
}
