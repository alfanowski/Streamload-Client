// lib/data/remote/endpoints/events_api.dart
import '../api_client.dart';

class EventsApi {
  EventsApi(this._client);
  final ApiClient _client;

  /// POST /api/events with a batch (max 100 per call).
  Future<int> postBatch({
    String? appVersion,
    required List<({String type, Map<String, dynamic> payload})> events,
  }) async {
    final body = await _client.postJson('/api/events', body: {
      if (appVersion != null) 'app_version': appVersion,
      'events': events
          .map((e) => {'event_type': e.type, 'payload': e.payload})
          .toList(),
    });
    return (body['accepted'] as num?)?.toInt() ?? 0;
  }
}
