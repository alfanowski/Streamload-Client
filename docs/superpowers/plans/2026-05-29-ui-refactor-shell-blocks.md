# UI Refactor — Shell Building Blocks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the shared row-level building blocks (poster card + content row) and a physical page transition that the Home and category screens will compose, all on top of the Foundation layer.

**Architecture:** Additive new primitives (`MediaPosterCard`, `ContentRow`) plus one extracted, tested page-transition function wired into the existing router. Reads only from `StreamloadTokens` + Foundation primitives. No data/state/plugin code touched.

**Tech Stack:** Flutter 3.5+, go_router, flutter_test. Primitives use plain `TextStyle` (inherit font family from the ambient theme) so widget tests never trigger google_fonts network fetches.

---

## Reference

Builds on `docs/superpowers/plans/2026-05-29-ui-refactor-foundation.md` (merged: `StreamloadTokens`, `AspectRatioMedia`, `MediaCardVm`, `SkeletonBox`). Implements the row + transition parts of spec Section 5.1 and the "physical motion" part of Section 3.4 / navigation comfort in Section 5.

## File Structure

```
lib/presentation/widgets/primitives/
  media_poster_card.dart       # CREATE — 2:3 poster + title + meta + optional progress
  content_row.dart             # CREATE — header + horizontal row; hides when empty; skeleton variant
lib/presentation/theme/
  page_transitions.dart        # CREATE — streamloadPageTransition (slide-up + fade)
lib/router.dart                # MODIFY — _fadeRoute uses streamloadPageTransition

test/widgets/primitives/
  media_poster_card_test.dart  # CREATE
  content_row_test.dart        # CREATE
test/presentation/theme/
  page_transitions_test.dart   # CREATE
```

---

### Task 1: MediaPosterCard primitive

**Files:**
- Create: `lib/presentation/widgets/primitives/media_poster_card.dart`
- Test: `test/widgets/primitives/media_poster_card_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/primitives/media_poster_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/view_models/media_card_vm.dart';
import 'package:streamload_client/presentation/widgets/primitives/media_poster_card.dart';

const _vm = MediaCardVm(
  tmdbId: 1,
  mediaType: 'movie',
  title: 'Dune',
  posterUrl: null,
  metaLine: '2024 · Film',
);

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders title and meta line', (tester) async {
    await tester.pumpWidget(_host(
      const MediaPosterCard(item: _vm, width: 140),
    ));
    await tester.pump();
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('2024 · Film'), findsOneWidget);
  });

  testWidgets('omits meta line when empty', (tester) async {
    const vm = MediaCardVm(
      tmdbId: 2,
      mediaType: 'movie',
      title: 'X',
      posterUrl: null,
      metaLine: '',
    );
    await tester.pumpWidget(_host(const MediaPosterCard(item: vm, width: 140)));
    await tester.pump();
    expect(find.text('X'), findsOneWidget);
    // Only the title Text under the card — no empty meta Text node.
    expect(
      find.descendant(
        of: find.byType(MediaPosterCard),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows a progress bar when progress > 0', (tester) async {
    await tester.pumpWidget(_host(
      const MediaPosterCard(item: _vm, width: 140, progress: 0.5),
    ));
    await tester.pump();
    expect(find.byKey(const Key('poster-progress')), findsOneWidget);
  });

  testWidgets('hides the progress bar when progress is null', (tester) async {
    await tester.pumpWidget(_host(
      const MediaPosterCard(item: _vm, width: 140),
    ));
    await tester.pump();
    expect(find.byKey(const Key('poster-progress')), findsNothing);
  });

  testWidgets('invokes onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(
      MediaPosterCard(item: _vm, width: 140, onTap: () => taps++),
    ));
    await tester.pump();
    await tester.tap(find.byType(MediaPosterCard));
    expect(taps, 1);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/primitives/media_poster_card_test.dart`
Expected: FAIL — URI for `media_poster_card.dart` doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/presentation/widgets/primitives/media_poster_card.dart`:

```dart
// lib/presentation/widgets/primitives/media_poster_card.dart
//
// The single poster tile used by rows and grids. Composes AspectRatioMedia
// (overflow-safe, fallback) with a title + meta line from MediaCardVm. The
// optional amber progress bar marks "continue watching". Text uses plain
// TextStyle so it inherits the ambient theme font (and stays test-safe).
import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../view_models/media_card_vm.dart';
import 'aspect_ratio_media.dart';

class MediaPosterCard extends StatelessWidget {
  const MediaPosterCard({
    super.key,
    required this.item,
    required this.width,
    this.progress,
    this.onTap,
  });

  final MediaCardVm item;
  final double width;

  /// 0..1 resume progress. Null or <= 0 hides the bar.
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showProgress = progress != null && progress! > 0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatioMedia(
                  aspectRatio: 2 / 3,
                  imageUrl: item.posterUrl,
                  fallbackLabel: item.title,
                ),
                if (showProgress)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _ProgressBar(
                      key: const Key('poster-progress'),
                      value: progress!.clamp(0.0, 1.0),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: StreamloadTokens.space2),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: StreamloadTokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (item.metaLine.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  item.metaLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: StreamloadTokens.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(StreamloadTokens.radiusCard),
      ),
      child: Container(
        height: 4,
        color: StreamloadTokens.surfaceHi,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: Container(color: StreamloadTokens.accent),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/primitives/media_poster_card_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/primitives/media_poster_card.dart test/widgets/primitives/media_poster_card_test.dart
git commit -m "feat(primitives): add MediaPosterCard (poster + meta + resume progress)"
```

---

### Task 2: ContentRow primitive (hides when empty + skeleton)

**Files:**
- Create: `lib/presentation/widgets/primitives/content_row.dart`
- Test: `test/widgets/primitives/content_row_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/primitives/content_row_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/view_models/media_card_vm.dart';
import 'package:streamload_client/presentation/widgets/primitives/content_row.dart';

MediaCardVm _vm(int id) => MediaCardVm(
      tmdbId: id,
      mediaType: 'movie',
      title: 'Title $id',
      posterUrl: null,
      metaLine: '2024',
    );

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: SizedBox(height: 320, child: child)));

void main() {
  testWidgets('renders header and items when non-empty', (tester) async {
    await tester.pumpWidget(_host(
      ContentRow(title: 'Tendenze oggi', items: [_vm(1), _vm(2), _vm(3)]),
    ));
    await tester.pump();
    expect(find.text('Tendenze oggi'), findsOneWidget);
    expect(find.text('Title 1'), findsOneWidget);
  });

  testWidgets('renders NOTHING when items is empty (no empty hole)',
      (tester) async {
    await tester.pumpWidget(_host(
      const ContentRow(title: 'Vuota', items: []),
    ));
    await tester.pump();
    expect(find.text('Vuota'), findsNothing);
    expect(find.byType(ContentRow), findsOneWidget); // present...
    final size = tester.getSize(find.byType(ContentRow));
    expect(size.height, 0); // ...but takes zero space
  });

  testWidgets('skeleton variant shows placeholder tiles', (tester) async {
    await tester.pumpWidget(_host(
      const ContentRow.skeleton(title: 'Caricamento', placeholderCount: 4),
    ));
    await tester.pump();
    expect(find.text('Caricamento'), findsOneWidget);
    expect(find.byKey(const Key('row-skeleton-tile')), findsNWidgets(4));
  });

  testWidgets('tapping an item reports the right vm', (tester) async {
    MediaCardVm? tapped;
    await tester.pumpWidget(_host(
      ContentRow(
        title: 'Row',
        items: [_vm(7), _vm(8)],
        onItemTap: (vm) => tapped = vm,
      ),
    ));
    await tester.pump();
    await tester.tap(find.text('Title 7'));
    expect(tapped?.tmdbId, 7);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/primitives/content_row_test.dart`
Expected: FAIL — URI for `content_row.dart` doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/presentation/widgets/primitives/content_row.dart`:

```dart
// lib/presentation/widgets/primitives/content_row.dart
//
// A titled horizontal row of MediaPosterCards. Two robustness guarantees:
//   1. An empty row renders NOTHING (zero-height) — never an orphan header
//      or an empty gap.
//   2. The skeleton constructor reserves the exact row height during load,
//      so there is no jump when data arrives.
import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../view_models/media_card_vm.dart';
import 'media_poster_card.dart';
import 'skeleton_box.dart';

class ContentRow extends StatelessWidget {
  const ContentRow({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
  })  : _skeleton = false,
        placeholderCount = 0;

  const ContentRow.skeleton({
    super.key,
    required this.title,
    this.placeholderCount = 6,
  })  : items = const [],
        onItemTap = null,
        _skeleton = true;

  final String title;
  final List<MediaCardVm> items;
  final void Function(MediaCardVm item)? onItemTap;
  final bool _skeleton;
  final int placeholderCount;

  /// Fixed poster width per breakpoint (Direction A: roomy, fewer per screen).
  static double cardWidthForWidth(double width) {
    if (width < StreamloadTokens.bpPhone) return 116;
    if (width < StreamloadTokens.bpDesktop) return 132;
    return 160;
  }

  @override
  Widget build(BuildContext context) {
    // Robustness rule #4: an empty (non-skeleton) row is not built at all.
    if (!_skeleton && items.isEmpty) {
      return const SizedBox.shrink();
    }

    final cardWidth = cardWidthForWidth(MediaQuery.sizeOf(context).width);
    // poster (2:3) + gap + title line + meta line.
    final rowHeight = cardWidth * 3 / 2 + StreamloadTokens.space2 + 38;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: StreamloadTokens.space3),
          child: Text(
            title,
            style: TextStyle(
              color: StreamloadTokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: rowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: _skeleton ? placeholderCount : items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: StreamloadTokens.space3),
            itemBuilder: (context, i) {
              if (_skeleton) {
                return SizedBox(
                  width: cardWidth,
                  child: SkeletonBox(
                    key: const Key('row-skeleton-tile'),
                    height: cardWidth * 3 / 2,
                  ),
                );
              }
              final item = items[i];
              return MediaPosterCard(
                item: item,
                width: cardWidth,
                onTap: onItemTap == null ? null : () => onItemTap!(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/primitives/content_row_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/primitives/content_row.dart test/widgets/primitives/content_row_test.dart
git commit -m "feat(primitives): add ContentRow (hides when empty + skeleton variant)"
```

---

### Task 3: Physical page transition

**Files:**
- Create: `lib/presentation/theme/page_transitions.dart`
- Modify: `lib/router.dart` (the `_fadeRoute` helper)
- Test: `test/presentation/theme/page_transitions_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/theme/page_transitions_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/theme/page_transitions.dart';

void main() {
  testWidgets('wraps child in a slide + fade and preserves it', (tester) async {
    final controller = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 300),
    )..value = 0.5;
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: streamloadPageTransition(
            controller,
            const Text('PAGE'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('PAGE'), findsOneWidget);
    expect(find.byType(SlideTransition), findsOneWidget);
    expect(find.byType(FadeTransition), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/theme/page_transitions_test.dart`
Expected: FAIL — URI for `page_transitions.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

Create `lib/presentation/theme/page_transitions.dart`:

```dart
// lib/presentation/theme/page_transitions.dart
//
// The app's page transition: a small upward slide that settles with a
// fade — "physical, settles into place" (spec §3.4) without the cheap
// scale reveal that CM-2 rejected. Extracted as a pure function so it can
// be unit-tested and reused by every route.
import 'package:flutter/material.dart';

import 'tokens.dart';

Widget streamloadPageTransition(Animation<double> animation, Widget child) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: StreamloadTokens.standardCurve,
    reverseCurve: Curves.easeIn,
  );
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.02), // ~2% of height — subtle settle
      end: Offset.zero,
    ).animate(curved),
    child: FadeTransition(opacity: curved, child: child),
  );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/presentation/theme/page_transitions_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Wire it into the router**

In `lib/router.dart`, add the import near the other presentation imports:

```dart
import 'presentation/theme/page_transitions.dart';
```

Then replace the `transitionsBuilder` inside `_fadeRoute` (currently a `FadeTransition`) with:

```dart
      transitionsBuilder: (_, animation, __, child) =>
          streamloadPageTransition(animation, child),
```

Also bump the durations to the token values for consistency — change the two duration lines in `_fadeRoute` to:

```dart
      transitionDuration: StreamloadTokens.page,
      reverseTransitionDuration: const Duration(milliseconds: 200),
```

And add the import for tokens at the top of `lib/router.dart` if not already present:

```dart
import 'presentation/theme/tokens.dart';
```

- [ ] **Step 6: Run the existing router/shell tests + analyzer**

Run: `flutter test test/widgets/app_shell_test.dart`
Expected: PASS (unchanged behavior — routes still resolve; only the transition widget changed).

Run: `flutter analyze lib/router.dart lib/presentation/theme/page_transitions.dart`
Expected: No issues.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/theme/page_transitions.dart test/presentation/theme/page_transitions_test.dart lib/router.dart
git commit -m "feat(nav): physical slide+fade page transition wired into router"
```

---

### Task 4: Shell-blocks gate — full suite + analyzer

**Files:** none (verification task)

- [ ] **Step 1: Run the whole test suite**

Run: `flutter test`
Expected: PASS — all prior tests plus the new ones (10 new tests across 3 files) green, 0 failures.

- [ ] **Step 2: Run the analyzer on the new/changed files**

Run: `flutter analyze lib/presentation/widgets/primitives/ lib/presentation/theme/ lib/router.dart`
Expected: No issues.

- [ ] **Step 3: Commit (only if analyze surfaced an auto-fixable lint you corrected)**

```bash
git add -A
git commit -m "chore(primitives): satisfy analyzer for shell building blocks"
```

If nothing changed, skip this commit.

---

## Self-Review

**1. Spec coverage:**
- §5.1 content rows (wide, hide-when-empty, "Continua a guardare" progress) → Task 2 `ContentRow` + Task 1 `MediaPosterCard` progress bar. ✓
- §3.4 physical motion / §5 navigation comfort (non-jarring transitions) → Task 3. ✓
- Hero, category pages, and the actual Home composition → next plan (Home). Noted, not a gap here.

**2. Placeholder scan:** No TBD/TODO; every code step is complete and compilable. ✓

**3. Type consistency:** `MediaCardVm` fields (`tmdbId`, `title`, `posterUrl`, `metaLine`) used identically to the Foundation definition. `MediaPosterCard` params (`item`, `width`, `progress`, `onTap`) match between impl and Task 2's usage. `ContentRow` named/skeleton constructors and `onItemTap` match between impl and tests. `streamloadPageTransition(Animation<double>, Widget)` signature matches test + router call site. `StreamloadTokens.standardCurve`/`page`/`space2`/`space3`/`accent`/`surfaceHi`/`radiusCard` all exist in the merged Foundation. ✓

---

## Next plan

**Home & categories** (Direction A): hero (immersive, parallax, auto-rotate), the row composition consuming `ContentRow` via `AsyncStateView`, "Vedi tutto" → category grid via `ResponsiveGrid`, and the theme rewire to `StreamloadTokens` (cream CTA, Inter body) made visible end-to-end.
