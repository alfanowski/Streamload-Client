import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/plugins/github_oauth.dart';

class _DioMock extends Mock implements Dio {}

Response<Map<String, dynamic>> _resp(Map<String, dynamic> body, {int status = 200}) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: ''),
      data: body,
      statusCode: status,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Options());
  });

  late _DioMock dio;
  late GithubOAuth oauth;

  setUp(() {
    dio = _DioMock();
    oauth = GithubOAuth(clientId: 'TEST_CLIENT_ID', dio: dio);
  });

  group('requestDeviceCode', () {
    test('parses successful response into DeviceCodeRequest', () async {
      when(() => dio.post<Map<String, dynamic>>(
            'https://github.com/login/device/code',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp({
            'device_code': 'dev-abc',
            'user_code': 'ABCD-1234',
            'verification_uri': 'https://github.com/login/device',
            'expires_in': 900,
            'interval': 5,
          }));

      final result = await oauth.requestDeviceCode();
      expect(result.deviceCode, 'dev-abc');
      expect(result.userCode, 'ABCD-1234');
      expect(result.verificationUri, 'https://github.com/login/device');
      expect(result.expiresIn, const Duration(seconds: 900));
      expect(result.pollInterval, const Duration(seconds: 5));
    });

    test('throws on non-2xx', () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp({'error': 'invalid_client'}, status: 400));
      expect(oauth.requestDeviceCode, throwsA(isA<StateError>()));
    });
  });

  group('pollForToken', () {
    test('returns token when GitHub returns 200 with access_token', () async {
      when(() => dio.post<Map<String, dynamic>>(
            'https://github.com/login/oauth/access_token',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp({
            'access_token': 'ghu_xyz789',
            'token_type': 'bearer',
            'scope': 'repo',
          }));

      final token = await oauth.pollForToken(
        deviceCode: 'dev-abc',
        interval: const Duration(milliseconds: 10),
        timeout: const Duration(seconds: 1),
      );
      expect(token, 'ghu_xyz789');
    });

    test('keeps polling while GitHub responds with authorization_pending', () async {
      var calls = 0;
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async {
        calls++;
        if (calls < 3) {
          return _resp({'error': 'authorization_pending'});
        }
        return _resp({'access_token': 'ghu_late', 'token_type': 'bearer', 'scope': 'repo'});
      });

      final token = await oauth.pollForToken(
        deviceCode: 'dev-abc',
        interval: const Duration(milliseconds: 5),
        timeout: const Duration(seconds: 1),
      );
      expect(token, 'ghu_late');
      expect(calls, 3);
    });

    test('respects slow_down by extending the interval', () async {
      var calls = 0;
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async {
        calls++;
        if (calls == 1) return _resp({'error': 'slow_down'});
        return _resp({'access_token': 't', 'token_type': 'bearer', 'scope': 'repo'});
      });
      // Should still complete within timeout even with slow_down.
      final token = await oauth.pollForToken(
        deviceCode: 'dev-abc',
        interval: const Duration(milliseconds: 5),
        timeout: const Duration(seconds: 2),
      );
      expect(token, 't');
    });

    test('throws DeviceFlowDenied when user denies', () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp({'error': 'access_denied'}));
      expect(
        () => oauth.pollForToken(
          deviceCode: 'd', interval: const Duration(milliseconds: 5),
          timeout: const Duration(milliseconds: 100),
        ),
        throwsA(isA<DeviceFlowDenied>()),
      );
    });

    test('throws DeviceFlowExpired on expired_token', () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp({'error': 'expired_token'}));
      expect(
        () => oauth.pollForToken(
          deviceCode: 'd', interval: const Duration(milliseconds: 5),
          timeout: const Duration(milliseconds: 100),
        ),
        throwsA(isA<DeviceFlowExpired>()),
      );
    });

    test('throws TimeoutException when own timeout fires before user authorizes', () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp({'error': 'authorization_pending'}));
      expect(
        () => oauth.pollForToken(
          deviceCode: 'd', interval: const Duration(milliseconds: 5),
          timeout: const Duration(milliseconds: 50),
        ),
        throwsA(isA<DeviceFlowExpired>()),
      );
    });
  });
}
