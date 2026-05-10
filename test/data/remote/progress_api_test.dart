// test/data/remote/progress_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/endpoints/progress_api.dart';

class _ClientMock extends Mock implements ApiClient {}

void main() {
  test('post sends the full TV payload', () async {
    final client = _ClientMock();
    when(() => client.postJson('/api/progress', body: {
          'tmdb_id': 1396,
          'media_type': 'tv',
          'season_number': 3,
          'episode_number': 7,
          'position_seconds': 754,
          'duration_seconds': 2880,
        })).thenAnswer((_) async => {'status': 'ok', 'completed': 'false'});
    final api = ProgressApi(client);
    final out = await api.post(
      tmdbId: 1396,
      mediaType: 'tv',
      seasonNumber: 3,
      episodeNumber: 7,
      positionSeconds: 754,
      durationSeconds: 2880,
    );
    expect(out['status'], 'ok');
  });
}
