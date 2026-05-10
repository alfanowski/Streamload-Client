// test/state/auth_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_exception.dart';
import 'package:streamload_client/data/remote/endpoints/auth_api.dart';
import 'package:streamload_client/domain/models/user.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/auth_provider.dart';

class _AuthApiMock extends Mock implements AuthApi {}

const _authenticatedUser = User(
  id: 'u1',
  username: 'alfanowski',
  email: 'a@x.com',
  emailVerified: true,
  githubUsername: 'alfanowski',
  profileComplete: false,
);

void main() {
  test('bootstrap with valid /me cookie → authenticated', () async {
    final auth = _AuthApiMock();
    when(() => auth.me()).thenAnswer((_) async => const User(
          id: 'u1', username: 'alice', email: 'a@x.com',
          emailVerified: true,
        ));
    final container = ProviderContainer(overrides: [
      authApiProvider.overrideWith((_) async => auth),
    ]);
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).bootstrap();
    final state = container.read(authProvider);
    expect(state, isA<AuthAuthenticated>());
    expect((state as AuthAuthenticated).user.username, 'alice');
  });

  test('bootstrap with no cookie / 401 → unauthenticated', () async {
    final auth = _AuthApiMock();
    when(() => auth.me()).thenThrow(ApiException(401, 'not authenticated'));
    final container = ProviderContainer(overrides: [
      authApiProvider.overrideWith((_) async => auth),
    ]);
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).bootstrap();
    expect(container.read(authProvider), isA<AuthUnauthenticated>());
  });

  test('loginWithGithub on success → authenticated + returns user', () async {
    final auth = _AuthApiMock();
    when(() => auth.loginWithGithub('ghu_abc'))
        .thenAnswer((_) async => _authenticatedUser);
    final container = ProviderContainer(overrides: [
      authApiProvider.overrideWith((_) async => auth),
    ]);
    addTearDown(container.dispose);

    final user = await container.read(authProvider.notifier).loginWithGithub('ghu_abc');
    expect(container.read(authProvider), isA<AuthAuthenticated>());
    expect(user.githubUsername, 'alfanowski');
    expect(user.profileComplete, false);
  });

  test('loginWithGithub on failure → AuthError + rethrows', () async {
    final auth = _AuthApiMock();
    when(() => auth.loginWithGithub(any()))
        .thenThrow(ApiException(401, 'invalid github token'));
    final container = ProviderContainer(overrides: [
      authApiProvider.overrideWith((_) async => auth),
    ]);
    addTearDown(container.dispose);

    await expectLater(
      container.read(authProvider.notifier).loginWithGithub('bad_token'),
      throwsA(isA<ApiException>()),
    );
    expect(container.read(authProvider), isA<AuthError>());
  });

  test('updateProfile updates state when authenticated', () async {
    final auth = _AuthApiMock();
    when(() => auth.me()).thenAnswer((_) async => _authenticatedUser);
    when(() => auth.updateProfile(
          firstName: 'Andrea',
          lastName: 'Alfano',
          birthDate: any(named: 'birthDate'),
          gender: 'male',
        )).thenAnswer((_) async => _authenticatedUser.copyWith(
          firstName: 'Andrea',
          lastName: 'Alfano',
          gender: 'male',
          profileComplete: true,
        ));
    final container = ProviderContainer(overrides: [
      authApiProvider.overrideWith((_) async => auth),
    ]);
    addTearDown(container.dispose);

    // Bootstrap first to reach authenticated state
    await container.read(authProvider.notifier).bootstrap();
    await container.read(authProvider.notifier).updateProfile(
          firstName: 'Andrea',
          lastName: 'Alfano',
          birthDate: DateTime(1990, 1, 15),
          gender: 'male',
        );

    final state = container.read(authProvider);
    expect(state, isA<AuthAuthenticated>());
    expect((state as AuthAuthenticated).user.profileComplete, true);
    expect(state.user.firstName, 'Andrea');
  });

  test('updateProfile throws StateError when not authenticated', () async {
    final auth = _AuthApiMock();
    final container = ProviderContainer(overrides: [
      authApiProvider.overrideWith((_) async => auth),
    ]);
    addTearDown(container.dispose);

    // State starts as AuthLoading — updateProfile should throw
    await expectLater(
      container.read(authProvider.notifier).updateProfile(
            firstName: 'X',
            lastName: 'Y',
            birthDate: DateTime(1990),
            gender: 'male',
          ),
      throwsA(isA<StateError>()),
    );
  });
}
