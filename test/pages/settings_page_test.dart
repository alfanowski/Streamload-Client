// test/pages/settings_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/settings_api.dart';
import 'package:streamload_client/domain/models/settings.dart';
import 'package:streamload_client/presentation/pages/settings_page.dart';
import 'package:streamload_client/presentation/theme/theme.dart';
import 'package:streamload_client/state/api_client_provider.dart';

class _SettingsApiMock extends Mock implements SettingsApi {}

void main() {
  setUpAll(() => registerFallbackValue(const UserSettingsModel()));

  testWidgets('renders current settings and saves on submit', (tester) async {
    final api = _SettingsApiMock();
    when(api.get).thenAnswer((_) async =>
        const UserSettingsModel(theme: 'dark', audioPrefLang: 'eng'));
    when(() => api.update(any())).thenAnswer((inv) async =>
        inv.positionalArguments.first as UserSettingsModel);

    await tester.pumpWidget(ProviderScope(
      overrides: [settingsApiProvider.overrideWith((_) async => api)],
      child: MaterialApp(theme: streamloadTheme(), home: const SettingsPage()),
    ));
    // Wait for the FutureBuilder to resolve
    await tester.pumpAndSettle();

    expect(find.text('eng'), findsOneWidget); // audio_pref_lang shown
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings.save')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('settings.save')));
    await tester.pump();

    verify(() => api.update(any())).called(1);
  });
}
