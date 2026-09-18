# UI Fixes Plan — four small, isolated corrections

Four small, independent fixes raised by `issues.md`, each confirmed against real code rather than assumed. None of them touch navigation structure — that larger, separate body of work is tracked in `app_navigation_plan.md`'s "Desktop/web navigation revisit" section. Written before implementation, same as that document.

## Context

`issues.md` (with `image.png` as supporting evidence) raised eight observations. Four are small, well-isolated bugs or UX gaps that don't need a design-document detour — each reuses an existing token, an existing widget capability, or an existing navigation call already present elsewhere in the codebase. They're grouped here because they're all "fix the thing, it's already specified/supported, just not applied here" — not because they share any code path.

## Study Review: a divider between findings and chat

`study_review_template.dart`'s `_buildThreeZone` (lines 79-122) — the `expanded`/`ultrawide` layout — places its `Expanded(flex: 5, ...)` primary-content column (image viewer + `FindingsPanel`) and its `SizedBox(width: AppLayout.panelMaxWidth, child: chatPanel)` as plain `Row` siblings (lines 100-119) with nothing between them: no `AppDivider`, no `Border`, no border token of any kind. The visible border around "Findings" in `image.png` comes entirely from `FindingsPanel`'s own self-contained card decoration (`findings_panel.dart:92-98`, `Border.all(color: colors.border)` + `AppElevation.card`) — unrelated to the seam between the two columns, which is genuinely empty.

**Fix**: insert `AppDivider(axis: Axis.vertical)` between the two `Row` children. `AppDivider` (`lib/ui/atoms/app_divider.dart`) already supports `axis: Axis.vertical` and already defaults its color to `context.colors.borderSubdued` — no new parameter, no new token. This is the correct token per `design_language.md` D-016: `border` (the stronger token, `FindingsPanel`'s own card uses it) is reserved for boundaries a user relies on seeing — an input outline, a button edge — while `borderSubdued` is "the decorative role," which is exactly what a seam between two already-distinguishable panels is. Precedent for this exact move already exists in the codebase: `settings_template.dart:98-102` separates its own two columns with a `borderSubdued` `VerticalDivider`.

## Settings drawer: fix the Settings button's colors

`nav_item.dart:33-35` always resolves its own color from `NavigationTokens.bottomNavSelected`/`bottomNavUnselected`, i.e. `context.colors.iconAccent`/`context.colors.textMuted` — tuned for `AppNavBar`'s background, `context.colors.surface` (a light, page-toned surface in both app themes). `conversation_drawer.dart:50-60` reuses that same `NavItem` for its bottom-of-drawer "Settings" entry, but the drawer's background is `NavigationTokens.drawerBackground` → `context.colors.surfaceBrandSecondary`, a brand-navy surface — and every *other* element in that same drawer (header username at line 78, empty-state text at line 96, conversation-tile icon/title at lines 141-143/155) correctly uses the on-brand pair, `textOnBrand`/`iconOnBrand`, instead. The Settings entry is the one outlier in its own widget family.

This is not a "dark mode isn't wired" bug — `textMuted` does resolve to a different literal color per mode (light `gray550` `#6E6E6E`; dark `darkTextMuted` `#8B95A1`). It's the wrong *token family* for the surface it sits on. Computed contrast against the drawer's actual background (`surfaceBrandSecondary` `#1A3D64` light / `darkSurfaceBrandSecondary` `#1B3049` dark — nearly identical navy in both modes, which is why the bug reads as "doesn't change with light/dark"): **~2.2:1 in light mode** (fails the 3:1 floor for a UI component/icon) and **~4.4:1 in dark mode** (passable, but still the wrong pairing on principle, and the closeness of the two navy values is what makes the whole row look theme-inert either way).

**Fix**: give `NavItem` two new optional constructor parameters, `selectedColor`/`unselectedColor` (`Color?`), defaulting to `null` — when absent, `NavItem` computes color exactly as it does today (`NavigationTokens.bottomNavSelected`/`bottomNavUnselected`), so `AppNavBar`'s existing call sites (and any other current caller) are byte-for-byte unaffected. Update `conversation_drawer.dart:55-59`'s Settings `NavItem` call to pass `unselectedColor: context.colors.iconOnBrand` (matching the rest of the drawer; this entry is never shown in a "selected" state today, so `selectedColor` doesn't strictly need a value here, but accept it for symmetry).

## Upload: navigate automatically on success

`upload_page.dart`'s `_upload()` (lines 53-83) only calls `setState` on success (lines 70-75, storing `_uploadedCase`); the actual navigation lives entirely in `_viewStudy()` (lines 85-93, a `Navigator.of(context).pushReplacement` to `StudyReviewPage`), which is wired *only* to the "View Study" button's `onAction` inside the success `StatusBar` (lines 114-120). A radiologist has to notice the banner and tap the button before landing on the study — exactly the manual step `issues.md:5` objects to.

**Fix**: call the same navigation `_upload()` already builds toward, directly from the success branch, as soon as `uploadStudy()` resolves — instead of waiting for a button tap. The error branch (`StatusBar` + "Retry" → re-running `_upload()`) is unaffected; that manual step is real and still needed, since the user has to decide whether to retry or pick a different file. This likely means `_viewStudy()`'s body becomes the thing `_upload()` calls directly on success, and the success `StatusBar`/"View Study" button state can go away entirely — there's nothing left for it to do once navigation happens immediately.

**Test impact, called out so it isn't missed**: `upload_page_test.dart:54-75` (`'uploading succeeds: shows View Study, tapping it opens Study Review'`) currently asserts the old manual-tap contract — it expects to find "View Study" text and taps it before expecting `StudyReviewPage`. That test needs rewriting to assert immediate navigation instead (no button, no intermediate banner to find).

## Settings: continuous scroll instead of master-detail

`issues.md:12` assumed Settings was split into three routed pages. It isn't — `settings_page.dart` is a single `ConsumerStatefulWidget` instantiating one `SettingsTemplate` (confirmed by the existing test `'only one SettingsTemplate is instantiated'` in `test/ui/pages/settings_page_test.dart`), and `settings_template.dart`'s `_buildTwoColumn` (lines 79-119, the `expanded`/`ultrawide` layout) already matches `design_tokens.md` §9.5's spec exactly: a 200px left index rail next to the content pane. The real gap is narrower: `_buildTwoColumn` is a **master-detail** layout — tapping a `SectionIndexTile` (lines 89-95) calls `onSectionSelected!(i)`, which flips `SettingsPage._selectedIndex` (`settings_page.dart:25,51-52`), and the content pane renders *only* `sections[index]` (lines 109-116, `SectionCard(title: sections[index].title, child: sections[index].child)`) — Account, Appearance, and About are never visible together. That's what reads as "different pages" even though the route never changes.

**Fix**: rework `_buildTwoColumn`'s content pane from "render `sections[index]`" to a single continuous scroll rendering every section's `SectionCard` in order (the same `ListView.separated` shape `_buildSingleColumn`, lines 57-77, already uses at narrower tiers) — repurpose the left rail from an exclusive switcher to a scroll-spy/jump-to-anchor index: tapping a `SectionIndexTile` scrolls the content pane to that section (a `GlobalKey` per `SectionCard` and `Scrollable.ensureVisible`, or an equivalent scroll-offset calculation) instead of hiding the other two. `selectedIndex` becomes "which section is currently in view" rather than "which section is exclusively shown" — still worth highlighting in the rail so the index reads as a table of contents, not a dead control.

## Docs to update alongside the code

- **`atomic_design.md:123`** — its one-line `SettingsTemplate` catalog entry ("Single-column layout for settings sections") is already stale relative to `_buildTwoColumn`'s existing master-detail behavior, and will need a further update once this becomes continuous-scroll-with-scroll-spy.
- No `design_tokens.md`/`design_tokens.dart` changes — every fix above reuses an existing token (`borderSubdued`, `iconOnBrand`) or an existing widget capability (`AppDivider`'s vertical axis, `NavItem`'s now-overridable color).

## Verification

- `flutter analyze` — clean, on every file touched.
- `flutter test` — full suite green. Existing tests likely needing updates: `upload_page_test.dart` (rewritten per the note above), the existing `NavItem` and `ConversationDrawer` widget tests (new cases for the color-override parameters and the on-brand call site), the existing `StudyReviewTemplate` widget test (new case asserting the divider renders at the `expanded`/`ultrawide` tier), and the existing `SettingsTemplate`/`SettingsPage` widget tests (new cases asserting all three sections render simultaneously at `expanded`/`ultrawide`, and that tapping a rail item scrolls rather than swaps content).
- Manual pass per `AGENTS.md`'s post-task checklist once implemented: exercise each fix in both light and dark mode, at the tier(s) it applies to, on a real run of the app.

## Status

Implemented:

1. Study Review findings↔chat divider — `AppDivider(axis: Axis.vertical)` inserted in `study_review_template.dart`'s `_buildThreeZone`.
2. Settings-drawer Settings-button coloring — `NavItem` gained optional `selectedColor`/`unselectedColor` overrides; `ConversationDrawer`'s Settings entry now passes `unselectedColor: context.colors.iconOnBrand`.
3. Upload auto-navigation — `_upload()` navigates to `StudyReviewPage` directly on success; the manual "View Study" button/banner and `_uploadedCase` state are gone.
4. Settings continuous scroll — `_buildTwoColumn` now renders every section via one scroll (`GlobalObjectKey`-keyed `SectionCard`s); the rail highlights and scrolls to a section (`Scrollable.ensureVisible`) instead of hiding the other two.

`flutter analyze lib/ test/` and the full `flutter test` suite (695 tests) both pass. `atomic_design.md`'s `SettingsTemplate` catalog row was updated to match.
