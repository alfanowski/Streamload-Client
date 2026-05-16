// test/state/availability_provider_test.dart
//
// availabilityProvider — Phase F2 of sub-plan 8.
//
// Verifies the wiring between PlayController.resolveTitle (TMDB →
// TitleHint) and ProviderRouter.probeAvailability (the F1 probe). Uses a
// custom playControllerProvider override so we don't have to spin up a
// real LocalProxyServer / plugin runtime.
//
// Covers:
//   - returns true when the probe finds a match
//   - returns false when the probe finds none
//   - same key inside the family yields the same future (Riverpod dedup)
//   - different keys yield distinct futures
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/domain/play_title.dart';
import 'package:streamload_client/player/session.dart';
import 'package:streamload_client/plugins/meta.dart';
import 'package:streamload_client/plugins/plugin.dart';
import 'package:streamload_client/plugins/routing/router.dart';
import 'package:streamload_client/plugins/runtime.dart';
import 'package:streamload_client/state/availability_provider.dart';
import 'package:streamload_client/state/play_controller_provider.dart';

class _PluginRuntimeMock extends Mock implements PluginRuntime {}
class _PluginMock extends Mock implements Plugin {}

PluginMeta _meta({
  String shortName = 'p',
  List<String> capabilities = const ['movie'],
}) =>
    PluginMeta(
      shortName: shortName,
      displayName: shortName,
      version: '1.0.0',
      apiVersion: 1,
      capabilities: capabilities,
    );

PlayController _buildController({
  required PluginRuntime runtime,
  TitleHint Function(int tmdbId, String mediaType)? resolveHint,
}) {
  final router = ProviderRouter(runtime: runtime);
  return PlayController(
    registry: PlaybackSessionRegistry(ttl: const Duration(minutes: 5)),
    proxyBaseUrl: 'http://127.0.0.1:0',
    router: router,
    resolveTitle: (tmdbId, mediaType) async =>
        (resolveHint ??
            (id, mt) => const TitleHint(title: 'Inception', year: 2010))(
            tmdbId, mediaType),
  );
}

ProviderContainer _containerWith(PlayController controller) {
  return ProviderContainer(overrides: [
    playControllerProvider.overrideWith((_) async => controller),
  ]);
}

void main() {
  test('returns true when probeAvailability finds a match', () async {
    final plugin = _PluginMock();
    when(() => plugin.meta).thenReturn(_meta(shortName: 'sc'));
    when(() => plugin.search(any())).thenAnswer(
      (_) async => [
        {
          'id': '1',
          'title': 'Inception',
          'type': 'movie',
          'year': 2010,
        }
      ],
    );

    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([plugin]);

    final controller = _buildController(runtime: runtime);
    final container = _containerWith(controller);
    addTearDown(container.dispose);

    final result = await container.read(
      availabilityProvider(
        const AvailabilityKey(tmdbId: 27205, mediaType: 'movie'),
      ).future,
    );
    expect(result, isTrue);
  });

  test('returns false when probeAvailability finds nothing', () async {
    // Plugin search returns a non-matching title — _resolveEntry rejects it
    // at every tier, so the probe is false.
    final plugin = _PluginMock();
    when(() => plugin.meta).thenReturn(_meta(shortName: 'p'));
    when(() => plugin.search(any())).thenAnswer(
      (_) async => [
        {
          'id': '1',
          'title': 'Totally Different Movie',
          'type': 'movie',
          'year': 1999,
        }
      ],
    );

    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([plugin]);

    final controller = _buildController(runtime: runtime);
    final container = _containerWith(controller);
    addTearDown(container.dispose);

    final result = await container.read(
      availabilityProvider(
        const AvailabilityKey(tmdbId: 27205, mediaType: 'movie'),
      ).future,
    );
    expect(result, isFalse);
  });

  test('returns false when no plugins cover the mediaType', () async {
    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([]);

    final controller = _buildController(runtime: runtime);
    final container = _containerWith(controller);
    addTearDown(container.dispose);

    final result = await container.read(
      availabilityProvider(
        const AvailabilityKey(tmdbId: 27205, mediaType: 'movie'),
      ).future,
    );
    expect(result, isFalse);
  });

  test(
      'family dedups same key — second read returns the same future + plugin '
      'search runs once', () async {
    final plugin = _PluginMock();
    when(() => plugin.meta).thenReturn(_meta(shortName: 'sc'));
    when(() => plugin.search(any())).thenAnswer(
      (_) async => [
        {
          'id': '1',
          'title': 'Inception',
          'type': 'movie',
          'year': 2010,
        }
      ],
    );

    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([plugin]);

    final controller = _buildController(runtime: runtime);
    final container = _containerWith(controller);
    addTearDown(container.dispose);

    const key = AvailabilityKey(tmdbId: 27205, mediaType: 'movie');
    final f1 = container.read(availabilityProvider(key).future);
    final f2 = container.read(availabilityProvider(key).future);
    // Riverpod's family caches by key — same family entry, same future.
    expect(identical(f1, f2), isTrue);

    final r1 = await f1;
    final r2 = await f2;
    expect(r1, isTrue);
    expect(r2, isTrue);
    verify(() => plugin.search('Inception')).called(1);
  });

  test('different keys produce distinct family entries (different futures)',
      () async {
    final plugin = _PluginMock();
    when(() => plugin.meta).thenReturn(_meta(
      shortName: 'sc',
      capabilities: ['tv'],
    ));
    when(() => plugin.search(any())).thenAnswer(
      (_) async => [
        {
          'id': '1',
          'title': 'Breaking Bad',
          'type': 'tv',
          'year': 2008,
        }
      ],
    );

    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([plugin]);

    final controller = _buildController(
      runtime: runtime,
      resolveHint: (_, __) => const TitleHint(title: 'Breaking Bad', year: 2008),
    );
    final container = _containerWith(controller);
    addTearDown(container.dispose);

    const a = AvailabilityKey(tmdbId: 1396, mediaType: 'tv', season: 1, episode: 1);
    const b = AvailabilityKey(tmdbId: 1396, mediaType: 'tv', season: 2, episode: 3);
    final fa = container.read(availabilityProvider(a).future);
    final fb = container.read(availabilityProvider(b).future);
    expect(identical(fa, fb), isFalse);

    expect(await fa, isTrue);
    expect(await fb, isTrue);
    // Both keys hit the probe (cache miss per season/episode → two calls).
    verify(() => plugin.search('Breaking Bad')).called(2);
  });

  test('AvailabilityKey == / hashCode honour all fields', () {
    const a = AvailabilityKey(tmdbId: 1, mediaType: 'tv', season: 1, episode: 1);
    const a2 = AvailabilityKey(tmdbId: 1, mediaType: 'tv', season: 1, episode: 1);
    const b = AvailabilityKey(tmdbId: 1, mediaType: 'tv', season: 1, episode: 2);
    const c = AvailabilityKey(tmdbId: 2, mediaType: 'tv', season: 1, episode: 1);
    const d = AvailabilityKey(tmdbId: 1, mediaType: 'movie');
    expect(a == a2, isTrue);
    expect(a.hashCode, a2.hashCode);
    expect(a == b, isFalse);
    expect(a == c, isFalse);
    expect(a == d, isFalse);
  });
}
