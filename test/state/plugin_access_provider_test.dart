// test/state/plugin_access_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/plugins/loader.dart';
import 'package:streamload_client/state/plugin_access_provider.dart';
import 'package:streamload_client/state/plugins_provider.dart';

void main() {
  test('initial → unknown', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(pluginAccessProvider), PluginAccess.unknown);
  });

  test('after AsyncData(success) → available', () {
    final c = ProviderContainer(overrides: [
      pluginRefreshControllerProvider.overrideWith(
        (ref) => _StubRefreshNotifier(RefreshSummary(
          outcome: RefreshOutcome.success,
          mounted: const ['echo'],
          failed: const [],
          removed: const [],
        )),
      ),
    ]);
    addTearDown(c.dispose);
    expect(c.read(pluginAccessProvider), PluginAccess.available);
  });

  test('after AsyncData(noAccess) → noAccess', () {
    final c = ProviderContainer(overrides: [
      pluginRefreshControllerProvider.overrideWith(
        (ref) => _StubRefreshNotifier(RefreshSummary(
          outcome: RefreshOutcome.noAccess,
          mounted: const [],
          failed: const [],
          removed: const [],
        )),
      ),
    ]);
    addTearDown(c.dispose);
    expect(c.read(pluginAccessProvider), PluginAccess.noAccess);
  });

  test('after AsyncData(networkError) → networkError', () {
    final c = ProviderContainer(overrides: [
      pluginRefreshControllerProvider.overrideWith(
        (ref) => _StubRefreshNotifier(RefreshSummary(
          outcome: RefreshOutcome.networkError,
          mounted: const [],
          failed: const [],
          removed: const [],
        )),
      ),
    ]);
    addTearDown(c.dispose);
    expect(c.read(pluginAccessProvider), PluginAccess.networkError);
  });
}

class _StubRefreshNotifier extends PluginRefreshController {
  _StubRefreshNotifier(RefreshSummary value) : super(_FakeRef()) {
    state = AsyncData(value);
  }
}

class _FakeRef extends Fake implements Ref {}
