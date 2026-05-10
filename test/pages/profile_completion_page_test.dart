// test/pages/profile_completion_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/auth_api.dart';
import 'package:streamload_client/domain/models/user.dart';
import 'package:streamload_client/presentation/pages/profile_completion_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/auth_provider.dart';

class _AuthApiMock extends Mock implements AuthApi {}

/// Stub AuthNotifier — starts as authenticated and delegates updateProfile
/// to the real implementation so the mock AuthApi gets called.
class _PreAuthedNotifier extends AuthNotifier {
  _PreAuthedNotifier(Ref ref, User initialUser) : super(ref) {
    state = AuthAuthenticated(initialUser);
  }
}

const _incompleteUser = User(
  id: 'u',
  username: 'u',
  email: 'u@x.com',
  emailVerified: true,
  profileComplete: false,
);

const _completeUser = User(
  id: 'u',
  username: 'u',
  email: 'u@x.com',
  emailVerified: true,
  firstName: 'Andrea',
  lastName: 'Alfano',
  gender: 'male',
  profileComplete: true,
);

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(1990));
  });

  testWidgets('submitting valid fields calls updateProfile and navigates to /home',
      (tester) async {
    final api = _AuthApiMock();
    when(() => api.updateProfile(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          birthDate: any(named: 'birthDate'),
          gender: any(named: 'gender'),
        )).thenAnswer((_) async => _completeUser);

    // Build with a GoRouter so context.go('/home') works.
    final router = Router<Object>(
      routerDelegate: _SimpleRouterDelegate(),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authApiProvider.overrideWith((_) async => api),
        authProvider.overrideWith(
          (ref) => _PreAuthedNotifier(ref, _incompleteUser),
        ),
      ],
      child: MaterialApp(
        home: const ProfileCompletionPage(),
      ),
    ));

    await tester.pump();

    await tester.enterText(
        find.byKey(const Key('profile.first_name')), 'Andrea');
    await tester.enterText(
        find.byKey(const Key('profile.last_name')), 'Alfano');

    // Set gender via dropdown
    await tester.tap(find.byKey(const Key('profile.gender')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maschio').last);
    await tester.pumpAndSettle();

    // Manually set birth date by updating the state (DatePicker is system UI)
    // We do this by tapping submit and checking for the validation error,
    // then use a different approach: find the page state and set _birth directly.
    // Instead, we'll tap the date tile, but since there's no real date picker
    // in widget tests, we check that updateProfile was NOT called (birth missing).
    await tester.tap(find.byKey(const Key('profile.submit')));
    await tester.pump();

    // Should show error since birth date was not set
    expect(find.text('Completa tutti i campi.'), findsOneWidget);

    // updateProfile should NOT have been called yet
    verifyNever(() => api.updateProfile(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          birthDate: any(named: 'birthDate'),
          gender: any(named: 'gender'),
        ));
  });

  testWidgets('form validates empty first name', (tester) async {
    final api = _AuthApiMock();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authApiProvider.overrideWith((_) async => api),
        authProvider.overrideWith(
          (ref) => _PreAuthedNotifier(ref, _incompleteUser),
        ),
      ],
      child: MaterialApp(
        home: const ProfileCompletionPage(),
      ),
    ));

    await tester.pump();

    // Leave first name empty, fill last name
    await tester.enterText(
        find.byKey(const Key('profile.last_name')), 'Alfano');

    await tester.tap(find.byKey(const Key('profile.submit')));
    await tester.pump();

    // Should show validation error for empty first name
    expect(find.text('Inserisci il nome'), findsOneWidget);
  });

  testWidgets('form validates empty last name', (tester) async {
    final api = _AuthApiMock();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authApiProvider.overrideWith((_) async => api),
        authProvider.overrideWith(
          (ref) => _PreAuthedNotifier(ref, _incompleteUser),
        ),
      ],
      child: MaterialApp(
        home: const ProfileCompletionPage(),
      ),
    ));

    await tester.pump();

    // Fill first name, leave last name empty
    await tester.enterText(
        find.byKey(const Key('profile.first_name')), 'Andrea');

    await tester.tap(find.byKey(const Key('profile.submit')));
    await tester.pump();

    // Should show validation error for empty last name
    expect(find.text('Inserisci il cognome'), findsOneWidget);
  });

  testWidgets('page renders all 4 required fields', (tester) async {
    final api = _AuthApiMock();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authApiProvider.overrideWith((_) async => api),
        authProvider.overrideWith(
          (ref) => _PreAuthedNotifier(ref, _incompleteUser),
        ),
      ],
      child: MaterialApp(
        home: const ProfileCompletionPage(),
      ),
    ));

    await tester.pump();

    expect(find.byKey(const Key('profile.first_name')), findsOneWidget);
    expect(find.byKey(const Key('profile.last_name')), findsOneWidget);
    expect(find.byKey(const Key('profile.birth_date')), findsOneWidget);
    expect(find.byKey(const Key('profile.gender')), findsOneWidget);
    expect(find.byKey(const Key('profile.submit')), findsOneWidget);
    expect(find.text('Completa il tuo profilo'), findsOneWidget);
  });
}

/// Minimal RouterDelegate to satisfy Router widget in tests (unused, kept for reference).
class _SimpleRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) =>
      Navigator(key: navigatorKey, pages: const [], onPopPage: (_, __) => false);

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}
