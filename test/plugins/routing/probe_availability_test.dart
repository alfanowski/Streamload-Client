// test/plugins/routing/probe_availability_test.dart
//
// ProviderRouter.probeAvailability — Phase F1 of sub-plan 8.
//
// The probe is the title-page "Guarda" CTA's source of truth: it runs
// search+match on every matching plugin in parallel and returns true iff
// at least one of them produces a candidate entry. Streams are NOT
// fetched. Results are cached in-memory for 30 min, so a user scrolling
// through the catalog doesn't re-hit the plugins for titles they already
// opened.
//
// Tests cover:
//   - no matching plugins → false (cached)
//   - one plugin matches → true
//   - all plugins return null (no match) → false
//   - all plugins throw → false
//   - second call within TTL doesn't re-invoke plugin.search (cache hit)
//   - cache key includes (mediaType, title, year, season, episode) so
//     two probes that differ only by season both invoke plugin.search
//   - per-call deadline bounds the wait when a plugin hangs forever
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/domain/play_title.dart';
import 'package:streamload_client/plugins/meta.dart';
import 'package:streamload_client/plugins/plugin.dart';
import 'package:streamload_client/plugins/routing/router.dart';
import 'package:streamload_client/plugins/runtime.dart';

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

/// One plugin entry that the router's tier-1/2 normalized-equality matcher
/// accepts (normalized title matches `Inception`, year within ±1).
Map<String, dynamic> _entry(String title, int? year) => {
      'id': 'x',
      'title': title,
      'type': 'movie',
      'year': year,
    };

void main() {
  test('returns false when no plugins match the mediaType', () async {
    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([]);
    final router = ProviderRouter(runtime: runtime);

    final result = await router.probeAvailability(
      mediaType: 'movie',
      hint: const TitleHint(title: 'Inception', year: 2010),
    );
    expect(result, isFalse);
  });

  test('returns true when one plugin returns a matching entry', () async {
    final plugin = _PluginMock();
    when(() => plugin.meta).thenReturn(_meta(shortName: 'sc'));
    when(() => plugin.search(any())).thenAnswer(
      (_) async => [_entry('Inception', 2010)],
    );

    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([plugin]);
    final router = ProviderRouter(runtime: runtime);

    final result = await router.probeAvailability(
      mediaType: 'movie',
      hint: const TitleHint(title: 'Inception', year: 2010),
    );
    expect(result, isTrue);
    verify(() => plugin.search('Inception')).called(1);
  });

  test('returns false when all plugins return null (no match)', () async {
    final plugin = _PluginMock();
    when(() => plugin.meta).thenReturn(_meta(shortName: 'p'));
    // Title doesn't normalize to "Inception" — matcher returns null for all
    // tiers (no exact, no prefix, no year tier-3a/3b candidates).
    when(() => plugin.search(any())).thenAnswer(
      (_) async => [_entry('Totally Different Movie', 1999)],
    );

    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([plugin]);
    final router = ProviderRouter(runtime: runtime);

    final result = await router.probeAvailability(
      mediaType: 'movie',
      hint: const TitleHint(title: 'Inception', year: 2010),
    );
    expect(result, isFalse);
  });

  test('returns false when all plugins throw (each error contained)',
      () async {
    final p1 = _PluginMock();
    when(() => p1.meta).thenReturn(_meta(shortName: 'p1'));
    when(() => p1.search(any())).thenThrow(StateError('p1 broken'));

    final p2 = _PluginMock();
    when(() => p2.meta).thenReturn(_meta(shortName: 'p2'));
    when(() => p2.search(any())).thenThrow(StateError('p2 broken'));

    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([p1, p2]);
    final router = ProviderRouter(runtime: runtime);

    final result = await router.probeAvailability(
      mediaType: 'movie',
      hint: const TitleHint(title: 'Inception', year: 2010),
    );
    expect(result, isFalse);
  });

  test('second call within TTL uses cache (plugin.search not re-invoked)',
      () async {
    final plugin = _PluginMock();
    when(() => plugin.meta).thenReturn(_meta(shortName: 'sc'));
    when(() => plugin.search(any())).thenAnswer(
      (_) async => [_entry('Inception', 2010)],
    );

    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([plugin]);
    final router = ProviderRouter(runtime: runtime);

    const hint = TitleHint(title: 'Inception', year: 2010);
    final first = await router.probeAvailability(mediaType: 'movie', hint: hint);
    final second =
        await router.probeAvailability(mediaType: 'movie', hint: hint);

    expect(first, isTrue);
    expect(second, isTrue);
    // Only one search call across both probes — the second hit the cache.
    verify(() => plugin.search('Inception')).called(1);
  });

  test('different season values produce distinct cache entries', () async {
    final plugin = _PluginMock();
    when(() => plugin.meta).thenReturn(_meta(
      shortName: 'sc',
      capabilities: ['tv'],
    ));
    when(() => plugin.search(any())).thenAnswer(
      (_) async => [
        {
          'id': 'bb',
          'title': 'Breaking Bad',
          'type': 'tv',
          'year': 2008,
        }
      ],
    );

    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([plugin]);
    final router = ProviderRouter(runtime: runtime);

    const hint = TitleHint(title: 'Breaking Bad', year: 2008);
    await router.probeAvailability(
      mediaType: 'tv',
      hint: hint,
      season: 1,
      episode: 1,
    );
    await router.probeAvailability(
      mediaType: 'tv',
      hint: hint,
      season: 2,
      episode: 3,
    );

    // Cache miss both times because the keys include season/episode.
    verify(() => plugin.search('Breaking Bad')).called(2);
  });

  test('respects probeTimeout when a plugin hangs forever', () async {
    // p_fast resolves immediately with a match.
    final fast = _PluginMock();
    when(() => fast.meta).thenReturn(_meta(shortName: 'fast'));
    when(() => fast.search(any())).thenAnswer(
      (_) async => [_entry('Inception', 2010)],
    );

    // p_slow returns a future that never completes — simulates a plugin
    // stuck on a hung HTTP request.
    final slow = _PluginMock();
    when(() => slow.meta).thenReturn(_meta(shortName: 'slow'));
    final hung = Completer<List<Map<String, dynamic>>>();
    when(() => slow.search(any())).thenAnswer((_) => hung.future);

    final runtime = _PluginRuntimeMock();
    when(() => runtime.all).thenReturn([fast, slow]);
    final router = ProviderRouter(runtime: runtime);

    final stopwatch = Stopwatch()..start();
    final result = await router.probeAvailability(
      mediaType: 'movie',
      hint: const TitleHint(title: 'Inception', year: 2010),
    );
    stopwatch.stop();

    // The fast plugin matched before the slow plugin's hang, so the call
    // returns true. Either:
    //   - fast resolved before the 4s deadline (overwhelmingly likely)
    //   - or the deadline fired with the partial true result already in
    expect(result, isTrue);
    // Bound the wait to well under 5s so the test fails loud if the timeout
    // isn't being honored.
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));

    // Release the hung future so the test process exits cleanly.
    hung.complete(const <Map<String, dynamic>>[]);
  });
}
