// test/pages/library_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/library_api.dart';
import 'package:streamload_client/presentation/pages/library_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';

class _LibraryApiMock extends Mock implements LibraryApi {}

void main() {
  testWidgets('LibraryPage renders the movies tab grid by default',
      (tester) async {
    final api = _LibraryApiMock();
    when(() => api.page(
          mediaType: any(named: 'mediaType'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        )).thenAnswer((_) async => {
          'items': [
            {
              'tmdb_id': 1,
              'media_type': 'movie',
              'title': 'Dune',
              'year': 2021,
              'poster_url': null,
            }
          ],
          'page': 1,
          'per_page': 24,
          'total': 1,
        });

    await tester.pumpWidget(ProviderScope(
      overrides: [libraryApiProvider.overrideWith((_) async => api)],
      child: const MaterialApp(home: LibraryPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Dune'), findsOneWidget);
  });

  testWidgets('LibraryPage shows Film and Serie TV tabs', (tester) async {
    final api = _LibraryApiMock();
    when(() => api.page(
          mediaType: any(named: 'mediaType'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        )).thenAnswer((_) async => {
          'items': <Map<String, dynamic>>[],
          'page': 1,
          'per_page': 24,
          'total': 0,
        });

    await tester.pumpWidget(ProviderScope(
      overrides: [libraryApiProvider.overrideWith((_) async => api)],
      child: const MaterialApp(home: LibraryPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Film'), findsOneWidget);
    expect(find.text('Serie TV'), findsOneWidget);
  });
}
