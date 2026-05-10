// test/data/remote/auth_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/endpoints/auth_api.dart';

class _ClientMock extends Mock implements ApiClient {}

void main() {
  late _ClientMock client;
  late AuthApi api;

  setUp(() {
    client = _ClientMock();
    api = AuthApi(client);
  });

  test('login posts to /auth/login and parses User', () async {
    when(() => client.postJson(
          '/api/auth/login',
          body: {'username': 'alice', 'password': 'pw'},
        )).thenAnswer((_) async => {
              'id': 'u1',
              'username': 'alice',
              'email': 'a@x.com',
              'email_verified': true,

            });
    final u = await api.login(username: 'alice', password: 'pw');
    expect(u.username, 'alice');
  });

  test('register posts to /auth/register', () async {
    when(() => client.postJson(
          '/api/auth/register',
          body: {'username': 'bob', 'email': 'b@x.com', 'password': 'pw'},
        )).thenAnswer((_) async => {
              'id': 'u2',
              'username': 'bob',
              'email': 'b@x.com',
              'email_verified': true,

            });
    final u = await api.register(username: 'bob', email: 'b@x.com', password: 'pw');
    expect(u.username, 'bob');
  });

  test('me hits /me', () async {
    when(() => client.getJson('/api/me')).thenAnswer((_) async => {
          'id': 'u1',
          'username': 'alice',
          'email': 'a@x.com',
          'email_verified': true,

        });
    final u = await api.me();
    expect(u.id, 'u1');
  });

  test('logout calls /auth/logout', () async {
    when(() => client.postJson('/api/auth/logout')).thenAnswer((_) async => {});
    await api.logout();
    verify(() => client.postJson('/api/auth/logout')).called(1);
  });
}
