// lib/data/remote/endpoints/admin_api.dart
//
// Admin endpoints. Only an admin user can hit these (server enforces).
// No UI consumes them in sub-plan #3 — they exist so sub-plan #6 (admin
// portal) can plug straight in.

import '../api_client.dart';

class AdminApi {
  AdminApi(this._client);
  final ApiClient _client;

  /// GET /api/admin/users
  Future<List<Map<String, dynamic>>> users() async {
    final raw = await _client.raw.get<dynamic>('/api/admin/users');
    final data = raw.data;
    if (data is! List) return const [];
    return data.cast<Map<String, dynamic>>();
  }

  /// PUT /api/admin/users/{id}/role
  Future<void> setRole(String userId, String role) async {
    await _client.putJson('/api/admin/users/$userId/role', body: {'role': role});
  }

  /// POST /api/admin/users/{id}/disable
  Future<void> disable(String userId) async {
    await _client.postJson('/api/admin/users/$userId/disable');
  }

  /// POST /api/admin/users/{id}/enable
  Future<void> enable(String userId) async {
    await _client.postJson('/api/admin/users/$userId/enable');
  }

  /// POST /api/admin/users/{id}/reset-password
  Future<void> resetPassword(String userId, String password) async {
    await _client.postJson(
      '/api/admin/users/$userId/reset-password',
      body: {'password': password},
    );
  }

  /// DELETE /api/admin/users/{id}
  Future<void> deleteUser(String userId) async {
    await _client.delete('/api/admin/users/$userId');
  }

  /// GET /api/admin/stats
  Future<Map<String, dynamic>> stats() async {
    return _client.getJson('/api/admin/stats');
  }

  /// GET /api/admin/top-watched
  Future<List<Map<String, dynamic>>> topWatched() async {
    final raw = await _client.raw.get<dynamic>('/api/admin/top-watched');
    final data = raw.data;
    if (data is! List) return const [];
    return data.cast<Map<String, dynamic>>();
  }
}
