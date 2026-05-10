// lib/state/github_pat_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/secure/secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((_) => SecureStorage());

/// `null` while loading (first call) and when no PAT is stored.
class GithubPatNotifier extends StateNotifier<AsyncValue<String?>> {
  GithubPatNotifier(this._storage) : super(const AsyncLoading()) {
    _refresh();
  }

  final SecureStorage _storage;

  Future<void> _refresh() async {
    try {
      state = AsyncData(await _storage.githubPat());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> save(String pat) async {
    await _storage.setGithubPat(pat);
    state = AsyncData(pat);
  }

  Future<void> clear() async {
    await _storage.clearGithubPat();
    state = const AsyncData(null);
  }
}

final githubPatProvider =
    StateNotifierProvider<GithubPatNotifier, AsyncValue<String?>>((ref) {
  return GithubPatNotifier(ref.watch(secureStorageProvider));
});
