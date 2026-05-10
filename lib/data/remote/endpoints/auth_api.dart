// lib/data/remote/endpoints/auth_api.dart
import '../../../domain/models/user.dart';
import '../api_client.dart';

class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  Future<User> login({required String username, required String password}) async {
    final json = await _client.postJson(
      '/api/auth/login',
      body: {'username': username, 'password': password},
    );
    return User.fromJson(json);
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final json = await _client.postJson(
      '/api/auth/register',
      body: {'username': username, 'email': email, 'password': password},
    );
    return User.fromJson(json);
  }

  Future<User> me() async {
    final json = await _client.getJson('/api/me');
    return User.fromJson(json);
  }

  Future<void> logout() async {
    await _client.postJson('/api/auth/logout');
  }
}
