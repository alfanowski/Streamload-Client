// test/pages/register_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/auth_api.dart';
import 'package:streamload_client/domain/models/user.dart';
import 'package:streamload_client/presentation/pages/register_page.dart';
import 'package:streamload_client/presentation/theme/theme.dart';
import 'package:streamload_client/state/api_client_provider.dart';

class _AuthApiMock extends Mock implements AuthApi {}

void main() {
  testWidgets('register form submits and calls AuthApi.register', (tester) async {
    final api = _AuthApiMock();
    when(() => api.register(
          username: 'bob', email: 'b@x.com', password: 'pw1234567',
        )).thenAnswer((_) async => const User(
              id: 'u2', username: 'bob', email: 'b@x.com',
              emailVerified: true,
            ));

    await tester.pumpWidget(ProviderScope(
      overrides: [authApiProvider.overrideWith((_) async => api)],
      child: MaterialApp(theme: streamloadTheme(), home: const RegisterPage()),
    ));
    await tester.enterText(find.byKey(const Key('register.username')), 'bob');
    await tester.enterText(find.byKey(const Key('register.email')), 'b@x.com');
    await tester.enterText(find.byKey(const Key('register.password')), 'pw1234567');
    await tester.tap(find.byKey(const Key('register.submit')));
    await tester.pump();

    verify(() => api.register(
          username: 'bob', email: 'b@x.com', password: 'pw1234567',
        )).called(1);
  });
}
