// test/pages/plugin_onboarding_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/secure/secure_storage.dart';
import 'package:streamload_client/presentation/pages/plugin_onboarding_page.dart';
import 'package:streamload_client/presentation/theme/theme.dart';
import 'package:streamload_client/state/github_token_provider.dart';

class _StorageMock extends Mock implements SecureStorage {}

void main() {
  testWidgets('valid PAT is saved via SecureStorage', (tester) async {
    final storage = _StorageMock();
    when(storage.githubToken).thenAnswer((_) async => null);
    when(() => storage.setGithubToken(any())).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
      ],
      child: MaterialApp(
        theme: streamloadTheme(),
        home: PluginOnboardingPage(verifyPat: (t) async => t == 'github_pat_xyz'),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('onboarding.pat')), 'github_pat_xyz',
    );
    await tester.tap(find.byKey(const Key('onboarding.submit')));
    await tester.pumpAndSettle();

    verify(() => storage.setGithubToken('github_pat_xyz')).called(1);
  });

  testWidgets('invalid PAT shows error and does not save', (tester) async {
    final storage = _StorageMock();
    when(storage.githubToken).thenAnswer((_) async => null);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
      ],
      child: MaterialApp(
        theme: streamloadTheme(),
        home: PluginOnboardingPage(verifyPat: (_) async => false),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('onboarding.pat')), 'wrong',
    );
    await tester.tap(find.byKey(const Key('onboarding.submit')));
    await tester.pumpAndSettle();

    verifyNever(() => storage.setGithubToken(any()));
    expect(find.textContaining('non valido'), findsOneWidget);
  });
}
