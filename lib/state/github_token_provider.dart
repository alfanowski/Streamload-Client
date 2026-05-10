// lib/state/github_token_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/secure/secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((_) => SecureStorage());

/// `null` while loading (first call) and when no token is stored.
class GithubTokenNotifier extends StateNotifier<AsyncValue<String?>> {
  GithubTokenNotifier(this._storage) : super(const AsyncLoading()) {
    _refresh();
  }

  final SecureStorage _storage;

  Future<void> _refresh() async {
    try {
      state = AsyncData(await _storage.githubToken());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> save(String token) async {
    await _storage.setGithubToken(token);
    state = AsyncData(token);
  }

  Future<void> clear() async {
    await _storage.clearGithubToken();
    state = const AsyncData(null);
  }
}

final githubTokenProvider =
    StateNotifierProvider<GithubTokenNotifier, AsyncValue<String?>>((ref) {
  return GithubTokenNotifier(ref.watch(secureStorageProvider));
});
