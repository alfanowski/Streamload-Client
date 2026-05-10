// test/state/github_pat_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/secure/secure_storage.dart';
import 'package:streamload_client/state/github_pat_provider.dart';

class _MemoryBackend implements SecureKvBackend {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);
}

void main() {
  ProviderContainer makeContainer({SecureStorage? storage}) {
    final container = ProviderContainer(
      overrides: [
        if (storage != null)
          secureStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('initial state is AsyncLoading then AsyncData(null) when no PAT stored',
      () async {
    final storage = SecureStorage(backend: _MemoryBackend());
    final container = makeContainer(storage: storage);

    // Read the notifier to force construction, then pump the event queue so
    // the internal _refresh() async call completes.
    container.read(githubPatProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final state = container.read(githubPatProvider);
    expect(state, const AsyncData<String?>(null));
  });

  test('save() stores the PAT and updates state', () async {
    final storage = SecureStorage(backend: _MemoryBackend());
    final container = makeContainer(storage: storage);
    container.read(githubPatProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await container.read(githubPatProvider.notifier).save('ghp_abc123');

    expect(container.read(githubPatProvider), const AsyncData<String?>('ghp_abc123'));
    expect(await storage.githubPat(), 'ghp_abc123');
  });

  test('clear() removes the PAT and resets state to AsyncData(null)', () async {
    final storage = SecureStorage(backend: _MemoryBackend());
    final container = makeContainer(storage: storage);
    container.read(githubPatProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await container.read(githubPatProvider.notifier).save('ghp_abc123');
    await container.read(githubPatProvider.notifier).clear();

    expect(container.read(githubPatProvider), const AsyncData<String?>(null));
    expect(await storage.githubPat(), isNull);
  });

  test('loads existing PAT from storage on first build', () async {
    final backend = _MemoryBackend();
    await backend.write('streamload.github_pat', 'ghp_preexisting');
    final storage = SecureStorage(backend: backend);
    final container = makeContainer(storage: storage);

    container.read(githubPatProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
      container.read(githubPatProvider),
      const AsyncData<String?>('ghp_preexisting'),
    );
  });
}
