# UI Refactor — Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the hardened design-system foundation (unified tokens + layout primitives + unified async-state rendering + null-safe view models) that every refactored screen will sit on, eliminating overflow/empty-hole/asymmetry fragility by construction.

**Architecture:** Additive new layer. We create `StreamloadTokens` as the single source of truth and a `primitives/` widget package; existing `StreamloadColors`/`Typography`/`Spacing`/`Motion`/`Responsive` stay untouched so un-migrated screens keep working. Screens migrate onto the new layer one-by-one in later plans. No data/state/plugin code is touched here.

**Tech Stack:** Flutter 3.5+, flutter_riverpod, cached_network_image, google_fonts, flutter_test, mocktail. Tests disable google_fonts runtime fetching (`GoogleFonts.config.allowRuntimeFetching = false`).

---

## Reference: spec

This plan implements Section 3 (Design System) and Section 4 (Robustness contract) of `docs/superpowers/specs/2026-05-29-ui-refactor-design.md`. Per-screen work (Sections 5–8) is covered by later plans.

## Decisions locked for this plan

- **CTA primaria** = cream-white `#F5F2EC` (NOT amber). Amber `#D4A574` is the discreet signature accent only.
- **Canonical breakpoints for new primitives:** phone `<600`, tablet `600–1023`, desktop `≥1024`. These live on `StreamloadTokens`. The legacy `Breakpoints`/`Responsive` (desktop ≥900) stays as-is and is migrated per-screen later — do NOT edit it in this plan (it would shift un-migrated screens).
- **No source/quality data** appears anywhere — not relevant to foundation, but view models never carry source fields.

## File Structure

```
lib/presentation/theme/
  tokens.dart                          # CREATE — StreamloadTokens (single source of truth)
lib/presentation/widgets/primitives/
  skeleton_box.dart                    # CREATE — shimmering placeholder box
  aspect_ratio_media.dart              # CREATE — aspect-locked image + skeleton + fallback
  async_state_view.dart                # CREATE — AsyncStateView<T> + Empty/Error states
  responsive_grid.dart                 # CREATE — aligned responsive grid
lib/presentation/view_models/
  media_card_vm.dart                   # CREATE — null-safe VM from MediaSummary

test/presentation/theme/
  tokens_test.dart                     # CREATE
test/widgets/primitives/
  skeleton_box_test.dart               # CREATE
  aspect_ratio_media_test.dart         # CREATE
  async_state_view_test.dart           # CREATE
  responsive_grid_test.dart            # CREATE
test/view_models/
  media_card_vm_test.dart              # CREATE
```

Each file has one responsibility. Files that change together live together (primitives under `primitives/`, the VM under `view_models/`).

---

### Task 1: Design tokens (`StreamloadTokens`)

**Files:**
- Create: `lib/presentation/theme/tokens.dart`
- Test: `test/presentation/theme/tokens_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/theme/tokens_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/theme/tokens.dart';

void main() {
  group('StreamloadTokens', () {
    test('primary CTA is cream-white, accent is the discreet amber', () {
      expect(StreamloadTokens.ctaPrimaryBg, const Color(0xFFF5F2EC));
      expect(StreamloadTokens.ctaPrimaryFg, const Color(0xFF0F0E0D));
      expect(StreamloadTokens.accent, const Color(0xFFD4A574));
    });

    test('background is warm near-black', () {
      expect(StreamloadTokens.bg, const Color(0xFF0F0E0D));
    });

    test('canonical breakpoints: phone 600, desktop 1024', () {
      expect(StreamloadTokens.bpPhone, 600);
      expect(StreamloadTokens.bpDesktop, 1024);
    });

    test('spacing follows a 4pt scale', () {
      expect(StreamloadTokens.space2, 8);
      expect(StreamloadTokens.space4, 16);
      expect(StreamloadTokens.space16, 64);
    });

    test('motion exposes a tactile spring curve and durations', () {
      expect(StreamloadTokens.springCurve, isA<Curve>());
      expect(StreamloadTokens.tap, const Duration(milliseconds: 110));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/theme/tokens_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../tokens.dart'`.

- [ ] **Step 3: Write minimal implementation**

Create `lib/presentation/theme/tokens.dart`:

```dart
// lib/presentation/theme/tokens.dart
//
// Single source of truth for the 2026 UI refactor ("Cinematic Premium").
// Consolidates the old v2/v3 token split. New primitives and migrated
// screens read ONLY from here. Legacy StreamloadColors/Typography/Spacing/
// Motion stay until each screen is migrated.
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class StreamloadTokens {
  StreamloadTokens._();

  // ── Color ────────────────────────────────────────────────────────────────
  static const Color bg = Color(0xFF0F0E0D); // warm near-black
  static const Color bgScrolled = Color(0xFF0A0A09);
  static const Color surface = Color(0xFF161412);
  static const Color surfaceHi = Color(0xFF211D1A);

  static const Color textPrimary = Color(0xFFF5F2EC); // warm cream
  static final Color textSecondary =
      const Color(0xFFF5F2EC).withValues(alpha: 0.65);
  static final Color textMuted =
      const Color(0xFFF5F2EC).withValues(alpha: 0.42);

  static final Color border = const Color(0xFFF5F2EC).withValues(alpha: 0.08);
  static final Color borderStrong =
      const Color(0xFFF5F2EC).withValues(alpha: 0.14);

  static const Color accent = Color(0xFFD4A574); // discreet signature amber
  static const Color accentHover = Color(0xFFE8C9A0);

  static const Color ctaPrimaryBg = Color(0xFFF5F2EC); // cream-white Play
  static const Color ctaPrimaryFg = Color(0xFF0F0E0D);

  static const Color critical = Color(0xFFF26B5E);

  // ── Radii ────────────────────────────────────────────────────────────────
  static const double radiusCard = 8;
  static const double radiusLarge = 12;
  static const double radiusPill = 999;

  // ── Spacing (4pt scale) ────────────────────────────────────────────────────
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space12 = 48;
  static const double space16 = 64;

  // ── Breakpoints (canonical for new primitives) ─────────────────────────────
  static const double bpPhone = 600;
  static const double bpDesktop = 1024;

  // ── Motion ─────────────────────────────────────────────────────────────────
  static const Duration tap = Duration(milliseconds: 110);
  static const Duration hover = Duration(milliseconds: 200);
  static const Duration page = Duration(milliseconds: 280);
  static const Duration heroCrossfade = Duration(milliseconds: 600);
  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve springCurve = Curves.easeOutBack; // tactile overshoot
  static final SpringDescription spring =
      SpringDescription(mass: 1, stiffness: 320, damping: 24);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/presentation/theme/tokens_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/theme/tokens.dart test/presentation/theme/tokens_test.dart
git commit -m "feat(theme): add unified StreamloadTokens design-system source of truth"
```

---

### Task 2: SkeletonBox primitive

**Files:**
- Create: `lib/presentation/widgets/primitives/skeleton_box.dart`
- Test: `test/widgets/primitives/skeleton_box_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/primitives/skeleton_box_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/primitives/skeleton_box.dart';

void main() {
  testWidgets('renders at the requested size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: SkeletonBox(width: 120, height: 40))),
      ),
    );
    await tester.pump(); // start the repeating animation; do NOT pumpAndSettle

    expect(find.byType(SkeletonBox), findsOneWidget);
    final size = tester.getSize(find.byType(SkeletonBox));
    expect(size.width, 120);
    expect(size.height, 40);
  });

  testWidgets('disposes its controller without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SkeletonBox(width: 10, height: 10))),
    );
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/primitives/skeleton_box_test.dart`
Expected: FAIL — URI for `skeleton_box.dart` doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/presentation/widgets/primitives/skeleton_box.dart`:

```dart
// lib/presentation/widgets/primitives/skeleton_box.dart
//
// A gently pulsing placeholder block. Used wherever real content is still
// loading so layouts reserve the correct space (no jump-on-load).
import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width, this.height, this.borderRadius});

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.65).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: StreamloadTokens.surfaceHi,
          borderRadius: widget.borderRadius ??
              BorderRadius.circular(StreamloadTokens.radiusCard),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/primitives/skeleton_box_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/primitives/skeleton_box.dart test/widgets/primitives/skeleton_box_test.dart
git commit -m "feat(primitives): add SkeletonBox loading placeholder"
```

---

### Task 3: AspectRatioMedia primitive (anti-overflow image with fallback)

**Files:**
- Create: `lib/presentation/widgets/primitives/aspect_ratio_media.dart`
- Test: `test/widgets/primitives/aspect_ratio_media_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/primitives/aspect_ratio_media_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/primitives/aspect_ratio_media.dart';

void main() {
  testWidgets('null url renders the initials fallback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            child: AspectRatioMedia(
              aspectRatio: 2 / 3,
              imageUrl: null,
              fallbackLabel: 'Blade Runner',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('BR'), findsOneWidget);
  });

  testWidgets('empty url renders the fallback (not a broken image)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            child: AspectRatioMedia(
              aspectRatio: 2 / 3,
              imageUrl: '',
              fallbackLabel: 'Dune',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('never overflows inside a tight constraint', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 40,
            height: 40,
            child: AspectRatioMedia(
              aspectRatio: 2 / 3,
              imageUrl: null,
              fallbackLabel: 'X',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/primitives/aspect_ratio_media_test.dart`
Expected: FAIL — URI for `aspect_ratio_media.dart` doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/presentation/widgets/primitives/aspect_ratio_media.dart`:

```dart
// lib/presentation/widgets/primitives/aspect_ratio_media.dart
//
// Aspect-locked media tile. Guarantees: never overflows (AspectRatio +
// ClipRRect), always shows *something* (skeleton while loading, initials
// fallback on null/empty/error). This is the only way the app loads poster /
// backdrop imagery — no raw Image.network anywhere.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'skeleton_box.dart';

class AspectRatioMedia extends StatelessWidget {
  const AspectRatioMedia({
    super.key,
    required this.aspectRatio,
    required this.imageUrl,
    required this.fallbackLabel,
    this.borderRadius,
  });

  final double aspectRatio;
  final String? imageUrl;
  final String fallbackLabel;
  final BorderRadius? borderRadius;

  bool get _hasUrl => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(StreamloadTokens.radiusCard);
    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: _hasUrl
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SkeletonBox(),
                errorWidget: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: StreamloadTokens.surfaceHi,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(StreamloadTokens.space2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _initials(fallbackLabel),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: StreamloadTokens.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  String _initials(String raw) {
    final parts = raw
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '—';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/primitives/aspect_ratio_media_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/primitives/aspect_ratio_media.dart test/widgets/primitives/aspect_ratio_media_test.dart
git commit -m "feat(primitives): add AspectRatioMedia (overflow-safe image + fallback)"
```

---

### Task 4: AsyncStateView + Empty/Error states

**Files:**
- Create: `lib/presentation/widgets/primitives/async_state_view.dart`
- Test: `test/widgets/primitives/async_state_view_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/primitives/async_state_view_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/primitives/async_state_view.dart';

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('loading state shows the provided loading widget',
      (tester) async {
    await tester.pumpWidget(_host(
      AsyncStateView<List<int>>(
        value: const AsyncValue.loading(),
        loading: const Text('LOADING'),
        onRetry: () {},
        data: (d) => const Text('DATA'),
      ),
    ));
    expect(find.text('LOADING'), findsOneWidget);
  });

  testWidgets('data state shows the data builder', (tester) async {
    await tester.pumpWidget(_host(
      AsyncStateView<List<int>>(
        value: const AsyncValue.data([1, 2, 3]),
        loading: const Text('LOADING'),
        onRetry: () {},
        data: (d) => Text('DATA ${d.length}'),
      ),
    ));
    expect(find.text('DATA 3'), findsOneWidget);
  });

  testWidgets('empty predicate routes to the empty state', (tester) async {
    await tester.pumpWidget(_host(
      AsyncStateView<List<int>>(
        value: const AsyncValue.data(<int>[]),
        loading: const Text('LOADING'),
        onRetry: () {},
        isEmpty: (d) => d.isEmpty,
        empty: const Text('EMPTY'),
        data: (d) => const Text('DATA'),
      ),
    ));
    expect(find.text('EMPTY'), findsOneWidget);
    expect(find.text('DATA'), findsNothing);
  });

  testWidgets('error state shows retry and invokes onRetry', (tester) async {
    var retried = 0;
    await tester.pumpWidget(_host(
      AsyncStateView<List<int>>(
        value: AsyncValue.error('boom', StackTrace.empty),
        loading: const Text('LOADING'),
        onRetry: () => retried++,
        data: (d) => const Text('DATA'),
      ),
    ));
    expect(find.text('Riprova'), findsOneWidget);
    await tester.tap(find.text('Riprova'));
    expect(retried, 1);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/primitives/async_state_view_test.dart`
Expected: FAIL — URI for `async_state_view.dart` doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/presentation/widgets/primitives/async_state_view.dart`:

```dart
// lib/presentation/widgets/primitives/async_state_view.dart
//
// The ONLY way a screen renders a Riverpod AsyncValue. Guarantees every
// data-driven surface handles all four states: loading, empty, error
// (with retry), data. No screen calls AsyncValue.when by hand — that's how
// "empty holes" and crash-on-error slipped in before.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/tokens.dart';

class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.value,
    required this.loading,
    required this.onRetry,
    required this.data,
    this.isEmpty,
    this.empty,
  });

  final AsyncValue<T> value;
  final Widget loading;
  final VoidCallback onRetry;
  final Widget Function(T data) data;

  /// Optional predicate: when it returns true the [empty] widget is shown
  /// instead of [data]. If null, data is always rendered.
  final bool Function(T data)? isEmpty;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading,
      error: (_, __) => StreamloadErrorState(onRetry: onRetry),
      data: (d) {
        if (isEmpty != null && isEmpty!(d)) {
          return empty ??
              const StreamloadEmptyState(message: 'Niente da mostrare');
        }
        return data(d);
      },
    );
  }
}

class StreamloadEmptyState extends StatelessWidget {
  const StreamloadEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.movie_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(StreamloadTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: StreamloadTokens.textMuted, size: 40),
            const SizedBox(height: StreamloadTokens.space3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: StreamloadTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class StreamloadErrorState extends StatelessWidget {
  const StreamloadErrorState({
    super.key,
    required this.onRetry,
    this.message = 'Qualcosa è andato storto',
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(StreamloadTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: StreamloadTokens.critical, size: 40),
            const SizedBox(height: StreamloadTokens.space3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: StreamloadTokens.textSecondary),
            ),
            const SizedBox(height: StreamloadTokens.space4),
            TextButton(
              onPressed: onRetry,
              child: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/primitives/async_state_view_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/primitives/async_state_view.dart test/widgets/primitives/async_state_view_test.dart
git commit -m "feat(primitives): add AsyncStateView with curated empty/error/retry states"
```

---

### Task 5: ResponsiveGrid primitive

**Files:**
- Create: `lib/presentation/widgets/primitives/responsive_grid.dart`
- Test: `test/widgets/primitives/responsive_grid_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/primitives/responsive_grid_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/primitives/responsive_grid.dart';

void main() {
  group('ResponsiveGrid.columnsForWidth', () {
    test('phone width uses phoneColumns', () {
      expect(
        ResponsiveGrid.columnsForWidth(360,
            phoneColumns: 3, tabletColumns: 4, desktopColumns: 6),
        3,
      );
    });
    test('tablet width uses tabletColumns', () {
      expect(
        ResponsiveGrid.columnsForWidth(800,
            phoneColumns: 3, tabletColumns: 4, desktopColumns: 6),
        4,
      );
    });
    test('desktop width uses desktopColumns', () {
      expect(
        ResponsiveGrid.columnsForWidth(1280,
            phoneColumns: 3, tabletColumns: 4, desktopColumns: 6),
        6,
      );
    });
  });

  testWidgets('builds every item without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1280,
            height: 800,
            child: ResponsiveGrid(
              itemCount: 12,
              itemAspectRatio: 2 / 3,
              itemBuilder: (context, i) => Text('item$i'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('item0'), findsOneWidget);
    expect(find.text('item11'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/primitives/responsive_grid_test.dart`
Expected: FAIL — URI for `responsive_grid.dart` doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/presentation/widgets/primitives/responsive_grid.dart`:

```dart
// lib/presentation/widgets/primitives/responsive_grid.dart
//
// Aligned, breakpoint-aware grid. Column count derives from the available
// width via StreamloadTokens breakpoints, so the last row is never lopsided
// and tiles never overflow. Non-scrolling by default (meant to live inside
// a CustomScrollView/Column on a page that scrolls as a whole).
import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemAspectRatio,
    this.spacing = StreamloadTokens.space3,
    this.phoneColumns = 3,
    this.tabletColumns = 4,
    this.desktopColumns = 6,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double itemAspectRatio;
  final double spacing;
  final int phoneColumns;
  final int tabletColumns;
  final int desktopColumns;

  static int columnsForWidth(
    double width, {
    required int phoneColumns,
    required int tabletColumns,
    required int desktopColumns,
  }) {
    if (width < StreamloadTokens.bpPhone) return phoneColumns;
    if (width < StreamloadTokens.bpDesktop) return tabletColumns;
    return desktopColumns;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsForWidth(
          constraints.maxWidth,
          phoneColumns: phoneColumns,
          tabletColumns: tabletColumns,
          desktopColumns: desktopColumns,
        );
        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: itemAspectRatio,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/primitives/responsive_grid_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/primitives/responsive_grid.dart test/widgets/primitives/responsive_grid_test.dart
git commit -m "feat(primitives): add ResponsiveGrid (aligned, breakpoint-aware)"
```

---

### Task 6: MediaCardVm (null-safe view model)

**Files:**
- Create: `lib/presentation/view_models/media_card_vm.dart`
- Test: `test/view_models/media_card_vm_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/view_models/media_card_vm_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/presentation/view_models/media_card_vm.dart';

void main() {
  group('MediaCardVm.fromSummary', () {
    test('maps a full summary', () {
      const s = MediaSummary(
        tmdbId: 550,
        mediaType: 'movie',
        title: 'Fight Club',
        year: 1999,
        posterUrl: 'https://x/p.jpg',
      );
      final vm = MediaCardVm.fromSummary(s);
      expect(vm.tmdbId, 550);
      expect(vm.title, 'Fight Club');
      expect(vm.posterUrl, 'https://x/p.jpg');
      expect(vm.metaLine, '1999 · Film');
    });

    test('null year is omitted from the meta line', () {
      const s = MediaSummary(tmdbId: 1, mediaType: 'tv', title: 'Shōgun');
      final vm = MediaCardVm.fromSummary(s);
      expect(vm.metaLine, 'Serie');
    });

    test('empty poster becomes null so the media fallback kicks in', () {
      const s =
          MediaSummary(tmdbId: 2, mediaType: 'movie', title: 'X', posterUrl: '');
      final vm = MediaCardVm.fromSummary(s);
      expect(vm.posterUrl, isNull);
    });

    test('blank title falls back to a placeholder string', () {
      const s = MediaSummary(tmdbId: 3, mediaType: 'movie', title: '   ');
      final vm = MediaCardVm.fromSummary(s);
      expect(vm.title, 'Senza titolo');
    });

    test('unknown media type contributes nothing to the meta line', () {
      const s = MediaSummary(tmdbId: 4, mediaType: 'other', title: 'Y', year: 2020);
      final vm = MediaCardVm.fromSummary(s);
      expect(vm.metaLine, '2020');
    });
  });

  group('MediaCardVm.buildMetaLine', () {
    test('joins non-empty parts with a middot and drops blanks', () {
      expect(MediaCardVm.buildMetaLine(['2024', '', 'Film', '   ']),
          '2024 · Film');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/view_models/media_card_vm_test.dart`
Expected: FAIL — URI for `media_card_vm.dart` doesn't exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/presentation/view_models/media_card_vm.dart`:

```dart
// lib/presentation/view_models/media_card_vm.dart
//
// Null-safe presentation model for a poster/backdrop card. Widgets never see
// a raw nullable field: missing poster -> null (media shows initials), blank
// title -> placeholder, missing year -> simply absent from the meta line.
// This is the robustness rule "widgets never render raw nulls" in code.
import '../../domain/models/media_summary.dart';

class MediaCardVm {
  const MediaCardVm({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    required this.posterUrl,
    required this.metaLine,
  });

  final int tmdbId;
  final String mediaType;
  final String title;

  /// Null when the source had no usable poster — AspectRatioMedia then
  /// renders its initials fallback instead of a broken image.
  final String? posterUrl;

  /// Pre-formatted "1999 · Film" style line, already stripped of empties.
  final String metaLine;

  factory MediaCardVm.fromSummary(MediaSummary s) {
    final trimmedTitle = s.title.trim();
    final poster = s.posterUrl;
    return MediaCardVm(
      tmdbId: s.tmdbId,
      mediaType: s.mediaType,
      title: trimmedTitle.isEmpty ? 'Senza titolo' : trimmedTitle,
      posterUrl: (poster == null || poster.isEmpty) ? null : poster,
      metaLine: buildMetaLine([
        if (s.year != null) s.year.toString(),
        mediaTypeLabel(s.mediaType),
      ]),
    );
  }

  static String mediaTypeLabel(String type) {
    switch (type) {
      case 'movie':
        return 'Film';
      case 'tv':
        return 'Serie';
      case 'anime':
        return 'Anime';
      default:
        return '';
    }
  }

  static String buildMetaLine(List<String> parts) =>
      parts.where((p) => p.trim().isNotEmpty).join(' · ');
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/view_models/media_card_vm_test.dart`
Expected: PASS (6 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/view_models/media_card_vm.dart test/view_models/media_card_vm_test.dart
git commit -m "feat(view-models): add null-safe MediaCardVm"
```

---

### Task 7: Foundation gate — full suite + analyzer green

**Files:** none (verification task)

- [ ] **Step 1: Run the whole test suite**

Run: `flutter test`
Expected: PASS — all existing tests plus the 6 new test files (24 new tests) green. If a pre-existing test fails, it is unrelated to this additive plan; note it but do not fix it here.

- [ ] **Step 2: Run the analyzer**

Run: `flutter analyze`
Expected: No new issues in `lib/presentation/theme/tokens.dart`, `lib/presentation/widgets/primitives/`, `lib/presentation/view_models/`.

- [ ] **Step 3: Commit (only if analyze surfaced an auto-fixable lint you corrected)**

```bash
git add -A
git commit -m "chore(primitives): satisfy analyzer for foundation layer"
```

If nothing changed, skip this commit.

---

## Self-Review

**1. Spec coverage (Sections 3 & 4):**
- §3.1 Color → Task 1 (`StreamloadTokens` colors incl. cream CTA + amber accent). ✓
- §3.2 Typography → deferred: the theme already wires Fraunces/Inter/JetBrains via `StreamloadTypography`; foundation does not duplicate it. The theme `streamloadTheme()` rewire to `StreamloadTokens` happens in the shell plan when the app swaps in the new theme. Noted, not a gap for this plan.
- §3.3 Spacing/radii/breakpoints → Task 1. ✓
- §3.4 Motion (physical spring) → Task 1 (`springCurve`, `spring`, durations). ✓
- §4.1 AsyncStateView → Task 4. ✓
- §4.2 null-safe view-model → Task 6 (`MediaCardVm`). ✓
- §4.3 anti-overflow primitives → Task 3 (`AspectRatioMedia`) + Task 5 (`ResponsiveGrid`). ✓
- §4.4 no empty rows → enforced at the row primitive level in the Home plan (rows hide when empty); the per-surface empty handling lives in `AsyncStateView`. Noted: the row-hiding rule is implemented in the shell/Home plan, not here.
- §4.5 aligned grids → Task 5. ✓
- §4.6 images skeleton/fallback → Task 2 + Task 3. ✓
- §4.7 stable shell → shell plan (out of scope here).

No gaps for a *foundation* plan; row-hiding and theme rewire are explicitly assigned to the next plan.

**2. Placeholder scan:** No TBD/TODO; every code step contains complete, compilable code. ✓

**3. Type consistency:** `StreamloadTokens` member names (`bg`, `surfaceHi`, `textMuted`, `accent`, `ctaPrimaryBg`, `radiusCard`, `space2/3/4/6`, `bpPhone`, `bpDesktop`, `springCurve`, `spring`) are referenced identically across Tasks 2–5. `MediaCardVm.fromSummary`/`buildMetaLine`/`mediaTypeLabel` names match between impl and tests. `AsyncStateView` constructor params (`value`, `loading`, `onRetry`, `data`, `isEmpty`, `empty`) match between impl and tests. `MediaSummary` field names (`tmdbId`, `mediaType`, `title`, `year`, `posterUrl`) verified against the real model. ✓

---

## Next plans (not in this plan)

1. **Shell & navigation** — rewire `streamloadTheme()` onto `StreamloadTokens`, hardened TopNavBar/BottomTabBar, scroll preservation, physical page transitions, the `ContentRow` row primitive (hides when empty).
2. **Home & categories** (Direction A).
3. **Title detail** (v2 layout, no sources).
4. **Player** (forced landscape on mobile, no quality control).
5. Search · La mia lista · Person · Settings/Profile · Onboarding.
6. **Cleanup** — remove deprecated v2/v3 token aliases once all screens are migrated.
