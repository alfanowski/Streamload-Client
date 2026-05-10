// test/pages/home_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/collections_api.dart';
import 'package:streamload_client/presentation/pages/home_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';

class _CollectionsApiMock extends Mock implements CollectionsApi {}

void main() {
  testWidgets('home shows collection rows from collectionsProvider',
      (tester) async {
    final api = _CollectionsApiMock();
    when(api.list).thenAnswer((_) async => [
          {
            'id': 'trending_movies',
            'title': 'In Tendenza',
            'media_type': 'movie',
            'items': [
              {
                'tmdb_id': 1,
                'media_type': 'movie',
                'title': 'Dune',
                'year': 2021,
                'poster_url': null,
              },
            ],
          },
        ]);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        collectionsApiProvider.overrideWith((_) async => api),
      ],
      child: const MaterialApp(home: HomePage()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('In Tendenza'), findsOneWidget);
    expect(find.text('Dune'), findsOneWidget);
  });
}
