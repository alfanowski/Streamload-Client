// test/plugins/host/http_host_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/plugins/host/http_host.dart';

class _DioMock extends Mock implements Dio {}

class _FakeOptions extends Fake implements RequestOptions {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeOptions()));

  test('GET passes URL and headers, returns shaped response', () async {
    final dio = _DioMock();
    when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: 'https://x/'),
          statusCode: 200,
          data: 'hello',
          headers: Headers.fromMap({
            'content-type': ['text/plain'],
          }),
        ));
    final host = HttpHost.test(dio);

    final result = await host.fetch('https://x/', {
      'method': 'GET',
      'headers': {'Referer': 'https://up'},
    });

    expect(result['status'], 200);
    expect(result['body'], 'hello');
    expect(result['headers']['content-type'], 'text/plain');
    expect(result['finalUrl'], 'https://x/');
  });

  test('non-2xx still resolves (does not throw); status preserved', () async {
    final dio = _DioMock();
    when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: 'https://x/'),
          statusCode: 404,
          data: 'not found',
        ));
    final host = HttpHost.test(dio);
    final result = await host.fetch('https://x/', {'method': 'GET'});
    expect(result['status'], 404);
    expect(result['body'], 'not found');
  });

  test('cookies array reflects Set-Cookie headers', () async {
    final dio = _DioMock();
    when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: 'https://x/'),
          statusCode: 200,
          data: '',
          headers: Headers.fromMap({
            'set-cookie': ['session=abc; Path=/', 'pref=dark'],
          }),
        ));
    final host = HttpHost.test(dio);
    final result = await host.fetch('https://x/', {'method': 'GET'});
    expect(result['cookies'], {'session': 'abc', 'pref': 'dark'});
  });
}
