# UI Refactor — Theme Rewire to StreamloadTokens

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans. Steps use `- [ ]` checkboxes.

**Goal:** Make the global `streamloadTheme()` read its colors from `StreamloadTokens`, so the design-system tokens are the single source of truth for app-wide chrome (spec §3 "token unici").

**Architecture:** Modify only `lib/presentation/theme/theme.dart` colors (scaffold/canvas/colorScheme/input/snackbar) to point at `StreamloadTokens`. Leave `textTheme` and `filledButtonTheme` untouched (avoids onboarding/form button regressions and google_fonts test churn). Legacy `StreamloadColors` stays for un-migrated widgets.

**Tech Stack:** Flutter, flutter_test. Only `theme_test.dart` asserts theme values; the other 4 tests that pump `streamloadTheme()` don't assert colors (verified).

---

### Task 1: Point streamloadTheme() colors at StreamloadTokens

**Files:**
- Modify: `lib/presentation/theme/theme.dart`
- Test: `test/theme_test.dart`

- [ ] **Step 1: Update the test to assert token-sourced values (failing)**

In `test/theme_test.dart`, change the color assertions in the first test to:

```dart
      expect(theme.scaffoldBackgroundColor, StreamloadTokens.bg);
      expect(theme.colorScheme.surface, StreamloadTokens.surface);
      expect(theme.colorScheme.primary, StreamloadTokens.accent);
      expect(theme.colorScheme.error, StreamloadTokens.critical);
```

Add the import:

```dart
import 'package:streamload_client/presentation/theme/tokens.dart';
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/theme_test.dart`
Expected: FAIL — scaffoldBackgroundColor is still `StreamloadColors.bg` (#08090A), not `StreamloadTokens.bg` (#0F0E0D).

- [ ] **Step 3: Rewire theme.dart colors to tokens**

In `lib/presentation/theme/theme.dart`, add `import 'tokens.dart';` and change the colorScheme + scaffold/canvas + input/snackbar colors to `StreamloadTokens` equivalents (see full file in Step 3 implementation below). Keep `textTheme: StreamloadTypography.textTheme()` and the entire `filledButtonTheme` block unchanged.

Replace the `colorScheme`, `scaffoldBackgroundColor`, `canvasColor`, `inputDecorationTheme` fill/focus, and `snackBarTheme` color references:
- `scaffoldBackgroundColor`/`canvasColor` → `StreamloadTokens.bg`
- `surface` → `StreamloadTokens.surface`
- `onSurface` → `StreamloadTokens.textPrimary`
- `primary` → `StreamloadTokens.accent`, `onPrimary` → `StreamloadTokens.ctaPrimaryFg`
- `secondary` → `StreamloadTokens.accentHover`, `onSecondary` → `StreamloadTokens.ctaPrimaryFg`
- `error` → `StreamloadTokens.critical`
- `surfaceContainerHighest` → `StreamloadTokens.surfaceHi`
- `outline` → `StreamloadTokens.borderStrong`, `outlineVariant` → `StreamloadTokens.border`
- input `fillColor` → `StreamloadTokens.surface`, `hoverColor` → `StreamloadTokens.surfaceHi`, focus border → `StreamloadTokens.accent`, other borders → `StreamloadTokens.border`, error border → `StreamloadTokens.critical`
- snackbar bg → `StreamloadTokens.surface`, text → `StreamloadTokens.textPrimary`

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/theme_test.dart`
Expected: PASS.

- [ ] **Step 5: Full suite + analyzer**

Run: `flutter test`
Expected: all green (the 4 other `streamloadTheme()` consumers don't assert colors).

Run: `flutter analyze lib/presentation/theme/theme.dart`
Expected: No issues.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/theme/theme.dart test/theme_test.dart
git commit -m "feat(theme): source streamloadTheme() colors from StreamloadTokens"
```

---

## Self-Review
- Spec §3 token unification into ThemeData → Task 1. ✓
- No placeholders; exact token mappings listed. ✓
- Only `theme_test.dart` asserts theme colors (verified via grep); other consumers just pump the theme. ✓
- `filledButtonTheme` + `textTheme` deliberately untouched to avoid onboarding/form regressions. Noted.
