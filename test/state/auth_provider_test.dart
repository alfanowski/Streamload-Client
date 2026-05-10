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

void main() {
  test('on app start with stored cookie + valid /me → authenticated', () async {
    final auth = _AuthApiMock();
    when(() => auth.me()).thenAnswer((_) async => const User(
          id: 'u1', username: 'alice', email: 'a@x.com',
          emailVerified: true, role: 'user',
        ));
    final container = ProviderContainer(overrides: [
      authApiProvider.overrideWith((_) async => auth),
    ]);
    addTearDown(container.dispose);

    // Trigger
    await container.read(authProvider.notifier).bootstrap();
    final state = container.read(authProvider);
    expect(state, isA<AuthAuthenticated>());
    expect((state as AuthAuthenticated).user.username, 'alice');
  });

  test('on app start with no cookie / 401 → unauthenticated', () async {
    final auth = _AuthApiMock();
    when(() => auth.me()).thenThrow(ApiException(401, 'not authenticated'));
    final container = ProviderContainer(overrides: [
      authApiProvider.overrideWith((_) async => auth),
    ]);
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).bootstrap();
    expect(container.read(authProvider), isA<AuthUnauthenticated>());
  });

  test('login on success transitions state to authenticated', () async {
    final auth = _AuthApiMock();
    when(() => auth.login(username: 'alice', password: 'pw'))
        .thenAnswer((_) async => const User(
              id: 'u1', username: 'alice', email: 'a@x.com',
              emailVerified: true, role: 'user',
            ));
    final container = ProviderContainer(overrides: [
      authApiProvider.overrideWith((_) async => auth),
    ]);
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).login(
          username: 'alice', password: 'pw',
        );
    expect(container.read(authProvider), isA<AuthAuthenticated>());
  });
}
