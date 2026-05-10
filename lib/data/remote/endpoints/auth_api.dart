// lib/data/remote/endpoints/auth_api.dart
import '../../../domain/models/user.dart';
import '../api_client.dart';

class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  /// Exchange a GitHub OAuth access token for a backend session cookie.
  /// Returns the user (with profile_complete=false for first-time logins).
  Future<User> loginWithGithub(String accessToken) async {
    final json = await _client.postJson(
      '/api/auth/github',
      body: {'access_token': accessToken},
    );
    return User.fromJson(json);
  }

  Future<User> me() async {
    final json = await _client.getJson('/api/me');
    return User.fromJson(json);
  }

  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required String gender,
  }) async {
    final json = await _client.patchJson(
      '/api/me/profile',
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate.toIso8601String().substring(0, 10),
        'gender': gender,
      },
    );
    return User.fromJson(json);
  }

  Future<void> logout() async {
    await _client.postJson('/api/auth/logout');
  }
}
