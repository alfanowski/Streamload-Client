// test/pages/login_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/auth_api.dart';
import 'package:streamload_client/domain/models/user.dart';
import 'package:streamload_client/presentation/pages/login_page.dart';
import 'package:streamload_client/presentation/theme/theme.dart';
import 'package:streamload_client/state/api_client_provider.dart';

class _AuthApiMock extends Mock implements AuthApi {}

void main() {
  testWidgets('login form submits and calls AuthApi.login', (tester) async {
    final api = _AuthApiMock();
    when(() => api.login(username: 'alice', password: 'pw'))
        .thenAnswer((_) async => const User(
              id: 'u1', username: 'alice', email: 'a@x.com',
              emailVerified: true,
            ));

    await tester.pumpWidget(ProviderScope(
      overrides: [authApiProvider.overrideWith((_) async => api)],
      child: MaterialApp(theme: streamloadTheme(), home: const LoginPage()),
    ));
    await tester.enterText(find.byKey(const Key('login.username')), 'alice');
    await tester.enterText(find.byKey(const Key('login.password')), 'pw');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pump();

    verify(() => api.login(username: 'alice', password: 'pw')).called(1);
  });
}
