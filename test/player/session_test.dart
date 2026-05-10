// test/player/session_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/player/session.dart';

void main() {
  test('put + get round-trip', () {
    final reg = PlaybackSessionRegistry(ttl: const Duration(hours: 4));
    final s = PlaybackSession.create(
      tmdbId: 42,
      mediaType: 'movie',
      pluginShortName: 'echo',
      upstreamMasterUrl: 'https://upstream/m.m3u8',
      upstreamHeaders: const {'Referer': 'https://up'},
    );
    reg.put(s);
    final got = reg.get(s.id);
    expect(got, isNotNull);
    expect(got!.tmdbId, 42);
    expect(got.upstreamMasterUrl, 'https://upstream/m.m3u8');
  });

  test('get returns null for unknown id', () {
    final reg = PlaybackSessionRegistry(ttl: const Duration(seconds: 1));
    expect(reg.get('does-not-exist'), isNull);
  });

  test('TTL expiry — get after TTL returns null and evicts', () async {
    final reg = PlaybackSessionRegistry(ttl: const Duration(milliseconds: 50));
    final s = PlaybackSession.create(
      tmdbId: 1, mediaType: 'movie', pluginShortName: 'p',
      upstreamMasterUrl: 'u', upstreamHeaders: const {},
    );
    reg.put(s);
    await Future.delayed(const Duration(milliseconds: 80));
    expect(reg.get(s.id), isNull);
  });

  test('touch resets last-seen — keeps session alive', () async {
    final reg = PlaybackSessionRegistry(ttl: const Duration(milliseconds: 80));
    final s = PlaybackSession.create(
      tmdbId: 1, mediaType: 'movie', pluginShortName: 'p',
      upstreamMasterUrl: 'u', upstreamHeaders: const {},
    );
    reg.put(s);
    await Future.delayed(const Duration(milliseconds: 50));
    reg.get(s.id, touch: true); // reset clock
    await Future.delayed(const Duration(milliseconds: 50));
    expect(reg.get(s.id), isNotNull); // would have expired without touch
  });

  test('remove drops the session', () {
    final reg = PlaybackSessionRegistry(ttl: const Duration(hours: 1));
    final s = PlaybackSession.create(
      tmdbId: 1, mediaType: 'movie', pluginShortName: 'p',
      upstreamMasterUrl: 'u', upstreamHeaders: const {},
    );
    reg.put(s);
    reg.remove(s.id);
    expect(reg.get(s.id), isNull);
  });

  test('purgeExpired returns count of purged sessions', () async {
    final reg = PlaybackSessionRegistry(ttl: const Duration(milliseconds: 30));
    final a = PlaybackSession.create(tmdbId: 1, mediaType: 'movie', pluginShortName: 'p', upstreamMasterUrl: 'u', upstreamHeaders: const {});
    final b = PlaybackSession.create(tmdbId: 2, mediaType: 'movie', pluginShortName: 'p', upstreamMasterUrl: 'u', upstreamHeaders: const {});
    reg.put(a);
    reg.put(b);
    await Future.delayed(const Duration(milliseconds: 50));
    expect(reg.purgeExpired(), 2);
  });
}
