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

  test('loginWithGithub posts to /api/auth/github and parses User', () async {
    when(() => client.postJson(
          '/api/auth/github',
          body: {'access_token': 'ghu_abc'},
        )).thenAnswer((_) async => {
              'id': 'u1',
              'username': 'alfanowski',
              'email': 'a@x.com',
              'email_verified': true,
              'github_username': 'alfanowski',
              'profile_complete': false,
            });
    final u = await api.loginWithGithub('ghu_abc');
    expect(u.username, 'alfanowski');
    expect(u.githubUsername, 'alfanowski');
    expect(u.profileComplete, false);
  });

  test('updateProfile patches /api/me/profile and parses User', () async {
    final birthDate = DateTime(1990, 1, 15);
    when(() => client.patchJson(
          '/api/me/profile',
          body: {
            'first_name': 'Andrea',
            'last_name': 'Alfano',
            'birth_date': '1990-01-15',
            'gender': 'male',
          },
        )).thenAnswer((_) async => {
              'id': 'u1',
              'username': 'alfanowski',
              'email': 'a@x.com',
              'email_verified': true,
              'first_name': 'Andrea',
              'last_name': 'Alfano',
              'birth_date': '1990-01-15',
              'gender': 'male',
              'profile_complete': true,
            });
    final u = await api.updateProfile(
      firstName: 'Andrea',
      lastName: 'Alfano',
      birthDate: birthDate,
      gender: 'male',
    );
    expect(u.firstName, 'Andrea');
    expect(u.lastName, 'Alfano');
    expect(u.gender, 'male');
    expect(u.profileComplete, true);
  });

  test('me hits /api/me', () async {
    when(() => client.getJson('/api/me')).thenAnswer((_) async => {
          'id': 'u1',
          'username': 'alice',
          'email': 'a@x.com',
          'email_verified': true,
        });
    final u = await api.me();
    expect(u.id, 'u1');
  });

  test('logout calls /api/auth/logout', () async {
    when(() => client.postJson('/api/auth/logout')).thenAnswer((_) async => {});
    await api.logout();
    verify(() => client.postJson('/api/auth/logout')).called(1);
  });
}
