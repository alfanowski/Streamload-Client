# Refactor "La mia lista" — iOS Apple liquid glass + 4 categorie

**Data:** 2026-05-31
**Scope:** Streamload-Client (Flutter), pagina `La mia lista`, focus **iOS / phone**.
**Obiettivo:** rendere `La mia lista` graficamente coerente con la Home (sfondo, ombre,
copertine, titoli) in stile Apple liquid glass nativo, e dividere i contenuti in 4
categorie (Film, Serie TV, Show televisivi, Anime) navigabili come righe Home-style con
"espandi per isolare".

---

## 1. Problema / causa radice

Oggi [`lib/presentation/pages/library_page.dart`](../../../lib/presentation/pages/library_page.dart)
monta un proprio `Scaffold` opaco con `AppBar` Material (`v3BgScrolled`) + `TabBar`
(Film / Serie TV) su sfondo `v3BgBase` (grigio). Questo:

- **copre lo scrim Dynamic Island** che [`AppShell`](../../../lib/presentation/widgets/app_shell.dart)
  dipinge su *ogni* schermata phone (`_TopSystemScrim`) — è la "ombra in alto" che l'utente
  vede nella Home e che manca qui;
- usa una card diversa (`MediaPosterCard` da `primitives/`, titolo 13px w500, niente Hero,
  niente bordo hairline) invece della `PosterCard` editoriale della Home (titolo Fraunces
  corsivo + anno mono, Hero shared-element, hover/press, long-press azioni);
- usa una chrome Material invece del liquid glass nativo Apple già adottato dalla tab bar
  ([`bottom_tab_bar.dart`](../../../lib/presentation/widgets/bottom_tab_bar.dart) /
  [`glass_surface.dart`](../../../lib/presentation/widgets/primitives/glass_surface.dart)).

La Home (`home_page.dart` `_buildMobile`) resta invece full-bleed nera (`ColoredBox(Colors.black)`)
e lascia trasparire lo scrim. **La coerenza si ottiene facendo lo stesso.**

## 2. Obiettivi (cosa significa "coerente alla Home")

- **Ombre (Dynamic Island):** ricompaiono togliendo la `Scaffold` opaca e diventando
  full-bleed nera; lo scrim di `AppShell` fa il resto.
- **Copertine:** identiche alla Home — stessa `PosterCard` (rounded `cardRadius`, `BoxFit.cover`,
  placeholder, Hero, hover/press).
- **Titoli:** Fraunces corsivo + anno mono (la `PosterCard` con `showLabel: true`).
- **Chrome:** liquid glass nativo Apple su iOS (via `GlassSurface`).

## 3. Non-obiettivi (YAGNI)

- Nessun redesign dello schema drift (i generi sono già in `catalog_items.genresJson`).
- Nessun nuovo endpoint backend (si riusa `GET /api/catalog/{id}`).
- Nessuna modifica alla riga "La mia lista" della Home (`_MyListRow`): continua a puntare a `/list`.
- Nessun nuovo idioma glass su desktop/tablet (vedi §9).

## 4. Architettura della pagina (phone)

`LibraryPage` diventa full-bleed:

```
ColoredBox(Colors.black)
 └─ CustomScrollView (BouncingScrollPhysics)   // come home _buildMobile
     ├─ _GlassLargeTitleHeader   (SliverPersistentHeader, pinned)
     └─ <corpo: overview | isolata>            // dipende da _isolated
```

Lo scrim Dynamic Island e lo scrim bottom (tab bar) sono forniti da `AppShell` e tornano
visibili automaticamente perché la pagina non è più opaca.

### 4.1 `_GlassLargeTitleHeader` (nav liquid glass + large title)

`SliverPersistentHeader(pinned: true)` con delegate che interpola sullo `shrinkOffset`:

- **Esteso** (top): titolo grande "La mia lista" in `StreamloadTypography.display` (Fraunces),
  su fondo trasparente (si vede lo scrim).
- **Collassato:** barra compatta con `GlassSurface` (→ liquid glass nativo Apple su iOS) e
  titolo piccolo centrato.
- **Modalità isolata** (`_isolated != null`): la barra mostra un chevron "back" a sinistra +
  il nome della categoria; il tap torna all'overview (`_isolated = null`).

`maxExtent` ≈ altezza large title + safe-area top; `minExtent` ≈ altezza barra compatta +
safe-area top. La compattazione segue il pattern Apple (Music / File).

### 4.2 Corpo — due modalità (stato `String? _isolated`)

**Overview** (`_isolated == null`): per ogni categoria *non vuota*, nell'ordine
**Film · Serie TV · Show televisivi · Anime**, una `PosterRow` (riuso esatto della Home):

- header Fraunces 20 con link "Vedi tutti →";
- tap su "Vedi tutti →" ⇒ `setState(_isolated = categoria)`.

Categorie vuote: nascoste. Se *tutte* vuote ⇒ empty-state (§4.4).

**Isolata** (`_isolated != null`): un `SliverGrid` a tutta pagina della sola categoria
selezionata, con la `PosterCard` della Home (`showLabel: true`). Colonne come
[`ResponsiveGrid`](../../../lib/presentation/widgets/primitives/responsive_grid.dart):
3 phone / 4 tablet / 6 desktop, `childAspectRatio` tarato per poster + label (~0.5).
Le altre categorie non sono renderizzate. Back dall'header.

### 4.3 Stati di caricamento

Durante il resolve/backfill: ogni `PosterRow` mostra i placeholder `Shimmer` (riuso del
loading della Home). In isolata: griglia di placeholder `Shimmer`.

### 4.4 Empty-state

Invariato nei contenuti (icona bookmark + "La tua lista è vuota" + "Tocca ＋ La mia lista su
un titolo per aggiungerlo qui."), ridipinto su nero, centrato sotto lo scrim.

## 5. Classificazione in categorie

Funzione pura, testabile in isolamento:

```
enum LibraryCategory { film, serieTv, show, anime }

LibraryCategory categoryOf(String mediaType, List<int> genreIds) {
  if (mediaType == 'movie') return LibraryCategory.film;
  // mediaType == 'tv'
  if (genreIds.contains(16)) return LibraryCategory.anime;            // Animation
  const showGenres = {10764, 10767, 10763, 10766};                   // Reality/Talk/News/Soap
  if (genreIds.any(showGenres.contains)) return LibraryCategory.show;
  return LibraryCategory.serieTv;
}
```

Etichette UI: Film / Serie TV / Show televisivi / Anime.
Nota: l'euristica `tv + 16 = anime` è la stessa già usata dalla Home (`_buildAnimeRows`).
I film d'animazione (movie + 16) restano in **Film**, coerente con la Home.

## 6. Resolver + backfill (estratto dal widget)

Nuovo provider `myListItemsProvider` (Riverpod `FutureProvider`) che centralizza la logica
oggi inline in `_ResolvedGrid._resolve`. Ritorna una struttura già raggruppata, es.:

```
class LibraryItem { MediaSummary summary; LibraryCategory category; }
// provider ritorna Map<LibraryCategory, List<LibraryItem>> oppure List<LibraryItem>.
```

Algoritmo:

1. `keys = favoritesProvider ∪ watchlistProvider` (deduplicate per `TitleKey`), come oggi.
2. Per ogni key: leggi la riga drift (`catalogDao.get`). Parsing di `genresJson` → `List<int>`.
3. **Backfill:** se la riga manca **oppure** `genresJson` è vuoto/`[]`:
   `catalogApi.get(tmdbId, mediaType)` → `toCompanion()` → `catalogDao.upsert`
   (stesso flusso di `titleProvider`). Concorrenza limitata (~6 in volo) per non
   saturare la rete. Errori per-item: swallowed → l'item usa il bucket di default per
   `mediaType` (`movie`→Film, `tv`→Serie TV). Mai crash.
4. Classifica ogni item con `categoryOf` e raggruppa.

Reattività: il provider dipende da `favoritesProvider` e `watchlistProvider`, quindi
aggiungere/rimuovere un titolo invalida e ricostruisce la lista (come oggi).

Cache-miss residui (titolo non risolvibile nemmeno dal backend): card placeholder con
`#tmdbId` come oggi, nel bucket di default per `mediaType`.

## 7. File toccati

- **Riscritto:** `lib/presentation/pages/library_page.dart` (shell full-bleed, header glass,
  overview/isolata, stato `_isolated`).
- **Nuovo:** widget `_GlassLargeTitleHeader` (inline nel file o in `widgets/`), funzione
  `categoryOf` + `enum LibraryCategory` (in un piccolo file di dominio/presentation),
  provider `myListItemsProvider` (in `lib/state/`).
- **Riuso senza modifiche:** `PosterRow`, `PosterCard`, `GlassSurface`, `Shimmer`,
  `ResponsiveGrid` (per le costanti colonne), scrim di `AppShell`.
- **Rimosso dall'uso in questa pagina:** `MediaPosterCard`, `MediaCardVm`,
  `TabController`/`TabBar`, `Scaffold`/`AppBar`.

## 8. Testing

- **Unit:** `categoryOf` — movie→film; tv+[16]→anime; tv+[10764]→show; tv+[18]→serieTv;
  movie+[16]→film; tv+[] (vuoto)→serieTv.
- **Unit/provider:** `myListItemsProvider` — unione fav∪watchlist con dedup; backfill
  invocato solo per righe mancanti o `genresJson` vuoto; errore backend per-item ⇒ bucket
  default, nessuna eccezione propagata; concorrenza limitata.
- **Widget:** overview mostra solo categorie non vuote nell'ordine atteso; tap "Vedi tutti →"
  entra in isolata e mostra solo quella categoria; back torna all'overview; empty-state quando
  tutto vuoto. (Sotto `flutter test`, `GlassSurface` usa il FakeGlass — vedi `useFake()` — quindi
  i test non caricano shader nativi.)

## 9. Scope desktop / tablet

Focus iOS/phone. Su tablet/desktop la pagina resta funzionante con le stesse righe-categoria
+ isola, ma **senza** la nav glass nativa (idioma iOS): un titolo grande semplice sotto la
`TopNavBar` esistente. Nessuna `Scaffold`/`AppBar` propria (che oggi confliggerebbe con la
`TopNavBar` flottante dell'`AppShell`). Il glass nativo non si applica fuori da iOS.

## 10. Rischi / note

- La compattazione large-title→glass va tarata a mano (`shrinkOffset`) per evitare scatti;
  riferimento visivo: Apple Music / File.
- Il backfill al primo caricamento può fare diverse richieste: cap di concorrenza + stati
  `Shimmer` per non far percepire blocco. Le richieste successive leggono dalla cache.
- L'euristica "Show televisivi" dipende dai generi TMDB presenti; titoli con generi atipici
  possono ricadere in Serie TV — accettabile come bucket di default.
