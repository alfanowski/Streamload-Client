// test/state/github_token_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/secure/secure_storage.dart';
import 'package:streamload_client/state/github_token_provider.dart';

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

  test('initial state is AsyncLoading then AsyncData(null) when no token stored',
      () async {
    final storage = SecureStorage(backend: _MemoryBackend());
    final container = makeContainer(storage: storage);

    container.read(githubTokenProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final state = container.read(githubTokenProvider);
    expect(state, const AsyncData<String?>(null));
  });

  test('save() stores the token and updates state', () async {
    final storage = SecureStorage(backend: _MemoryBackend());
    final container = makeContainer(storage: storage);
    container.read(githubTokenProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await container.read(githubTokenProvider.notifier).save('ghu_abc123');

    expect(container.read(githubTokenProvider), const AsyncData<String?>('ghu_abc123'));
    expect(await storage.githubToken(), 'ghu_abc123');
  });

  test('clear() removes the token and resets state to AsyncData(null)', () async {
    final storage = SecureStorage(backend: _MemoryBackend());
    final container = makeContainer(storage: storage);
    container.read(githubTokenProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await container.read(githubTokenProvider.notifier).save('ghu_abc123');
    await container.read(githubTokenProvider.notifier).clear();

    expect(container.read(githubTokenProvider), const AsyncData<String?>(null));
    expect(await storage.githubToken(), isNull);
  });

  test('loads existing token from storage on first build', () async {
    final backend = _MemoryBackend();
    await backend.write('streamload.github_token', 'ghu_preexisting');
    final storage = SecureStorage(backend: backend);
    final container = makeContainer(storage: storage);

    container.read(githubTokenProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
      container.read(githubTokenProvider),
      const AsyncData<String?>('ghu_preexisting'),
    );
  });

  test('backwards compat: reads from legacy github_pat key if new key absent',
      () async {
    final backend = _MemoryBackend();
    // Simulate a user who saved a PAT under the old key before OAuth landed.
    await backend.write('streamload.github_pat', 'ghp_legacy');
    final storage = SecureStorage(backend: backend);
    final container = makeContainer(storage: storage);

    container.read(githubTokenProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
      container.read(githubTokenProvider),
      const AsyncData<String?>('ghp_legacy'),
    );
  });
}
