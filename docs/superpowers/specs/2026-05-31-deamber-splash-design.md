# De-ambra globale + Splash "Streamload" handwriting

**Data:** 2026-05-31
**Scope:** Streamload-Client (Flutter), iOS-first.
**Obiettivo:** (A) eliminare ogni colore ambrato dalla piattaforma; (B) refactor della
splash — schermo nero con il wordmark "Streamload" che si **disegna a tratto** (handwriting)
e poi si dissolve in modo **stra smooth** sull'app, senza tagli netti.

---

## A. De-ambra (centralizzato, DRY)

Oggi l'ambra è definita in due file di tema e usata via token:

- `lib/presentation/theme/tokens.dart`: `accent #D4A574`, `accentHover #E8C9A0`
  (`ctaPrimaryBg` è già `#F4F4F6` crema, ok).
- `lib/presentation/theme/colors.dart`: `accent #D4A574`, `accentHover #E2B888`,
  `gold #F4D17C`, `v3AccentYellow #FFC700`, `v3AccentYellowHover #FFDB4D`,
  `v3SurfaceGlassYellow`, `v3CtaPrimaryBg #D4A574`.

Usata (renderizzata) da: `theme.dart` (`colorScheme.primary/secondary`, bordo focus input,
un button bg), `title_page.dart` (rating + progress + marker), `season_episodes.dart`
(icona + progress), `top_nav_bar.dart`, `episode_list.dart` + `primary_pill.dart`
(`v3CtaPrimaryBg`).

**Decisione:** home e player sono monocromi — il player **neutralizza già l'ambra**
forzando `colorScheme.primary: Colors.white`; progress/seek/Play usano `Colors.white` /
crema `#F4F4F6`. Quindi si ridefiniscono i **valori** dei token ambrati al neutro
`#F4F4F6` (la crema di testo/Play della home), senza toccare alcun call-site:

- `StreamloadColors.accent` → `#F4F4F6`; `accentHover` → `#F4F4F6`; `gold` → `#F4F4F6`
- `StreamloadColors.v3CtaPrimaryBg` → `#F4F4F6` (`v3CtaPrimaryFg` resta `#0E0E10`)
- `StreamloadColors.v3AccentYellow` → `#F4F4F6`; `v3AccentYellowHover` → `#F4F4F6`;
  `v3SurfaceGlassYellow` → bianco a bassa opacità
- `StreamloadTokens.accent` → `#F4F4F6`; `accentHover` → `#F4F4F6`

**Sweep:** grep finale per hex ambrati hardcoded (`0xFFD4A574`, `0xFFF4D17C`, `0xFFFFC700`,
`0xFFFFDB4D`, `0xFFE8C9A0`, `0xFFE2B888`) e `Colors.amber`/`Colors.yellow` fuori dai due
file di tema → sostituiti col neutro. (Il commento in `colors.dart` viene aggiornato.)

Risultato: rating, progress, PrimaryPill, pill episodio attiva, bordo focus,
`colorScheme.primary` diventano bianco/crema. Piattaforma 100% monocroma.

## B. Splash

### B.1 Nativa (no white flash)

`ios/Runner/Base.lproj/LaunchScreen.storyboard`: `backgroundColor` da bianco (1,1,1) a
**nero** (0,0,0). L'`imageView` "LaunchImage" è un placeholder vuoto (PNG da 68 byte) →
risultato: schermo nero pulito. (Il branding lo fa la splash Flutter.)

### B.2 Animata — wordmark che si disegna

**Asset/dep (revisione in fase di implementazione):** `text_to_path_maker` a runtime
risultava inaffidabile su questo TTF (la sua cmap non mappava ~metà dei glifi →
"Character not found" per e/a/l/d). Sostituito da un approccio **offline + parsing SVG**:
- Il path SVG di "Streamload" (Fraunces Italic, advances reali via `hmtx`, Y già
  ribaltata) è **pre-generato una volta con fontTools** e incorporato come costante Dart
  in `lib/presentation/widgets/splash/streamload_wordmark_path.dart`. Nessun font/asset
  a runtime, nessun glifo mancante.
- pacchetto **`path_drawing`** (`parseSvgPathData`) per ottenere il `Path` a runtime.

**Componente `SplashGate`** (`lib/presentation/widgets/splash/splash_gate.dart`):
- Avvolge il `child` del `MaterialApp.router` tramite il `builder:` in `app.dart`
  (l'app è già costruita DIETRO la splash → la dissolvenza la rivela senza tagli).
- Stack: `child` (app) in fondo, overlay nero `SplashOverlay` sopra.
- `SplashOverlay` (`StatefulWidget`, `AnimationController` ~2.6s):
  - **0.0–0.72** (≈1.85s): disegno del tratto — `CustomPainter` che, dato il `Path` di
    "Streamload" generato da `text_to_path_maker`, usa `path.computeMetrics()` +
    `extractPath(0, totalLen * draw)` per disegnare progressivamente il contorno (stroke
    bianco crema, width ~2). A `draw==1` un fill morbido (`fillAlpha` 0→1 sull'ultimo 15%).
  - **0.72–0.86**: breve hold.
  - **0.86–1.0** (≈0.36s): **fade-out** dell'intero overlay (`opacity` 1→0, `Curves.easeInOut`)
    + lievissimo `scale` 1.0→1.03 del wordmark → dissolvenza stra smooth sull'app.
  - A fine animazione l'overlay si auto-rimuove (`IgnorePointer` + opacity 0; o
    `setState` che smette di montare l'overlay), restando solo `child`.
- Mostrata **una volta per avvio a freddo** (stato locale del widget radice, non persistito —
  un cold start = una splash). Indipendente da routing/auth.
- Mentre la splash è visibile, l'`authProvider.bootstrap()` (già in `app.dart` post-frame)
  gira: la splash maschera anche il caricamento iniziale.

**Fallback:** se la generazione del path dal TTF fallisce (parsing/asset), l'overlay mostra
comunque il wordmark "Streamload" (Text Fraunces) con un fade-in/out — niente crash, niente
schermo nero infinito.

## Testing

- **De-ambra (unit):** `StreamloadColors.accent == const Color(0xFFF4F4F6)`,
  `v3CtaPrimaryBg == 0xFFF4F4F6`, `v3AccentYellow == 0xFFF4F4F6`,
  `StreamloadTokens.accent == 0xFFF4F4F6`; nessun valore resta `0xFFD4A574`/`0xFFFFC700`.
- **SplashGate (widget):** monta `SplashGate(child: Placeholder)`; il wordmark/overlay è
  presente all'inizio; dopo aver pompato oltre la durata totale, l'overlay è rimosso e
  `child` è visibile e interattivo. (Sotto test si forza il fallback Text per non dipendere
  dal parsing TTF; oppure si pompano le durate.)

## Rischi / note

- `text_to_path_maker`: verificare risoluzione con Flutter 3.41 / Dart SDK del progetto;
  l'API usata è `PMFontReader().parseTTFAsset()` → `PMFont` → generazione path per stringa
  con avanzamento glifi. Se il pacchetto non risolve o l'API differisce, il `SplashGate`
  ricade sul fallback Text (vedi sopra) senza bloccare il resto.
- Il disegno del contorno traccia i **profili** dei glifi serif (non penna a mano libera):
  effetto "lettere inchiostrate/disegnate", elegante e coerente col font della home.
- La splash non deve ritardare l'usabilità: durata totale ~2.6s, e l'app è già viva dietro.
