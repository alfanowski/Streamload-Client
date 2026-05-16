// test/pages/settings_page_test.dart
//
// v3 SettingsPage tests (Phase H2). Covers the four user-facing sections
// (Account / Aspetto / Riproduzione / About) and verifies:
//   - the page is completely silent about plugins (no eyebrow, no
//     "Aggiorna", no "Cambia token GitHub")
//   - the Sviluppatore section is hidden unless DEBUG_PLUGINS=true
//   - logout invokes AuthNotifier.logout()
//   - Aspetto rows are disabled (locked)
//   - the audio / subtitle dropdowns persist via playbackPrefsProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamload_client/data/remote/endpoints/auth_api.dart';
import 'package:streamload_client/domain/models/user.dart';
import 'package:streamload_client/presentation/pages/settings_page.dart';
import 'package:streamload_client/presentation/theme/theme.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/auth_provider.dart';
import 'package:streamload_client/state/playback_prefs_provider.dart';

class _AuthApiMock extends Mock implements AuthApi {}

class _PreAuthedNotifier extends AuthNotifier {
  _PreAuthedNotifier(super.ref, User initialUser) {
    state = AuthAuthenticated(initialUser);
  }
}

const _testUser = User(
  id: 'u-1',
  username: 'alfanowski',
  email: 'andrea@example.com',
  emailVerified: true,
  githubUsername: 'alfanowski',
  firstName: 'Andrea',
  lastName: 'Alfano',
  profileComplete: true,
);

Future<void> _pumpSettings(
  WidgetTester tester, {
  required AuthApi authApi,
  User? user,
}) async {
  // Use a tall + wide-ish viewport so the dropdown rows live above the
  // fold without scrolling them into view in every test. Desktop-sized.
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(ProviderScope(
    overrides: [
      authApiProvider.overrideWith((_) async => authApi),
      authProvider.overrideWith(
        (ref) => _PreAuthedNotifier(ref, user ?? _testUser),
      ),
    ],
    child: MaterialApp(
      theme: streamloadTheme(),
      // Wrap in a Scaffold for ScaffoldMessenger (snackbars in the repo
      // link copy fallback) — production renders inside AppShell which
      // also provides Scaffold.
      home: const Scaffold(body: SettingsPage()),
    ),
  ));
  // Let FutureProviders (playback prefs + package info) settle.
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(1990));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('renders Account section with user name + email', (tester) async {
    final api = _AuthApiMock();
    await _pumpSettings(tester, authApi: api);

    expect(find.text('Andrea Alfano'), findsOneWidget);
    expect(find.text('andrea@example.com'), findsOneWidget);
  });

  testWidgets('logout button calls AuthNotifier.logout()', (tester) async {
    final api = _AuthApiMock();
    when(() => api.logout()).thenAnswer((_) async {});
    await _pumpSettings(tester, authApi: api);

    final logoutFinder = find.widgetWithText(InkWell, 'Esci');
    expect(logoutFinder, findsOneWidget);

    await tester.ensureVisible(logoutFinder);
    await tester.tap(logoutFinder);
    await tester.pumpAndSettle();

    verify(() => api.logout()).called(1);
  });

  testWidgets('Aspetto rows are locked (Tema + Lingua "in arrivo")',
      (tester) async {
    final api = _AuthApiMock();
    await _pumpSettings(tester, authApi: api);

    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Lingua'), findsOneWidget);
    // Both rows show the "in arrivo" subtitle.
    expect(find.text('In arrivo'), findsNWidgets(2));
    // Lock icon trails both rows.
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
  });

  testWidgets('Riproduzione audio dropdown persists via playbackPrefsProvider',
      (tester) async {
    final api = _AuthApiMock();
    await _pumpSettings(tester, authApi: api);

    // Default audio label is "Italiano".
    expect(find.text('Italiano'), findsWidgets);

    // Open the audio dropdown via the underlying DropdownButton.
    final audioDropdown = find.descendant(
      of: find.byKey(const Key('settings.audio_lang')),
      matching: find.byType(DropdownButton<String>),
    );
    expect(audioDropdown, findsOneWidget);
    await tester.tap(audioDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inglese').last);
    await tester.pumpAndSettle();

    // Persisted in SharedPreferences under our canonical key.
    final raw = await SharedPreferences.getInstance();
    expect(raw.getString(kPlaybackAudioLangKey), 'en');
  });

  testWidgets('Riproduzione subtitle dropdown persists via playbackPrefsProvider',
      (tester) async {
    final api = _AuthApiMock();
    await _pumpSettings(tester, authApi: api);

    final subDropdown = find.descendant(
      of: find.byKey(const Key('settings.subtitle_lang')),
      matching: find.byType(DropdownButton<String>),
    );
    expect(subDropdown, findsOneWidget);
    await tester.tap(subDropdown);
    await tester.pumpAndSettle();
    // Pick "Inglese" — appears in subtitle options only as a menu item
    // (avoids the ambiguity of "Italiano", which also shows as the audio
    // dropdown's current value above).
    await tester.tap(find.text('Inglese').last);
    await tester.pumpAndSettle();

    final raw = await SharedPreferences.getInstance();
    expect(raw.getString(kPlaybackSubtitleLangKey), 'en');
  });

  testWidgets('About section shows version + GitHub link', (tester) async {
    final api = _AuthApiMock();
    await _pumpSettings(tester, authApi: api);

    // The version label always starts with "Streamload v" — the actual
    // version string is whatever package_info_plus returns under the
    // test harness (mocked to "1.0" by flutter_test by default).
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && (w.data?.startsWith('Streamload v') ?? false),
      ),
      findsOneWidget,
    );
    expect(find.text('Repository GitHub'), findsOneWidget);
    expect(find.text('Licenza MIT'), findsOneWidget);
  });

  testWidgets('Sviluppatore section hidden when DEBUG_PLUGINS=false',
      (tester) async {
    // bool.fromEnvironment defaults to false in tests, so the section
    // must be absent.
    final api = _AuthApiMock();
    await _pumpSettings(tester, authApi: api);
    expect(find.text('Sviluppatore'), findsNothing);
    expect(find.text('Forza aggiornamento plugin'), findsNothing);
  });

  testWidgets('page is silent about plugins (no eyebrow / no manager UI)',
      (tester) async {
    final api = _AuthApiMock();
    await _pumpSettings(tester, authApi: api);

    expect(find.text('Plugin'), findsNothing);
    expect(find.text('Gestisci plugin installati'), findsNothing);
    expect(find.text('Aggiorna pacchetto plugin'), findsNothing);
    expect(find.text('Cambia token GitHub'), findsNothing);
  });
}
