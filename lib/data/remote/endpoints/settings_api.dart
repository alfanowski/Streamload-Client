// lib/data/remote/endpoints/settings_api.dart
import '../../../domain/models/settings.dart';
import '../api_client.dart';

class SettingsApi {
  SettingsApi(this._client);
  final ApiClient _client;

  /// GET /api/settings
  Future<UserSettingsModel> get() async {
    final json = await _client.getJson('/api/settings');
    return UserSettingsModel.fromJson(json);
  }

  /// PUT /api/settings
  Future<UserSettingsModel> update(UserSettingsModel settings) async {
    final json = await _client.putJson('/api/settings', body: settings.toJson());
    return UserSettingsModel.fromJson(json);
  }
}
