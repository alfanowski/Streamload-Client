// test/state/plugins_provider_test.dart
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/data/secure/secure_storage.dart';
import 'package:streamload_client/plugins/loader.dart';
import 'package:streamload_client/state/database_provider.dart';
import 'package:streamload_client/state/github_pat_provider.dart';
import 'package:streamload_client/state/plugins_provider.dart';

class _MockPluginLoader extends Mock implements PluginLoader {}

class _EmptyBackend implements SecureKvBackend {
  @override
  Future<String?> read(String key) async => null;
  @override
  Future<void> write(String key, String value) async {}
  @override
  Future<void> delete(String key) async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      RefreshResult(mounted: [], failed: [], removed: []),
    );
  });

  test('installedPluginsProvider emits an empty list on a fresh database',
      () async {
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
    ]);
    addTearDown(container.dispose);

    final rows = await container.read(installedPluginsProvider.future);
    expect(rows, isEmpty);
  });

  test('pluginLoaderProvider throws StateError when no PAT set', () async {
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    // Override secureStorageProvider with a backend that always returns null
    // so githubPatProvider resolves to AsyncData(null).
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      secureStorageProvider.overrideWithValue(
        SecureStorage(backend: _EmptyBackend()),
      ),
    ]);
    addTearDown(container.dispose);

    // Let the githubPatProvider _refresh() settle so state is AsyncData(null)
    container.read(githubPatProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await expectLater(
      container.read(pluginLoaderProvider.future),
      throwsA(isA<StateError>()),
    );
  });

  test('PluginRefreshController.refresh() delegates to PluginLoader.refresh()',
      () async {
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    final loader = _MockPluginLoader();
    when(loader.refresh).thenAnswer(
      (_) async => RefreshResult(mounted: ['p1'], failed: [], removed: []),
    );

    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      pluginLoaderProvider.overrideWith((_) async => loader),
    ]);
    addTearDown(container.dispose);

    await container.read(pluginRefreshControllerProvider.notifier).refresh();

    final state = container.read(pluginRefreshControllerProvider);
    expect(state, isA<AsyncData<RefreshResult?>>());
    final result = (state as AsyncData<RefreshResult?>).value;
    expect(result?.mounted, ['p1']);
    verify(loader.refresh).called(1);
  });

  test('PluginRefreshController captures errors as AsyncError', () async {
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    final loader = _MockPluginLoader();
    when(loader.refresh).thenThrow(StateError('network down'));

    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      pluginLoaderProvider.overrideWith((_) async => loader),
    ]);
    addTearDown(container.dispose);

    await container.read(pluginRefreshControllerProvider.notifier).refresh();

    final state = container.read(pluginRefreshControllerProvider);
    expect(state, isA<AsyncError>());
  });
}
