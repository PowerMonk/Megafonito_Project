# Megafonito UI modernization plan

## Decision and objective

Refresh the existing Flutter UI into a consistent, polished, accessible Material 3 experience while retaining current functionality and screen structure. **The code's existing UI is the behavior baseline.** The historical UX PDFs do not change the five coded destinations or the separate Support route.

Visual work must not claim or imply backend integration. Keep the mock login and example data visibly identified as development/example behavior. Backend authentication, privacy, and persistence work remains separate.

## Design direction

### Brand character

Use a calm, contemporary school/work communications identity: confident deep navy, warm amber/orange accents, near-white cool neutral surfaces, readable dark text, restrained borders and shadows, and clear typographic hierarchy. Keep the brand assets and Spanish product copy already present.

### Foundation

- Make Material 3 intentional with `ThemeData.from(..., useMaterial3: true)` and one app-level `ColorScheme` created from a deep-navy seed with the existing amber as a controlled secondary/accent color.
- Use `colorScheme`, `textTheme`, and component themes for AppBar, NavigationBar/Rail, cards, input decoration, chips, buttons, dialogs/sheets, snackbars, and FABs.
- Define a small spacing/radius/elevation scale in the frontend theme/design helper; avoid another UI dependency.
- Prefer framework Material components over hand-built lookalikes when their semantics/interaction fit. Keep custom SVG icons where they are part of the current brand, and ensure selected/unselected contrast is explicit.
- Use surface hierarchy (page background, cards, modal surfaces) and subtle outlines rather than applying heavy shadows to every card.

### Responsive layout

- Phone/compact width: preserve the current five-destination bottom navigation.
- Medium/wide window (600 logical pixels and above): use a Material 3 NavigationRail while retaining the same destination order, labels, index state, and pages.
- Constrain content width on wide layouts; keep feed/forms readable rather than stretching line lengths indefinitely.
- Use flexible/wrapping rows for titles, author labels, metadata, and action groups; avoid fixed widths/heights where they cause clipping.
- Respect safe areas, keyboard view insets, scrollability, landscape, and increased text scaling.

## Behavior contract

Preserve:

1. Splash -> development login -> shell navigation.
2. Current destinations: Inicio, Contactos, Oportunidades, Procesos, Cuenta.
3. Support opened from the app bar.
4. Feed category selection, refresh, pagination, notice-detail modal, create-notice entry, and admin action-menu affordances.
5. Current Contacts copy/search, Opportunities category/detail, Account clipboard/sign-out navigation, and current composer validation/picker entry points.
6. Existing mock/local/backend boundaries and current form callbacks.

Do not represent placeholders as complete workflows. Fixing the title/link data binding, nonpersistent mock storage, auth/privacy, or backend behavior is a separate functional task. UI-level resilience bugs directly blocking presentation (for example, duplicate FAB Hero tags or text clipping) can be corrected while preserving the action callback/navigation.

## Implementation sequence

### Phase 1 — Shared visual foundation

1. Add one Material 3 app theme using built-in Flutter APIs compatible with the updated Flutter 3.44+ baseline.
2. Establish readable color/text/spacing/shape tokens and shared component defaults.
3. Refresh the shell's AppBar, compact NavigationBar, wide NavigationRail, scaffold surfaces, and selected states.

### Phase 2 — High-use announcement path

1. Restyle filter chips and sort popup consistently.
2. Redesign NoticeCard with robust author/date/category/attachment layout and sensible text bounds.
3. Harmonize notice detail sheet and attachment affordance.
4. Improve feed loading, empty, error, refresh, and pagination presentation.
5. Refresh the admin action menu with unique Hero identities, clear labels, and accessible tap targets.
6. Polish notice composer hierarchy, field focus/errors, dropdowns, attachment row, and app-bar actions while keeping submitted values and callbacks unchanged.

### Phase 3 — Remaining current screens

Apply the same theme and hierarchy to Contacts/search/copy rows, Opportunities/category/detail pages, Processes/FAQ, Account/schedule placeholder, Support choices, message/opportunity composers, Login/Register, and Splash. Keep every current destination and action in place. Explicitly label development/demo authentication and sample data.

### Phase 4 — Quality verification

- Run `dart format` on changed Dart files.
- Run `flutter analyze --no-pub`; resolve errors and all newly introduced warnings. Record pre-existing diagnostics separately instead of masking them.
- Run project widget tests covering Material 3 activation, navigation selection at compact/wide constraints, no overflow on representative narrow/wide screens, notices and card metadata, text semantics/tooltips, and core tap flows.
- Run `flutter test --no-pub` and `flutter build apk --release --no-pub` using the checked-in lock resolution where supported.
- Manually inspect device/emulator at approximately 360x800 and tablet/landscape widths; test large text, keyboard-open forms, touch targets, selected/focus/disabled contrast, support route, and overlay dismissal.
- Capture before/after screenshots if a runnable emulator/device is available. Do not claim screenshot validation when no device is connected.

## Accessibility acceptance criteria

- Text color/background combinations remain legible in all states; semantic meaning is not conveyed by color alone.
- Icon-only buttons have tooltips/semantic labels; visible action labels are understandable to screen readers.
- Interactive targets are at least 48x48 logical pixels unless a clearly justified Material control already supplies the minimum.
- Text scales without clipped labels, inaccessible buttons, or destructive horizontal overflow.
- Focus, selected, disabled, loading, and error states remain distinguishable; forms remain scrollable when the keyboard appears.
- Navigation order/selected destination is announced and unchanged across compact/wide layouts.

## Out of scope for this visual pass

- Frontend/backend integration, authentication redesign, schema changes, migrations, audience privacy/authorization fixes, or S3 setup.
- Changing product navigation, current page set, or user journeys to match UX PDFs.
- Replacing current state management/services or broad folder refactoring.
- Dependency upgrades solely for newer visual widgets. Use Flutter Material 3 built-ins and the existing dependency lock.

## Completion record

**Implemented.** The current Flutter screens and flows now use the shared Material 3 theme, adaptive floating five-destination navigation, refreshed rounded surfaces and toolbar controls, and clearer development-mode login. The announcement action menu has local state and no longer rebuilds the feed when toggled. The original screen organization and mock/service boundaries remain in place. No new UI package was added.

Verification on local Flutter 3.47.7 / Dart 3.13.5:

| Check | Result |
| --- | --- |
| `dart format` on changed Dart files | Passed. |
| `flutter analyze --no-pub` | Passed: no issues found. |
| `flutter pub get --enforce-lockfile --offline` | Passed with the file_picker 13.3.0 update and unused Cronet adapter removal. |
| `flutter test --no-pub` | Passed: 9 UI/widget tests. SVG parser emitted non-fatal warnings for embedded font/style/metadata tags. |
| `flutter build apk --debug --no-pub` | Passed with Gradle 9.3.1, AGP 9.1.0, and built-in Kotlin. |
| `flutter build apk --release --no-pub` | Passed with the same Android toolchain; the previous version-support warnings are gone. |
| Device screenshots / manual Android review | Not run; no Android device or emulator was connected. |

The local host exposed Windows desktop and Chrome/Edge, not an Android emulator. Android toolchain compatibility and the SVG test warnings are recorded in [Build and tests](../as-built/build-and-tests.md) and [Known gaps](../as-built/known-gaps.md). Production authentication, server integration, privacy, and persistence remain separate work.
