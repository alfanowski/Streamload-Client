// test/pages/search_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/search_api.dart';
import 'package:streamload_client/presentation/pages/search_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';

class _SearchApiMock extends Mock implements SearchApi {}

void main() {
  testWidgets('typing in the search field eventually shows results',
      (tester) async {
    final api = _SearchApiMock();
    when(() => api.run('dune')).thenAnswer((_) async => {
          'items': [
            {
              'tmdb_id': 1,
              'media_type': 'movie',
              'title': 'Dune',
              'year': 2021,
              'poster_url': null
            }
          ],
        });
    await tester.pumpWidget(ProviderScope(
      overrides: [searchApiProvider.overrideWith((_) async => api)],
      child: const MaterialApp(home: SearchPage()),
    ));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'dune');
    // pump past the 250ms debounce.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Dune'), findsOneWidget);
  });
}
