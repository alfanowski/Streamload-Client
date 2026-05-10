// test/state/settings_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/settings_api.dart';
import 'package:streamload_client/domain/models/settings.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/settings_provider.dart';

class _SettingsApiMock extends Mock implements SettingsApi {}

void main() {
  setUpAll(() => registerFallbackValue(const UserSettingsModel()));

  test('reads server defaults on first build', () async {
    final api = _SettingsApiMock();
    when(api.get).thenAnswer((_) async => const UserSettingsModel());
    final container = ProviderContainer(overrides: [
      settingsApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    final s = await container.read(settingsFutureProvider.future);
    expect(s.audioPrefLang, 'ita');
    expect(s.theme, 'auto');
  });

  test('save round-trips through update', () async {
    final api = _SettingsApiMock();
    when(api.get).thenAnswer((_) async => const UserSettingsModel());
    when(() => api.update(any())).thenAnswer((inv) async {
      return inv.positionalArguments.first as UserSettingsModel;
    });
    final container = ProviderContainer(overrides: [
      settingsApiProvider.overrideWith((_) async => api),
    ]);
    addTearDown(container.dispose);

    const updated = UserSettingsModel(theme: 'dark', audioPrefLang: 'eng');
    final out = await container.read(settingsControllerProvider.notifier).save(updated);
    expect(out.theme, 'dark');
    expect(out.audioPrefLang, 'eng');
  });
}
