# "La mia lista" Liquid Glass Refactor — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render `La mia lista` (iOS/phone) coerente con la Home — sfondo nero full-bleed con scrim Dynamic Island, copertine/titoli identici (`PosterCard`), nav in liquid glass nativo Apple — e suddividere i contenuti in 4 categorie (Film · Serie TV · Show televisivi · Anime) come righe Home-style con "espandi per isolare".

**Architecture:** La pagina smette di montare una `Scaffold`/`AppBar` opaca (che copriva lo scrim di `AppShell`) e diventa `ColoredBox(Colors.black)` + `CustomScrollView` come la Home. Un `SliverPersistentHeader` pinned fornisce il large-title in `GlassSurface` (liquid glass nativo su iOS). Un nuovo `myListItemsProvider` risolve favorites ∪ watchlist dalla cache drift, fa backfill dei generi mancanti dal backend, e classifica ogni item con la funzione pura `categoryFor`. L'overview mostra una `PosterRow` (riuso della Home) per categoria non vuota; il tap su "Vedi tutti →" isola la categoria in un `SliverGrid` di `PosterCard`.

**Tech Stack:** Flutter, Riverpod, drift (cache locale), GoRouter, `native_liquid_glass`/`liquid_glass_renderer` (via `GlassSurface`), mocktail + flutter_test.

**Spec:** `docs/superpowers/specs/2026-05-31-la-mia-lista-liquid-glass-design.md`

---

### Task 1: `LibraryCategory` enum + `categoryFor` (funzione pura)

Classificazione testabile senza Flutter, basata sui **nomi** dei generi (la cache salva `List<String>` localizzati it-IT, non ID).

**Files:**
- Create: `lib/domain/models/library_category.dart`
- Test: `test/domain/library_category_test.dart`

- [ ] **Step 1: Write the failing test**

`test/domain/library_category_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/domain/models/library_category.dart';

void main() {
  test('movie → film (anche con generi animazione)', () {
    expect(categoryFor('movie', const []), LibraryCategory.film);
    expect(categoryFor('movie', const ['Animazione']), LibraryCategory.film);
  });

  test('tv + Animazione → anime (case-insensitive)', () {
    expect(categoryFor('tv', const ['Animazione']), LibraryCategory.anime);
    expect(categoryFor('tv', const ['animazione']), LibraryCategory.anime);
    expect(categoryFor('tv', const ['Animation']), LibraryCategory.anime);
  });

  test('tv + Reality/Soap → show', () {
    expect(categoryFor('tv', const ['Reality']), LibraryCategory.show);
    expect(categoryFor('tv', const ['Soap']), LibraryCategory.show);
  });

  test('tv altri generi o vuoto → serieTv', () {
    expect(categoryFor('tv', const ['Dramma']), LibraryCategory.serieTv);
    expect(categoryFor('tv', const []), LibraryCategory.serieTv);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/library_category_test.dart`
Expected: FAIL — `library_category.dart` non esiste / `categoryFor` undefined.

- [ ] **Step 3: Write the implementation**

`lib/domain/models/library_category.dart`:
```dart
// lib/domain/models/library_category.dart
//
// Classifica un titolo de "La mia lista" in una delle 4 categorie. Si basa sui
// NOMI dei generi (la cache drift salva `genresJson = jsonEncode(genres)` dove
// `genres` è List<String> localizzata it-IT — NON ID numerici). Il backend filtra
// già Talk/News, quindi tra gli "show" arrivano di fatto solo Reality e Soap.
enum LibraryCategory { film, serieTv, show, anime }

LibraryCategory categoryFor(String mediaType, List<String> genres) {
  if (mediaType == 'movie') return LibraryCategory.film;
  // mediaType == 'tv'
  final g = genres.map((s) => s.toLowerCase().trim()).toSet();
  if (g.contains('animazione') || g.contains('animation')) {
    return LibraryCategory.anime;
  }
  const show = {'reality', 'soap'};
  if (g.any(show.contains)) return LibraryCategory.show;
  return LibraryCategory.serieTv;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/domain/library_category_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/domain/models/library_category.dart test/domain/library_category_test.dart
git commit -m "feat(library): LibraryCategory enum + categoryFor classifier"
```

---

### Task 2: `myListItemsProvider` — resolve + backfill + classify

Centralizza la logica oggi inline nel widget. Risolve favorites ∪ watchlist dalla cache drift; per le righe mancanti o senza generi fa backfill dal backend; classifica con `categoryFor`. Concorrenza limitata.

**Files:**
- Create: `lib/state/my_list_items_provider.dart`
- Test: `test/state/my_list_items_provider_test.dart`

- [ ] **Step 1: Write the failing test**

`test/state/my_list_items_provider_test.dart`:
```dart
import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_api.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/data/remote/endpoints/watchlist_api.dart';
import 'package:streamload_client/domain/models/catalog_item.dart';
import 'package:streamload_client/domain/models/library_category.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/database_provider.dart';
import 'package:streamload_client/state/my_list_items_provider.dart';

class _FavApiMock extends Mock implements FavoritesApi {}
class _WlApiMock extends Mock implements WatchlistApi {}
class _CatalogApiMock extends Mock implements CatalogApi {}

ProviderContainer _container({
  required FavoritesApi fav,
  required WatchlistApi wl,
  required CatalogApi catalog,
  required StreamloadDatabase db,
}) {
  final c = ProviderContainer(overrides: [
    favoritesApiProvider.overrideWith((_) async => fav),
    watchlistApiProvider.overrideWith((_) async => wl),
    catalogApiProvider.overrideWith((_) async => catalog),
    databaseProvider.overrideWithValue(db),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('lista vuota → []', () async {
    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => const []);
    when(wl.list).thenAnswer((_) async => const []);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    final c = _container(fav: fav, wl: wl, catalog: _CatalogApiMock(), db: db);
    final items = await c.read(myListItemsProvider.future);
    expect(items, isEmpty);
  });

  test('film con generi già in cache → Film, nessun backfill', () async {
    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => [
          {'tmdb_id': 1, 'media_type': 'movie', 'title': 'Dune', 'year': 2021,
           'poster_url': null},
        ]);
    when(wl.list).thenAnswer((_) async => const []);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    await db.catalogDao.upsert(CatalogItemsCompanion.insert(
      tmdbId: 1,
      mediaType: 'movie',
      title: 'Dune',
      genresJson: Value(jsonEncode(['Azione'])),
    ));
    final catalog = _CatalogApiMock();

    final c = _container(fav: fav, wl: wl, catalog: catalog, db: db);
    final items = await c.read(myListItemsProvider.future);

    expect(items.single.category, LibraryCategory.film);
    verifyNever(() => catalog.get(any(), mediaType: any(named: 'mediaType')));
  });

  test('tv senza cache → backfill dal backend, generi classificano (anime)',
      () async {
    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => [
          {'tmdb_id': 7, 'media_type': 'tv', 'title': 'Naruto', 'year': 2002,
           'poster_url': null},
        ]);
    when(wl.list).thenAnswer((_) async => const []);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = _CatalogApiMock();
    when(() => catalog.get(7, mediaType: 'tv')).thenAnswer((_) async =>
        const CatalogItemResponse(
          tmdbId: 7, mediaType: 'tv', title: 'Naruto', genres: ['Animazione'],
        ));

    final c = _container(fav: fav, wl: wl, catalog: catalog, db: db);
    final items = await c.read(myListItemsProvider.future);

    expect(items.single.category, LibraryCategory.anime);
    verify(() => catalog.get(7, mediaType: 'tv')).called(1);
  });

  test('errore backend per-item → bucket di default (serieTv), nessuna eccezione',
      () async {
    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => [
          {'tmdb_id': 9, 'media_type': 'tv', 'title': '#9', 'year': null,
           'poster_url': null},
        ]);
    when(wl.list).thenAnswer((_) async => const []);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = _CatalogApiMock();
    when(() => catalog.get(9, mediaType: 'tv'))
        .thenThrow(Exception('boom'));

    final c = _container(fav: fav, wl: wl, catalog: catalog, db: db);
    final items = await c.read(myListItemsProvider.future);

    expect(items.single.category, LibraryCategory.serieTv);
    expect(items.single.summary.title, '#9');
  });
}
```

> Nota: se `CatalogItemsCompanion.insert` richiede colonne diverse da quelle qui usate,
> adatta i campi NOT-NULL (`tmdbId`, `mediaType`, `title` sono richiesti; `genresJson` ha
> default `'[]'`). Verifica con `lib/data/local/database.g.dart` se in dubbio.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/state/my_list_items_provider_test.dart`
Expected: FAIL — `my_list_items_provider.dart` / `myListItemsProvider` / `LibraryItem` non esistono.

- [ ] **Step 3: Write the implementation**

`lib/state/my_list_items_provider.dart`:
```dart
// lib/state/my_list_items_provider.dart
//
// Risolve "La mia lista" (favorites ∪ watchlist) in [LibraryItem] classificati.
// Per le righe mancanti o senza generi in cache fa backfill dal backend
// (GET /api/catalog/{id}) e le upserta, così la classificazione in 4 categorie
// è accurata. Concorrenza limitata. Errori per-item: bucket di default per
// mediaType, mai eccezioni.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/catalog_item_x.dart';
import '../domain/models/library_category.dart';
import '../domain/models/media_summary.dart';
import 'api_client_provider.dart';
import 'database_provider.dart';
import 'favorites_provider.dart';
import 'title_provider.dart';
import 'watchlist_provider.dart';

class LibraryItem {
  const LibraryItem({required this.summary, required this.category});
  final MediaSummary summary;
  final LibraryCategory category;
}

final myListItemsProvider =
    FutureProvider.autoDispose<List<LibraryItem>>((ref) async {
  final fav = ref.watch(favoritesProvider).value ?? const <TitleKey>{};
  final wl = ref.watch(watchlistProvider).value ?? const <TitleKey>{};
  // Dedup per TitleKey completo (tmdbId + mediaType): il mediaType guida la categoria.
  final keys = <TitleKey>{...fav, ...wl}.toList(growable: false);
  if (keys.isEmpty) return const <LibraryItem>[];

  final db = ref.watch(databaseProvider);
  final api = await ref.watch(catalogApiProvider.future);

  Future<LibraryItem> resolve(TitleKey k) async {
    var row = await db.catalogDao.get(k.tmdbId, k.mediaType);
    var genres = _parseGenres(row?.genresJson);
    if (row == null || genres.isEmpty) {
      try {
        final fresh = await api.get(k.tmdbId, mediaType: k.mediaType);
        await db.catalogDao.upsert(fresh.toCompanion());
        row = await db.catalogDao.get(k.tmdbId, k.mediaType);
        genres = fresh.genres;
      } catch (_) {
        // Lascia row/genres com'erano: la classificazione ricade sul mediaType.
      }
    }
    final summary = row != null
        ? MediaSummary(
            tmdbId: row.tmdbId,
            mediaType: row.mediaType,
            title: row.title,
            year: row.year,
            posterUrl: row.posterUrl,
            backdropUrl: row.backdropUrl,
          )
        : MediaSummary(
            tmdbId: k.tmdbId,
            mediaType: k.mediaType,
            title: '#${k.tmdbId}',
          );
    return LibraryItem(
      summary: summary,
      category: categoryFor(k.mediaType, genres),
    );
  }

  return _mapBounded(keys, 6, resolve);
});

List<String> _parseGenres(String? json) {
  if (json == null || json.isEmpty) return const [];
  try {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList(growable: false);
    }
  } catch (_) {/* malformed cache → treat as no genres */}
  return const [];
}

/// Mappa [items] con al massimo [concurrency] future in volo, preservando l'ordine.
/// Sicuro single-thread: l'indice viene preso sincronicamente prima di ogni await.
Future<List<T>> _mapBounded<S, T>(
  List<S> items,
  int concurrency,
  Future<T> Function(S) fn,
) async {
  final results = List<T?>.filled(items.length, null);
  var next = 0;
  Future<void> worker() async {
    while (true) {
      final i = next++;
      if (i >= items.length) break;
      results[i] = await fn(items[i]);
    }
  }

  final n = concurrency < items.length ? concurrency : items.length;
  await Future.wait(List.generate(n, (_) => worker()));
  return results.cast<T>();
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/state/my_list_items_provider_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/state/my_list_items_provider.dart test/state/my_list_items_provider_test.dart
git commit -m "feat(library): myListItemsProvider — resolve+backfill+classify"
```

---

### Task 3: `PosterRow.onSeeAll` — callback per "Vedi tutti →"

Aggiunta additiva (low-risk) a `PosterRow`: un callback opzionale per "Vedi tutti →" che ha precedenza sul route `seeAllTo`. Serve all'overview per isolare la categoria invece di navigare.

**Files:**
- Modify: `lib/presentation/widgets/rows/poster_row.dart`
- Test: `test/widgets/rows/poster_row_see_all_test.dart`

- [ ] **Step 1: Write the failing test**

`test/widgets/rows/poster_row_see_all_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/presentation/widgets/rows/poster_row.dart';

void main() {
  testWidgets('tap "Vedi tutti →" chiama onSeeAll', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PosterRow(
          title: 'Film',
          items: const [
            MediaSummary(tmdbId: 1, mediaType: 'movie', title: 'Dune'),
          ],
          onSeeAll: () => tapped = true,
        ),
      ),
    ));
    await tester.pump();

    expect(find.text('Vedi tutti →'), findsOneWidget);
    await tester.tap(find.text('Vedi tutti →'));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/rows/poster_row_see_all_test.dart`
Expected: FAIL — `PosterRow` non ha il parametro `onSeeAll`.

- [ ] **Step 3: Modify `poster_row.dart`**

Aggiungi il campo al costruttore di `PosterRow` (dopo `this.seeAllTo,`):
```dart
    this.seeAllTo,
    this.onSeeAll,
```
e la dichiarazione del campo (dopo il doc-comment di `seeAllTo` / la sua dichiarazione `final String? seeAllTo;`):
```dart
  /// Callback opzionale per "Vedi tutti →". Ha precedenza su [seeAllTo]: quando
  /// impostato, il link chiama questo invece di navigare a una route.
  final VoidCallback? onSeeAll;
```
Passa il callback all'header — sostituisci `_Header(title: title, seeAllTo: seeAllTo,)` con:
```dart
          child: _Header(
            title: title,
            seeAllTo: seeAllTo,
            onSeeAll: onSeeAll,
          ),
```
In `_Header`, aggiungi il campo e usalo. Sostituisci la classe `_Header` interamente con:
```dart
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    this.seeAllTo,
    this.onSeeAll,
  });
  final String title;
  final String? seeAllTo;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final showLink = onSeeAll != null || seeAllTo != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title,
          style: StreamloadTypography.display(
            fontSize: 20,
            italic: false,
          ),
        ),
        const Spacer(),
        if (showLink)
          InkWell(
            onTap: () {
              if (onSeeAll != null) {
                onSeeAll!();
              } else {
                context.go(seeAllTo!);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'Vedi tutti →',
                style: StreamloadTypography.body(
                  fontSize: 12,
                  color: StreamloadColors.v3TextSecondary,
                ).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/rows/poster_row_see_all_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/rows/poster_row.dart test/widgets/rows/poster_row_see_all_test.dart
git commit -m "feat(rows): PosterRow.onSeeAll callback for 'Vedi tutti'"
```

---

### Task 4: `GlassLargeTitleHeader` — sliver nav liquid glass + large title

Header pinned in stile Apple: titolo grande che collassa in una barra compatta `GlassSurface`. In modalità isolata mostra chevron back + nome categoria.

**Files:**
- Create: `lib/presentation/widgets/library/glass_large_title_header.dart`
- Test: `test/widgets/library/glass_large_title_header_test.dart`

- [ ] **Step 1: Write the failing test**

`test/widgets/library/glass_large_title_header_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/library/glass_large_title_header.dart';

Widget _host({String? isolated, VoidCallback? onBack}) {
  return MaterialApp(
    home: Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: GlassLargeTitleHeader(
              title: 'La mia lista',
              topPadding: 0,
              isolatedLabel: isolated,
              onBack: onBack,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 1200)),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('mostra il titolo grande in overview', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();
    expect(find.text('La mia lista'), findsWidgets);
  });

  testWidgets('modalità isolata: chevron back chiama onBack + mostra label',
      (tester) async {
    var back = false;
    await tester.pumpWidget(_host(isolated: 'Anime', onBack: () => back = true));
    await tester.pump();
    expect(find.text('Anime'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    expect(back, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/library/glass_large_title_header_test.dart`
Expected: FAIL — file/classe inesistenti.

- [ ] **Step 3: Write the implementation**

`lib/presentation/widgets/library/glass_large_title_header.dart`:
```dart
// lib/presentation/widgets/library/glass_large_title_header.dart
//
// Nav Apple-style per "La mia lista": un titolo grande (Fraunces) che, scrollando,
// collassa in una barra compatta in liquid glass nativo (GlassSurface → Apple
// Liquid Glass su iOS). In modalità isolata mostra un chevron back + il nome
// categoria.
import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../primitives/glass_surface.dart';

class GlassLargeTitleHeader extends SliverPersistentHeaderDelegate {
  GlassLargeTitleHeader({
    required this.title,
    required this.topPadding,
    this.isolatedLabel,
    this.onBack,
  });

  final String title;
  final double topPadding;

  /// Quando non-null, la barra è in modalità "categoria isolata": chevron back
  /// a sinistra + questo testo come titolo, niente large title.
  final String? isolatedLabel;
  final VoidCallback? onBack;

  static const double _compactBar = 52;
  static const double _largeBand = 60;

  @override
  double get maxExtent => topPadding + _compactBar + _largeBand;

  @override
  double get minExtent => topPadding + _compactBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isolated = isolatedLabel != null;
    // t: 0 = espanso, 1 = collassato.
    final t = (shrinkOffset / _largeBand).clamp(0.0, 1.0);
    final glassOpacity = isolated ? 1.0 : t;

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Barra glass compatta pinnata in alto (il vetro entra man mano che t→1).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + _compactBar,
            child: Opacity(
              opacity: glassOpacity,
              child: const GlassSurface(
                borderRadius: 0,
                child: SizedBox.expand(),
              ),
            ),
          ),
          // Titolo piccolo centrato nella barra compatta.
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            height: _compactBar,
            child: Opacity(
              opacity: isolated ? 1.0 : t,
              child: Center(
                child: Text(
                  isolated ? isolatedLabel! : title,
                  style: StreamloadTypography.display(fontSize: 17, italic: false)
                      .copyWith(color: StreamloadColors.v3TextPrimary),
                ),
              ),
            ),
          ),
          // Chevron back (solo isolata).
          if (isolated)
            Positioned(
              top: topPadding,
              left: 4,
              height: _compactBar,
              child: IconButton(
                icon: const Icon(Icons.chevron_left),
                color: StreamloadColors.v3TextPrimary,
                onPressed: onBack,
              ),
            ),
          // Large title (solo overview, svanisce mentre t→1).
          if (!isolated)
            Positioned(
              left: 16,
              right: 16,
              bottom: 8,
              child: Opacity(
                opacity: 1 - t,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StreamloadTypography.display(fontSize: 32, italic: false)
                      .copyWith(color: StreamloadColors.v3TextPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant GlassLargeTitleHeader old) =>
      old.title != title ||
      old.topPadding != topPadding ||
      old.isolatedLabel != isolatedLabel ||
      old.onBack != onBack;
}
```

> Nota: sotto `flutter test`, `GlassSurface` usa il FakeGlass (`useFake()` → BackdropFilter),
> quindi nessuno shader nativo viene caricato.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/library/glass_large_title_header_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/library/glass_large_title_header.dart test/widgets/library/glass_large_title_header_test.dart
git commit -m "feat(library): GlassLargeTitleHeader sliver nav (liquid glass)"
```

---

### Task 5: Riscrittura `library_page.dart` — overview + isolata

La pagina diventa full-bleed nera + `CustomScrollView`, con header glass, overview di `PosterRow` per categoria, e isolata in `SliverGrid` di `PosterCard`.

**Files:**
- Rewrite: `lib/presentation/pages/library_page.dart`
- Rewrite: `test/pages/library_page_test.dart`

- [ ] **Step 1: Write the failing tests**

Sostituisci interamente `test/pages/library_page_test.dart`:
```dart
// test/pages/library_page_test.dart
import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/data/remote/endpoints/catalog_api.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/data/remote/endpoints/watchlist_api.dart';
import 'package:streamload_client/presentation/pages/library_page.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/database_provider.dart';

class _FavApiMock extends Mock implements FavoritesApi {}
class _WlApiMock extends Mock implements WatchlistApi {}
class _CatalogApiMock extends Mock implements CatalogApi {}

Widget _wrap({
  required FavoritesApi fav,
  required WatchlistApi wl,
  required CatalogApi catalog,
  required StreamloadDatabase db,
}) {
  return ProviderScope(
    overrides: [
      favoritesApiProvider.overrideWith((_) async => fav),
      watchlistApiProvider.overrideWith((_) async => wl),
      catalogApiProvider.overrideWith((_) async => catalog),
      databaseProvider.overrideWithValue(db),
    ],
    child: const MaterialApp(home: Scaffold(body: LibraryPage())),
  );
}

void main() {
  setUp(() {
    // physicalSize impostato per-test (sotto) così Responsive.isPhone è true.
  });

  testWidgets('empty-state quando favorites + watchlist sono vuoti',
      (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => const []);
    when(wl.list).thenAnswer((_) async => const []);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
        _wrap(fav: fav, wl: wl, catalog: _CatalogApiMock(), db: db));
    await tester.pumpAndSettle();

    expect(find.text('La tua lista è vuota'), findsOneWidget);
  });

  testWidgets('un film in cache → riga categoria "Film" in overview',
      (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => [
          {'tmdb_id': 1, 'media_type': 'movie', 'title': 'Dune', 'year': 2021,
           'poster_url': null},
        ]);
    when(wl.list).thenAnswer((_) async => const []);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    await db.catalogDao.upsert(CatalogItemsCompanion.insert(
      tmdbId: 1,
      mediaType: 'movie',
      title: 'Dune',
      genresJson: Value(jsonEncode(['Azione'])),
    ));

    await tester.pumpWidget(
        _wrap(fav: fav, wl: wl, catalog: _CatalogApiMock(), db: db));
    await tester.pumpAndSettle();

    expect(find.text('Film'), findsOneWidget);
    // 'Vedi tutti →' presente sulla riga.
    expect(find.text('Vedi tutti →'), findsOneWidget);
  });

  testWidgets('tap "Vedi tutti →" isola la categoria (header mostra "Film")',
      (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fav = _FavApiMock();
    final wl = _WlApiMock();
    when(fav.list).thenAnswer((_) async => [
          {'tmdb_id': 1, 'media_type': 'movie', 'title': 'Dune', 'year': 2021,
           'poster_url': null},
        ]);
    when(wl.list).thenAnswer((_) async => const []);
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    await db.catalogDao.upsert(CatalogItemsCompanion.insert(
      tmdbId: 1,
      mediaType: 'movie',
      title: 'Dune',
      genresJson: Value(jsonEncode(['Azione'])),
    ));

    await tester.pumpWidget(
        _wrap(fav: fav, wl: wl, catalog: _CatalogApiMock(), db: db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vedi tutti →'));
    await tester.pumpAndSettle();

    // In isolata: il chevron back appare e la riga "Vedi tutti →" sparisce.
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.text('Vedi tutti →'), findsNothing);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/pages/library_page_test.dart`
Expected: FAIL — la nuova `LibraryPage` non esiste ancora con questo contratto.

- [ ] **Step 3: Rewrite `library_page.dart`**

Sostituisci interamente `lib/presentation/pages/library_page.dart`:
```dart
// lib/presentation/pages/library_page.dart
//
// "La mia lista" — la collezione personale (favorites ∪ watchlist). Coerente con
// la Home: full-bleed nera (lo scrim Dynamic Island di AppShell torna visibile),
// nav in liquid glass nativo (GlassLargeTitleHeader), copertine/titoli identici
// (PosterCard). I contenuti sono divisi in 4 categorie (Film · Serie TV · Show
// televisivi · Anime): in overview ogni categoria è una PosterRow Home-style;
// "Vedi tutti →" isola la categoria in una griglia a tutta pagina.
//
// Routed da /list (primario) e /library (back-compat).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/library_category.dart';
import '../../domain/models/media_summary.dart';
import '../../state/my_list_items_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/library/glass_large_title_header.dart';
import '../widgets/poster_card.dart';
import '../widgets/rows/poster_row.dart';

const _categoryOrder = <LibraryCategory>[
  LibraryCategory.film,
  LibraryCategory.serieTv,
  LibraryCategory.show,
  LibraryCategory.anime,
];

String _labelFor(LibraryCategory c) {
  switch (c) {
    case LibraryCategory.film:
      return 'Film';
    case LibraryCategory.serieTv:
      return 'Serie TV';
    case LibraryCategory.show:
      return 'Show televisivi';
    case LibraryCategory.anime:
      return 'Anime';
  }
}

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  LibraryCategory? _isolated;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myListItemsProvider);
    final topPad = MediaQuery.of(context).padding.top;

    return ColoredBox(
      color: Colors.black,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: GlassLargeTitleHeader(
              title: 'La mia lista',
              topPadding: topPad,
              isolatedLabel: _isolated == null ? null : _labelFor(_isolated!),
              onBack: () => setState(() => _isolated = null),
            ),
          ),
          ...async.when(
            data: (items) => _dataSlivers(context, items),
            loading: _loadingSlivers,
            error: (_, __) => _errorSlivers(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  List<Widget> _dataSlivers(BuildContext context, List<LibraryItem> items) {
    if (items.isEmpty) {
      return const [
        SliverFillRemaining(hasScrollBody: false, child: _EmptyState()),
      ];
    }
    final grouped = <LibraryCategory, List<MediaSummary>>{};
    for (final it in items) {
      (grouped[it.category] ??= <MediaSummary>[]).add(it.summary);
    }

    if (_isolated != null) {
      return [_grid(context, grouped[_isolated!] ?? const [], _isolated!)];
    }

    final rows = <Widget>[];
    for (final cat in _categoryOrder) {
      final list = grouped[cat];
      if (list == null || list.isEmpty) continue;
      rows.add(Padding(
        padding: EdgeInsets.only(top: rows.isEmpty ? 8 : 24),
        child: PosterRow(
          title: _labelFor(cat),
          items: list,
          onSeeAll: () => setState(() => _isolated = cat),
        ),
      ));
    }
    return [SliverList(delegate: SliverChildListDelegate(rows))];
  }

  Widget _grid(
      BuildContext context, List<MediaSummary> items, LibraryCategory cat) {
    final columns = Responsive.isPhone(context)
        ? 3
        : Responsive.isTablet(context)
            ? 4
            : 6;
    return SliverPadding(
      padding: StreamloadSpacing.pagePaddingPhone.copyWith(top: 12, bottom: 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final m = items[i];
            final tag = 'lib_${cat.name}_${m.tmdbId}_$i';
            return PosterCard(
              summary: m,
              width: double.infinity,
              showLabel: true,
              heroTag: tag,
              onTap: () => context.push(
                '/title/${m.tmdbId}?media_type=${m.mediaType}',
                extra: tag,
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  List<Widget> _loadingSlivers() {
    return const [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 8),
          child: PosterRow(title: 'Film', items: [], isLoading: true),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 24),
          child: PosterRow(title: 'Serie TV', items: [], isLoading: true),
        ),
      ),
    ];
  }

  List<Widget> _errorSlivers() {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(myListItemsProvider),
            child: Text(
              'Errore di caricamento. Riprova',
              style: StreamloadTypography.v3Body(
                color: StreamloadColors.v3TextMuted,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 56,
              color: StreamloadColors.v3TextMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'La tua lista è vuota',
              style: StreamloadTypography.v3SectionHeader().copyWith(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tocca ＋ La mia lista su un titolo per aggiungerlo qui.',
              style: StreamloadTypography.v3Body(
                color: StreamloadColors.v3TextMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/pages/library_page_test.dart`
Expected: PASS (3 tests). Se la griglia isolata mostra overflow nei log, regola `childAspectRatio` (0.5 → 0.48/0.52) — non pregiudica i test.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/pages/library_page.dart test/pages/library_page_test.dart
git commit -m "feat(library): full-bleed liquid-glass La mia lista with 4 categories"
```

---

### Task 6: Verifica finale — analyzer + suite completa

**Files:** nessuno (verifica).

- [ ] **Step 1: Analyzer pulito**

Run: `flutter analyze`
Expected: "No issues found!" (o solo info preesistenti non legate ai file toccati). Risolvi eventuali warning sui file nuovi/modificati (import inutilizzati: la vecchia `library_page.dart` importava `async_state_view`, `media_poster_card`, `responsive_grid`, `media_card_vm`, `database_provider`, `favorites_provider`, `watchlist_provider`, `title_provider` — assicurati che non restino import morti).

- [ ] **Step 2: Suite completa verde**

Run: `flutter test`
Expected: tutti i test passano, inclusi i nuovi (`test/domain/library_category_test.dart`, `test/state/my_list_items_provider_test.dart`, `test/widgets/rows/poster_row_see_all_test.dart`, `test/widgets/library/glass_large_title_header_test.dart`, `test/pages/library_page_test.dart`) e quelli esistenti della Home (`test/pages/home_page_test.dart`) non regrediscono.

- [ ] **Step 3: Commit finale (se l'analyzer ha richiesto fix)**

```bash
git add -A
git commit -m "chore(library): analyzer cleanup after La mia lista refactor"
```

---

## Self-review (autore del piano)

**Copertura spec:**
- §1/§2 (causa radice, full-bleed + scrim) → Task 5 (ColoredBox nero + CustomScrollView, niente Scaffold opaca).
- §4.1 (nav glass large-title) → Task 4.
- §4.2 (overview PosterRow + isolata SliverGrid, stato `_isolated`) → Task 5 (+ Task 3 per `onSeeAll`).
- §4.3 (loading Shimmer) → Task 5 `_loadingSlivers` (PosterRow `isLoading`).
- §4.4 (empty-state) → Task 5 `_EmptyState`.
- §5 (categoryFor su nomi) → Task 1.
- §6 (resolver + backfill, dedup TitleKey, concorrenza) → Task 2.
- §7 (file toccati / rimossi) → Task 5 rimuove uso di `MediaPosterCard`/`MediaCardVm`/`TabBar`.
- §8 (testing) → Task 1/2/4/5 test.
- §9 (desktop/tablet): la nuova pagina funziona su tutti i breakpoint (la griglia isolata calcola le colonne via `Responsive`); su iOS `GlassSurface` rende il glass nativo, altrove il fallback shader/FakeGlass — coerente con l'assunzione di scope.

**Placeholder scan:** nessun TODO/TBD; ogni step ha codice/comando concreto.

**Type consistency:** `categoryFor(String, List<String>) → LibraryCategory`, `LibraryItem{summary, category}`, `myListItemsProvider: FutureProvider.autoDispose<List<LibraryItem>>`, `GlassLargeTitleHeader{title, topPadding, isolatedLabel, onBack}`, `PosterRow.onSeeAll: VoidCallback?` — coerenti tra task.

**Rischio noto:** `CatalogItemsCompanion.insert` — verificare i campi richiesti in `database.g.dart` se il costruttore nei test si lamenta (named args richiesti vs `Value`). `genresJson` ha default, gli altri NOT-NULL sono `tmdbId/mediaType/title`.
