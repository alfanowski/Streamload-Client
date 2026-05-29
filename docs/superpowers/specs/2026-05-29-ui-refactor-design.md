# Streamload Client — UI Refactor (Cinematic Premium)

**Data:** 2026-05-29
**Stato:** Approvato (in attesa di review finale dello spec)
**Ambito:** Overhaul completo del layer `lib/presentation/` dell'app Flutter, con fondazione robusta e migrazione schermata-per-schermata.

---

## 1. Obiettivo

Trasformare la UI del client Streamload in un'esperienza di livello superiore alle principali piattaforme streaming, lungo tre assi **di pari priorità**:

1. **Look premium** — direzione "Cinematic Premium" (lean Apple TV+), anima editoriale (Cinema Magazine) preservata.
2. **Robustezza** — eliminare la fragilità attuale ("tocco una cosa e si rompe tutto"): nessun overflow, nessuna asimmetria, nessun buco vuoto, stati di caricamento/vuoto/errore curati ovunque.
3. **Navigazione comoda** — pattern familiari e prevedibili (back, scroll preservato, deep-link stabili).

### Decisioni di inquadramento (confermate dall'utente)

- **Direzione di stile:** ibrido — ossatura familiare + anima editoriale.
- **Layout Home:** Direzione A "Cinematic Premium" (hero immersivo grande, molta aria, righe larghe).
- **Form factor:** desktop **e** mobile, qualità TV-grade su entrambi (tablet incluso).
- **Scope:** overhaul completo, tutte le schermate.
- **Backend:** è consentito aggiungere campi/endpoint a supporto della UI (trattati come opzionali).
- **Riferimenti:** Apple TV+ (feel premium), Netflix (densità/usabilità), Disney+/Max/Prime (collezioni/brand).
- **Motion:** vivace e fisico (spring, momentum).

### Vincoli espliciti

- **Nessun dettaglio su fonti/qualità mostrato all'utente** — né nel dettaglio titolo né nel player. La selezione sorgente e la qualità sono automatiche e invisibili.
- **Player mobile sempre in landscape** — al tap su Guarda/Riprendi la app forza l'orientamento orizzontale (auto-rotazione + lock + immersive mode). Niente riproduzione in verticale.
- **Niente buchi vuoti e niente asimmetrie** in nessuna condizione di dati.

---

## 2. Approccio: Ibrido (Opzione C)

Costruire una **fondazione robusta** come nuovo strato, poi **migrare le schermate una ad una** sopra di essa, **senza toccare** il layer dati/stato/plugin esistente (Riverpod providers, `playerEngineProvider`, plugin registry, progress tracking, drift DB).

**Perché:** isola la causa della fragilità (il widget layer), mantiene funzionante la logica già collaudata, consente progresso verificabile schermata per schermata e rollback semplice.

Scartate:
- **A (in-place):** trascina la fragilità strutturale esistente.
- **B (rebuild totale):** rischio elevato di regressione sulla logica funzionante.

---

## 3. Fondazione del Design System

Unica fonte di verità: `lib/presentation/theme/tokens.dart` (`StreamloadTokens`). Collassa l'attuale dualismo `v2`/`v3` in un set unico. I vecchi nomi restano come `@Deprecated` alias temporanei durante la migrazione, poi rimossi.

### 3.1 Colore

| Ruolo | Token | Valore |
|---|---|---|
| Background base | `bg` | `#0F0E0D` |
| Background scrolled | `bgScrolled` | `#0A0A09` |
| Surface | `surface` | `#161412` |
| Surface elevata | `surfaceHi` | `#211D1A` |
| Border | `border` | rgba(245,242,236, .08) |
| Border forte | `borderStrong` | rgba(245,242,236, .14) |
| Testo primario | `textPrimary` | `#F5F2EC` |
| Testo secondario | `textSecondary` | rgba(245,242,236, .65) |
| Testo muted | `textMuted` | rgba(245,242,236, .42) |
| **Accento (firma)** | `accent` | `#D4A574` |
| Accento hover | `accentHover` | `#E8C9A0` |
| CTA primaria bg | `ctaPrimaryBg` | `#F5F2EC` (bianco-panna) |
| CTA primaria fg | `ctaPrimaryFg` | `#0F0E0D` |
| Critico/errore | `critical` | `#F26B5E` |

**Regola accento:** l'ambra è una **firma discreta**, usata solo per: progress bar, indicatore nav attiva, focus/hover ring, eyebrow, rating ★. La CTA primaria (Play/Riprendi) è bianco-panna. Il colore "vivo" lo danno i poster/backdrop.

### 3.2 Tipografia

- **Fraunces** (serif, corsivo per display) — titoli hero, titoli pagina, intestazioni sezione.
- **Inter** — corpo, sinossi, descrizioni, label CTA.
- **JetBrains Mono** — metadati (`2024 · 2h 44m · ★ 8.0`), eyebrow/etichette uppercase.

Scala tipografica responsiva centralizzata (display hero più grande su desktop, ridotto su mobile, senza mai andare in overflow).

### 3.3 Spazio, raggi, breakpoint

- Scala spaziatura **4pt**. Padding pagina e gap riga definiti **per breakpoint**.
- Raggi: card 8, card-large 12, pill 999, chip 999.
- Breakpoint: **phone <600 · tablet 600–1024 · desktop ≥1024**.
- Larghezze card derivate da token per breakpoint (poster, backdrop), mai sparse nei widget.

### 3.4 Motion

Curve e durate centralizzate in `StreamloadTokens.motion`. Personalità **fisica**: spring per press-feedback e transizioni, momentum nelle liste, parallax leggero nell'hero, hero-transition poster→dettaglio. Durate base: tap 110ms, hover 200ms, transizione pagina 250–300ms, crossfade hero 600ms. `MediaQuery.disableAnimations` rispettato (accessibilità).

---

## 4. Contratto di robustezza

Regole non negoziabili, applicate da primitive condivise così che valgano ovunque per costruzione.

1. **`AsyncStateView<T>`** — wrapper unico per ogni superficie data-driven. Stati: `loading` → skeleton dimensionato come il contenuto reale; `empty` → stato vuoto curato (icona/illustrazione + messaggio); `error` → messaggio + pulsante riprova (invalida il provider); `data` → contenuto. **Nessuna schermata renderizza un `AsyncValue` a mano.**
2. **View-model null-safe** — i widget ricevono modelli di presentazione già normalizzati: nessun campo nullo grezzo. Poster mancante → placeholder con iniziali/titolo; rating assente → ★ omessa (mai "★ null"); runtime/anno assenti → segmento omesso pulito.
3. **Primitive layout anti-overflow** — `MediaRow`, `ResponsiveGrid`, contenitori media a `AspectRatio` bloccato. Testi con `maxLines` + `overflow: ellipsis`. Niente `Row` non vincolate. Risultato: zero `RenderFlex overflow`.
4. **Niente righe/sezioni vuote** — una riga senza item **non viene costruita** (non lascia spazio/titolo orfano).
5. **Griglie allineate** — conteggio colonne per breakpoint; l'ultima riga non resta sbilenca; spacing coerente.
6. **Immagini** — `cached_network_image` con skeleton → fade-in, `errorWidget` con fallback coerente. Mai riquadro grigio rotto.
7. **Shell stabile** — cambi di rotta/deep-link non rimontano lo shell; nessun salto di layout durante le transizioni.

Queste regole sono **verificabili**: ogni schermata migrata si testa con dati pieni, dati parziali (campi nulli), lista vuota, ed errore di rete.

---

## 5. Navigazione

### Desktop / Tablet
- **Top-nav** floating: logo "Streamload" (Fraunces corsivo) · Home · Film · Serie · Anime · La mia lista · ricerca (`⌘K`) · avatar.
- Voce attiva con underline ambra. Allo scroll la barra si condensa (bg → solido) senza scatti.

### Mobile
- **Bottom-tab** a 4 voci: Home · Cerca · La mia lista · Tu. Target ampi per il pollice, hairline superiore.
- Settings raggiungibile da "Tu".

### Comportamento
- Back coerente; **stato di scroll preservato** tornando alla Home/categoria.
- Transizioni fisiche, nessun salto di layout.
- Deep-link (`/title/:id`, `/watch/:id?...`, `/person/:id`, `/search?q=`) stabili e non rompono lo shell.

---

## 6. Specifiche per schermata

### 6.1 Home & Categorie (Direzione A — Cinematic Premium)
- **Hero immersivo** grande: backdrop con gradiente derivato (palette dominante poster se disponibile), eyebrow ambra, titolo Fraunces grande (o title-art/logo se disponibile), metadati mono, CTA Play (bianco) + La mia lista + Dettagli. Auto-rotazione tra titoli in evidenza con parallax leggero; pausa al tap; swipe su mobile.
- **Righe larghe**, poche per schermata, con intestazione Fraunces e "Vedi tutto". Tipi: Continua a guardare (card backdrop con progress ambra), Tendenze, Nuove uscite, La mia lista (se non vuota), righe-collezione tematiche (universi/franchise), Top di sempre.
- **Categorie** (`/film`, `/serie`, `/anime`) come pagine dedicate con lo stesso impianto, filtrate.
- Densità di catalogo recuperata via "Vedi tutto" → griglia categoria, senza appesantire la Home.

### 6.2 Dettaglio titolo (v2 confermata)
- **Desktop:** 2 colonne. Hero backdrop con titolo Fraunces + metadati mono. Colonna principale: CTA (Play/Riprendi bianco; se ripresa, progress ambra + "Xm rimasti"; + La mia lista; condividi), sinossi (Inter), cast principale (avatar circolari → pagina persona), titoli simili. Per le **serie**: selettore stagione + lista episodi con progress.
- **Sidebar:** **solo metadati editoriali** — Regia, Sceneggiatura, Titolo originale, Paese · Lingua, Generi (chip). **Nessun blocco fonti/qualità.**
- **Mobile:** impilato, **solo hero** (nessuna copertina flottante), CTA full-width, poi sinossi, cast, episodi/simili.
- `PlayCta`: stati `checking`/`play`/`resume`/`unavailable` gestiti, ma **senza mai esporre la sorgente**.

### 6.3 Player
- Chrome minimale Apple TV+: appare/scompare al tap, auto-hide dopo 3s. Top: indietro + titolo (+ S/E per serie). Centro: ±10s + play/pausa. Bottom: scrubber grande (progress ambra, knob, anteprima al drag) + tempi + Sottotitoli + Audio + Schermo intero.
- **Nessun controllo Qualità/Sorgente** — qualità adattiva automatica.
- **Mobile:** all'avvio **forza landscape** (auto-rotazione + lock + immersive/full-screen), ripristina portrait all'uscita. Gesture: doppio tap ±10s, swipe verticale luce/volume, pinch zoom, tap mostra/nascondi.
- **Prossimo episodio**: card a comparsa a fine episodio con countdown + "Salta".

### 6.4 Ricerca
- Ricerca istantanea (debounce), griglia mista (film/serie/persone) responsiva e allineata. Stato vuoto → "Ricerche di tendenza". Niente filtri superflui. URL `?q=` condivisibile.

### 6.5 La mia lista
- Unione preferiti + watchlist (da provider locali), deduplicata; tab Film / Serie. Stato vuoto curato per ogni tab.

### 6.6 Persona
- Hero editoriale (ritratto + nome Fraunces corsivo + bio Inter + meta mono) + filmografia (riga poster, ordinata per rilevanza).

### 6.7 Settings / Profilo
- Ripuliti. **Rimuovere i finti "In arrivo"** (Tema/Lingua): o resi reali o eliminati — nessun placeholder morto. Account, preferenze playback, About. Sezione Developer solo in debug.

### 6.8 Onboarding (GitHub device-flow + completamento profilo)
- Riallineati al nuovo design system (chrome, tipografia, CTA), stessi pattern di robustezza.

---

## 7. Aggiunte backend (opzionali, non bloccanti)

Da introdurre solo se elevano la UI; la UI resta perfetta anche senza (regola di robustezza #2):

- **Palette dominante del poster** → gradienti hero coerenti col contenuto.
- **Title-art / logo del titolo** → hero con logo invece del testo (stile Disney/Netflix), con fallback su titolo Fraunces.
- **Tagline** → riga editoriale sotto il titolo nel dettaglio.
- **Certificazione età** → badge nei metadati.

---

## 8. Strategia di migrazione

1. **Fondazione:** `StreamloadTokens`, primitive di layout (`MediaRow`, `ResponsiveGrid`, media a aspect-ratio bloccato), `AsyncStateView<T>`, sistema view-model null-safe, motion centralizzato.
2. **Shell & navigazione:** top-nav/bottom-tab robusti, transizioni, preservazione scroll.
3. **Migrazione schermate** (in ordine di impatto): Home/Categorie → Dettaglio → Player → Ricerca → La mia lista → Persona → Settings/Profilo → Onboarding.
4. Per ogni schermata: ricostruzione sopra le primitive + verifica nei 4 stati dati (pieno / parziale / vuoto / errore) su phone, tablet, desktop.
5. **Pulizia finale:** rimozione alias `@Deprecated`, rimozione widget morti, audit overflow/asimmetrie.

---

## 9. Criteri di completamento

- Zero `RenderFlex overflow` in qualsiasi breakpoint e stato dati.
- Nessuna riga/sezione vuota, nessuna griglia sbilenca.
- Ogni superficie data-driven passa per `AsyncStateView` con i 4 stati curati.
- Nessun dettaglio fonti/qualità visibile all'utente.
- Player mobile sempre in landscape, mai portrait.
- Navigazione: back coerente, scroll preservato, deep-link stabili.
- Token unici (nessun residuo `v2`/`v3`).
- Look conforme ai mockup approvati (Home A, mono+ambra, Dettaglio v2, Player).

---

## 10. Fuori scope (per ora)

- Profili multipli/account multi-utente.
- Download offline.
- Funzioni social/condivisione avanzata oltre il link.
- Nuove feature di catalogo non legate alla UI.
