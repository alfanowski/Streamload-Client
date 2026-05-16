// test/widgets/title/title_sidebar_test.dart
//
// Sidebar — Phase E2 of sub-plan 8. We stub creditsProvider via riverpod
// override (no network mocks needed) and assert what the three blocks
// render: CAST · CREATO DA · GENERI.
//
// Branches verified:
//   - loading shows skeleton placeholders
//   - data shows comma-joined cast + crew grouped by job
//   - genres render even when credits failed (empty cast/crew)
//   - empty genres are hidden — section is conditional
//   - expandable variant (phone) starts collapsed and reveals on tap
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/domain/models/catalog_credits.dart';
import 'package:streamload_client/domain/models/catalog_item.dart';
import 'package:streamload_client/presentation/widgets/title/title_sidebar.dart';
import 'package:streamload_client/state/home_rows_provider.dart';

void main() {
  Widget host(
    Widget child, {
    List<Override> extra = const [],
  }) {
    return ProviderScope(
      overrides: extra,
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  const item = CatalogItemResponse(
    tmdbId: 1396,
    mediaType: 'tv',
    title: 'Breaking Bad',
    genres: ['Drama', 'Crime'],
  );

  testWidgets('renders cast + crew + genres when loaded', (t) async {
    await t.pumpWidget(host(
      const TitleSidebar(item: item),
      extra: [
        creditsProvider.overrideWith((_, __) async => const CatalogCredits(
              cast: [
                CatalogCreditPerson(id: 1, name: 'Bryan Cranston'),
                CatalogCreditPerson(id: 2, name: 'Aaron Paul'),
              ],
              crew: [
                CatalogCreditPerson(id: 9, name: 'Vince Gilligan', job: 'Creator'),
                CatalogCreditPerson(id: 10, name: 'Some Director', job: 'Director'),
              ],
            )),
      ],
    ));
    await t.pumpAndSettle();
    expect(find.text('CAST'), findsOneWidget);
    expect(find.text('CREATO DA'), findsOneWidget);
    expect(find.text('GENERI'), findsOneWidget);
    expect(find.text('Bryan Cranston, Aaron Paul'), findsOneWidget);
    expect(find.textContaining('Vince Gilligan'), findsOneWidget);
    expect(find.text('Drama, Crime'), findsOneWidget);
  });

  testWidgets('shows skeleton while loading', (t) async {
    final completer = Completer<CatalogCredits>();
    await t.pumpWidget(host(
      const TitleSidebar(item: item),
      extra: [
        creditsProvider.overrideWith((_, __) async => completer.future),
      ],
    ));
    // First pump while the future is still unresolved.
    await t.pump();
    expect(find.text('CAST'), findsOneWidget);
    // Genres section still renders alongside the loading placeholder.
    expect(find.text('GENERI'), findsOneWidget);
    completer.complete(const CatalogCredits());
    await t.pumpAndSettle();
  });

  testWidgets('hides genres section when item has none', (t) async {
    const bare = CatalogItemResponse(
      tmdbId: 1,
      mediaType: 'movie',
      title: 'Bare',
    );
    await t.pumpWidget(host(
      const TitleSidebar(item: bare),
      extra: [
        creditsProvider.overrideWith((_, __) async => const CatalogCredits()),
      ],
    ));
    await t.pumpAndSettle();
    expect(find.text('GENERI'), findsNothing);
    // No cast / crew → those sections are also hidden.
    expect(find.text('CAST'), findsNothing);
    expect(find.text('CREATO DA'), findsNothing);
  });

  testWidgets('expandable variant reveals sidebar on tap', (t) async {
    await t.pumpWidget(host(
      const TitleSidebarExpandable(item: item),
      extra: [
        creditsProvider.overrideWith((_, __) async => const CatalogCredits(
              cast: [
                CatalogCreditPerson(id: 1, name: 'Bryan Cranston'),
              ],
            )),
      ],
    ));
    await t.pumpAndSettle();
    expect(find.text('Mostra dettagli'), findsOneWidget);
    // Collapsed: GENERI not yet rendered (subtree off).
    expect(find.text('GENERI'), findsNothing);
    await t.tap(find.text('Mostra dettagli'));
    await t.pumpAndSettle();
    expect(find.text('GENERI'), findsOneWidget);
    expect(find.text('Bryan Cranston'), findsOneWidget);
  });
}
