// lib/state/settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/settings.dart';
import 'api_client_provider.dart';

/// Read-only view: hits /api/settings each time the provider is built.
final settingsFutureProvider = FutureProvider<UserSettingsModel>((ref) async {
  final api = await ref.watch(settingsApiProvider.future);
  return api.get();
});

/// Controller for mutations. Saves to the server and invalidates the
/// settingsFutureProvider so consumers refresh.
class SettingsController extends StateNotifier<AsyncValue<UserSettingsModel>> {
  SettingsController(this._ref) : super(const AsyncLoading()) {
    _refresh();
  }

  final Ref _ref;

  Future<void> _refresh() async {
    state = const AsyncLoading();
    try {
      final api = await _ref.read(settingsApiProvider.future);
      final s = await api.get();
      state = AsyncData(s);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Persist server-side and update local state.
  Future<UserSettingsModel> save(UserSettingsModel next) async {
    final api = await _ref.read(settingsApiProvider.future);
    final saved = await api.update(next);
    state = AsyncData(saved);
    _ref.invalidate(settingsFutureProvider);
    return saved;
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<UserSettingsModel>>(
  (ref) => SettingsController(ref),
);
