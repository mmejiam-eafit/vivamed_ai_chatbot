# Design Conformance Register

Does the implemented app satisfy [`design_language.md`](design_language.md) (DL) and [`design_tokens.md`](design_tokens.md) (DT)?

**Verdict: no, and the gap is large but structured.** Of ~25 normative rules audited, 8 conform, 16 are violated, and 8 are specified with no implementation at all. (Twenty-six more have since closed outright — 4, 10, 24 from the tokens/atoms reconciliation, 1, 2, 3, 7, 12, 15, 21 from Step 3, 5 and 6 taken early out of step order, 8 closed as a standalone fix, 9 and 26 from Step 4, 29 from a sixth pass, 13, 16, 22 from a seventh, 11, 25, 30 from a ninth, 14, 17 from a tenth, 32 from an eleventh, and 18, 20 from a twelfth — folded into Conforming below; several others have real, verified partial progress. Six rows have been **added** since the original audit, each found while implementing rather than while auditing: 27 is still deferred to Step 5; 28, 29, 31, and 32 closed the same pass they were found; 30 closed three passes after it was logged, once the user chose to derive the color it needed rather than defer it further — so the numbering now runs to 32 even though fewer rows are open than at the start. See the reconciliation notes above and each updated row.)

The gap splits along one clean line. **Mechanical rules — the greppable ones — are at 100% in production code:** zero hex literals, zero `_Palette` references, zero `Theme.of(context)`, zero inline radii or durations. **Semantic rules — everything the design language newly articulated — are largely unimplemented:** the mono voice, tabular figures, severity redundancy, the truncation policy, the perceptual hierarchy, responsive tiers, focus, density, and dark mode.

That shape is expected rather than alarming. The design documents were written *after* the app and describe an intent it was never built to satisfy. The old rules were enforceable by grep and were enforced; the new rules describe judgment and nothing yet expresses them.

## How to read this

Rows are grouped by **clinical risk** — could a radiologist be misled, or miss something. **Effort** is S (hours), M (about a day), L (multi-day or architectural). Each row cites the rule it breaks and the code that breaks it.

This register supersedes the known-gaps table at `design_tokens.md` §12; the "§12" column records which entries it absorbs. When a gap closes, delete the row here and the matching §12 entry together.

Audited at commit `906e91f`. A reconciliation pass since then (uncommitted at audit time, atoms + tokens + `app.dart` only — no organism, molecule, or template touched) closed three rows outright (4, 10, 24) and made partial, atom-only progress on several others (8, 14, 16, 20, 23) — updated in place below rather than re-auditing from scratch. Two things the reconciliation *claimed* in its own step plan below turned out not to have happened when checked directly: gap 11 (no `textTheme`, still Roboto) and gap 19's `DiagnosticImageTokens` (doesn't exist) — corrected in place, not silently left to look done.

A third pass took gaps **5** and **6** out of order, both high clinical risk, also uncommitted. Two things it found that the rows themselves did not say. Gap 6's ground value was **already specified** — DT §10.4 has carried `#0A0C0E` all along with no token to live in — so it needed implementing, not deciding, and `design_language.md` needed no change at all (D-004 and DL §3.7 already carry the reasoning). And gap 6 was **latent, not live**: `heatmap_viewer_template.dart` reads the deprecated static, so its canvas was frozen light-navy and never actually brightened; the brightening would have begun the moment gap 18 migrated the file. Fixing it now is preventive. The same DL §3.7 clause turned out to be broken a second time in a file gap 6 never cited — `study_review_template.dart` grounded its image slot in off-white `surfacePage` — and that was fixed in the same pass.

A fourth pass closed gap 8, also uncommitted. The row had never actually been assigned to a step — Step 2 closed its atom half ("focus rings on every interactive atom"), but the molecule half ("`nav_item.dart`, chips") wasn't in Step 3's closing list either, so it sat open with no step ever claiming it. Closing it surfaced that `_FocusRing` was already duplicated verbatim between `app_button.dart` and `app_text_field.dart` — two real call sites, which is exactly the threshold this document's own new simplicity rule sets for extracting a shared implementation — so it became a public `FocusRing` in `lib/ui/core/`, and both atoms were rewired to it rather than gaining a third and fourth copy. `AppChip` turned out to have no focus ring at all — checked directly — despite Step 2's own row claiming focus rings on "every interactive atom." A second thing that step didn't actually finish. Two more interactive molecules the row's "and other interactive molecules" phrase covers but didn't name — `finding_row.dart` and `image_thumbnail.dart` — got the same fix in the same pass, since leaving them would mean the gap wasn't actually closed, just narrowed again without saying so.

A second pass executed Step 3 (Molecules), uncommitted at time of writing. Closes rows 1, 2, 3, 7, 12, 15, 21 outright and narrows row 18 (`finding_row`, `metadata_field`, `severity_chip` now read `context.colors`/`context.severity`; `status_banner` still doesn't — 15 files remain, not 18). One correction to this document's own Step 3 table: it listed a `ConversationDrawer` fix (gap 20b) as molecule-layer work, but `conversation_drawer.dart` lives in `lib/ui/organisms/` — checked directly. That item was not executed as part of this pass; moved to Step 4's table, where it actually belongs. `flutter analyze` clean, `flutter test` at 383 passing (was 362).

A seventh pass did Step 16 — real tiers and pane fit on all seven templates, taken in the order the user asked: tiers first, per-page new UI (gap 17) deliberately later. A shared `AppLayoutTier` enum and a `layoutTier` extension on `double`, both new in `design_tokens.dart`, replace what would otherwise be the same four boundary checks reimplemented seven times. Three templates already had a single `LayoutBuilder` boolean at the old `templateSplitWidth` (768) — `chat_template.dart` and `study_review_template.dart` now gate their multi-pane layouts at `threePaneMinWidth` (1120) instead, closing gap 13 outright: the 168px chat column this register opened with is no longer reachable, because nav+chat+findings only ever render together once all three actually fit. `study_review_template.dart` also gained a real middle tier — viewer beside tabs, between its narrow stacked layout and its three-zone wide one — and its wide layout goes side by side, not stacked, past `ultrawideMinWidth`. `case_list_template.dart`'s list-to-grid switch moved from 768 to `mediumMinWidth` (600), matching DT §9.5 exactly; the grid itself stays the interim until gap 17 builds the real table.

The other four templates had no branching at all. `auth_template.dart` gained a compact tier (full-bleed, no card, no shadow) and, from medium up, a card capped at `formMaxWidth` (400) instead of `panelMaxWidth` (360) with the shadow dropped entirely — gap 22, closed the same pass, including the pinned test that asserted the shadow as correct. `onboarding_template.dart` caps its content at 560 from medium up; its own expanded/ultrawide spec — image left, copy right — needs `OnboardingCarousel` to accept a layout mode it doesn't have, so that half stays open for gap 17 rather than getting a half-built version of it here. `heatmap_viewer_template.dart` moves its opacity control from a bottom bar (compact, and medium at an explicit 56px) to a persistent 280px right rail at expanded and up — pure rearrangement of its three existing slots, no new widget needed. `settings_template.dart` needed the most: `sections` changed from opaque widgets to `SettingsSection` (title + child), letting the template own the section-card chrome itself and, at expanded and up, build a real 200px title index beside a 720px-capped content pane. Selection stays where every other selected-index molecule in this app keeps it — the caller, via `selectedIndex` + `onSectionSelected` — so the template stays stateless like its six siblings; `SettingsPage` now holds that one bit of state. The actual Appearance section content is still gap 17's, not built here.

Confirmed, not assumed: rendering `study_review_template.dart`'s narrow layout at a short, wide test size reproduced the exact overflow `design_tokens.md` §12 gap 15 had logged as a credible-but-unproven lead — its `AspectRatio(4/3)` sat directly in a `Column`, demanding `width × 0.75` of height regardless of what the column actually had, because the old 768 threshold happened to route the default test viewport into the wide branch instead, so the narrow branch's own layout was never actually exercised by those tests. Capped at 45% of the available body height and re-verified; §12 gap 15 is deleted, along with gap 9 (organism coverage, closed two passes ago and never removed) and gap 10 (this pass's own subject), both missed when their matching register rows closed.

`flutter analyze` clean, `flutter test` at 481 passing (was 462).

An eighth pass found something no prior pass could have, because every previous one checked token *values*, never layer *boundaries*: `settings_template.dart`'s `_SectionIndexTile` and `_SectionCard` — private widget classes added in the seventh pass — composed `AppText` plus `Container`/`InkWell` plus selection state, matching this repo's own definition of a molecule (AGENTS.md: "2–4 atoms forming one conceptual unit... expose interactions through callbacks"), while reaching for `AppElevation.card`, `AppRadius.borderCard`, `AppTypography.headingSm`/`labelMd`, and `colors.surface`/`surfaceSubdued` directly inside a template file. AGENTS.md's token-class table restricts templates to `AppSpacing` and `AppColors.surfacePage` only. This chrome previously lived only in exempt preview code; moving it into a production template class during the seventh pass is what turned it into a real violation. Fixed by extracting both into real molecules — `lib/ui/molecules/section_card.dart` and `lib/ui/molecules/section_index_tile.dart` — with `settings_template.dart` composing them instead of defining them; the rendered tree is unchanged, so no existing test needed to change. `auth_template.dart`'s own card (`colors.surface` + `AppRadius.borderPanel` wrapping `formContent`, no atom composition inside it) was checked against the same rule and left alone on purpose — a bare decorated `Container` around an opaque slot isn't the same kind of problem as an inlined molecule, and extracting it would be accommodating a case that doesn't clearly exist yet. Assigned row 31, closed the same pass. `flutter analyze` clean, `flutter test` at 492 passing (was 481).

A ninth pass closed the three remaining **S**-effort gaps in one batch, at the user's request. Two turned out narrower than their own rows claimed, checked directly rather than taken on faith:

Gap 11's "21 such sites" holds, but only 16 are true bypasses (falling back to Flutter's own Typography) — the other 5 already reach `AppTypography` through their own widget (`AppButton`'s `ButtonStyle.textStyle`, or an explicit `style:` on `AppBadge`/`AppAvatar`/`AppChip`). Of those 16, 15 are `AppBar(title: Text(...))` sites; the 16th is a `@Preview`-only placeholder, already exempt under the same carve-out as every other preview site. Closed by one field — `buildAppTheme()`'s `appBarTheme` now sets `titleTextStyle: AppTypography.headingMd.copyWith(color: colors.textOnBrand)` — not the repo-wide `textTheme` the row's own wording implied; a full `textTheme` was considered and rejected, because Material 3's default type scale requests `FontWeight.w500` for several slots this app never actually uses, and only 400/600/700 have real font files (AGENTS.md) — scoping to the one field that's actually broken avoids manufacturing a faux-bold regression to fix a gap that, on inspection, was never that broad. The row's own location citation (`design_tokens.dart:863-868`) was also wrong — that range is `AppTypography.headingSm`'s constructor, not `buildAppTheme()` (`1441-1564`) — corrected in passing.

Gap 25 closed the same way gap 20b's `drawerWidth` half did: `chat_template.dart`'s narrow-layout bottom sheet threads the outer `LayoutBuilder`'s available height down into `_buildNarrow()` and caps the sheet at a fraction of it, replacing the literal `AppLayout.panelMaxWidth` (a width) used as a `maxHeight`. The fraction is a local, interim constant, not a new token — DT §9.5 already specifies this slot's real destination as a **draggable** sheet (gap 17), so it gets the same treatment as `study_review_template.dart`'s `_narrowImageHeightFraction` rather than a properly-specified global value for a state this pass isn't building.

Gap 30 split in two, and the row's own speculation about `TooltipTokens` turned out to be resolvable rather than a permanent shrug. `AppScrollbar`'s three colors alias existing `AppColorsData` fields exactly — `trackColor`→`surfaceSubdued`, `thumbHoverColor`→`border`, and `thumbColor`→`borderSubdued` (a deliberate re-pairing: the literal `gray300` it used to read had gone orphaned when gap 28 moved `border` off it, so this reuses the already-established `borderSubdued`/`border` resting/hover pair instead of keeping a stray one-off gray). Neither `AppScrollbar` nor `TooltipTokens` is ever consumed anywhere but inside `buildAppTheme()` itself, which has no `BuildContext` to call a `NavigationTokens`-style method with — it already resolves `colors` from the `brightness` parameter directly, so the fix is a plain reference swap, not a new accessor. `TooltipTokens.background` (`#061625`) had no such alias available in either mode — computed contrast against dark mode's own page (`surfacePage`, `#0E141B`) comes out to ≈1.01, confirming the row's suspicion that simply carrying the light value over would not work. Rather than leave it deferred, the user chose to derive the dark value now: reuses `surfaceOverlay`/`textPrimary`, the dark elevation ladder's own topmost step, already the most-elevated surface this app defines and a reasonable match for a tooltip's topmost z-order (≈1.31 contrast against the page). No new palette entry — `design_language.md` gains D-017 for the reasoning, `design_tokens.md` §10.4 gains the derived pair, and `buildAppTheme()`'s own doc comment (which cited this exact gap as unresolved) is removed now that it's false.

`flutter analyze` clean, `flutter test` at 500 passing (was 492).

A tenth pass closed gap 14 and all four of gap 17's sub-items, at the user's request — the largest single pass this register has recorded, five separate builds.

Gap 14 turned out half-closed already: `chat_input.dart`'s send/attach buttons are `AppButton(variant: iconOnly)`, which already carries the Step 2 atom fix (`IconButton(constraints: BoxConstraints(minWidth/minHeight: 44))`) — confirmed with a new test rather than assumed, since neither button had one before. `nav_item.dart` was the real site: a bare `InkWell` with no floor at all, now wrapped in the same `ConstrainedBox` pattern `AppButton`/`AppTextField` use, covering both `NavItemLayout` variants from one place.

Gap 17's table needed a design correction mid-build: Flutter's stock `DataTable` looked disqualified by D-010 (no fixed-height rows, no horizontal scroll) on first read, but checking the actual SDK source rather than the widget's reputation found `dataRowMaxHeight: double.infinity` and an explicit `FlexColumnWidth` per `DataColumn` make it fully compliant — reused rather than hand-built. Surfaced a real, pre-existing overflow in `SeverityChip` along the way (no `Flexible` on its label, so a narrow host had nowhere to put an overflow) and fixed it at the source, since it's a shared molecule. `CaseListTemplate` gained a real three-way tier branch (list / grid / table) replacing the old two-way split; `CaseListPage` now builds both the cards and the table from one canonical `CaseSummary` list so they can't drift.

Gap 17's Settings Appearance section is the architecturally significant piece: this app's first dependency beyond `flutter_svg` (`shared_preferences`) and its first piece of state above the page level (`ThemeController`, reached via a hand-rolled `ThemeControllerScope`) — kept to the minimum the requirement (DT §10.5: remembered across launches) actually needs, no state-management package, no repository. The placeholder "Display" section becomes "Appearance," backed by a new `ThemeModeSelector` molecule (Dark/Light/System, per D-013) — no choice-picker control existed anywhere in the app to reuse.

Gap 17's remaining two sub-items — the draggable sheet and the collapsed rail — both land in `chat_template.dart`. The rail gives it a genuine third tier (previously only a two-way narrow/wide split), a 64px `CollapsedNavRail` that finally gives `NavigationTokens.sideNavCollapsedWidth` a real consumer (dead since it was defined) and opens the existing `ConversationDrawer`/findings panel as `Scaffold` drawer/endDrawer overlays rather than building second, icon-only renderings of either. The draggable sheet needed a real design correction, caught only by writing the test and watching it fail: a `DraggableScrollableController` driven manually from a separate `GestureDetector` never actually attaches to anything, because `isAttached` requires a connected `ScrollPosition`, not just a controller reference (confirmed against the SDK source) — so the drag handle is instead wrapped in a `SingleChildScrollView` connected to the sheet's own provided `scrollController`, the idiomatic mechanism, with `findingsPanel` kept outside it (it already scrolls itself internally, and nesting two scroll mechanisms over the same gesture would have fought each other).

`flutter analyze` clean, `flutter test` at 550 passing (was 500).

An eleventh pass audited the codebase against AGENTS.md's simplicity rule specifically, not a DL/DT rule — the same category as gap 31, not the clinical-risk gaps — after the tenth pass's `DataTable` correction raised the concern that it might not have been an isolated incident. All 47 files under `lib/ui/` were read directly against the actual Flutter SDK source, not sampled or grepped.

Four confirmed. `AppNavBar`'s hand-built three-item bottom nav is now `NavigationBar`/`NavigationDestination`, whose `icon`/`selectedIcon` pair is exactly the filled/outline swap it already did by hand, with the same two `selectedIndex`/`onDestinationSelected` params carried straight through. `ConversationDrawer`'s bare `Container` is now wrapped in `Drawer` — Flutter's own purpose-built container for a `Scaffold.drawer` slot, which the app had never actually used there, and which gains the elevation and semantic drawer label the plain `Container` never carried. `ThemeModeSelector` (ninth pass) and `SectionIndexTile` (eighth pass) both used a hand-rolled `InkWell` + conditional-fill row where `ListTile`'s own `selected`/`selectedTileColor` already do the same job — `ThemeModeSelector`'s own doc comment at the time cited "no radio/segmented-control atom exists... to reuse," the same category of mistake the `DataTable` situation was: checking this app's own catalog rather than Flutter's SDK. All four are behavior-preserving rewrites — same visual, same callbacks — confirmed by the existing test suite passing with only finders updated, not new assertions.

Three more were checked and deliberately left alone, recorded here so a future pass doesn't re-litigate them. `SectionCard`/`StudyInfoCard`/`FindingsPanel`'s card-shaped containers are not `Card`: `Card` has no `boxShadow` passthrough, only a numeric `elevation` driving Material's own shadow curve, and DL §6 requires elevation to split into a lightness-step-plus-hairline-border under dark mode — a rendering rule `Card.elevation` cannot express, so the hand-built `Container` is the only tool that can hold `AppElevation.card`'s exact recipe. `StatusBanner`/`StatusBar` are not `MaterialBanner`: its `actions` parameter is required and must be non-empty, while three of this app's four documented banner uses carry no action at all. `CollapsedNavRail` is not `NavigationRail`: every `NavigationRailDestination` requires a `label` and the whole widget is built around a persistent `selectedIndex`, but the rail's two icons are independent overlay triggers with no "current destination" concept. `AppBadge`'s one call site (`ImageThumbnail`'s corner overlay) was checked against `Badge` too and left as is — the win was about six lines and would have stranded `AppBadge` as unused or forced a double-decoration.

Assigned row 32, closed the same pass. `flutter analyze` clean, `flutter test` at 550 passing (unchanged — this pass rewrote finders, not behavior).

A twelfth pass started from a question, not a gap: whether `AGENTS.md` itself still reflects the project's current state, since every future pass is told to follow it exactly. It did not. `AGENTS.md` prescribed the deprecated `AppColors`/`SeverityTokens` statics as the *correct* pattern in four places and never mentioned `context.colors`/`context.severity` anywhere, unchanged since before the `ThemeExtension` mechanism landed — corrected before anything else, since working gap 18 from a rulebook that contradicts the fix would have been fighting itself.

Gap 18 closed outright, and checking it directly first (rather than trusting this row's own count, already twice caught stale this session) found the real remaining scope was smaller and different: `settings_template.dart` and `heatmap_viewer_template.dart` were already fully compliant, never removed from the row's count. The actual fix touched `study_info_card.dart` (mirrors `FindingsPanel`'s existing pattern) and `status_banner.dart` (`_bgFor`/`_fgFor` were `static` and keyed only on the variant, so they couldn't reach `context` — parameterized the same way `FindingRow`'s already do, not a new pattern), plus five templates' `surfacePage` scaffold background. `study_review_template.dart` also had a raw `TabBar` configured inline with token colors — the one template-level color usage that wasn't just a background, and the one interactive Material widget in this app without its own `App*` atom — extracted into a new `AppTabBar`, at the user's request, over an in-place swap. Writing its dark-theme test surfaced a real, unrelated bug: pumping light then dark within one test is a live theme transition, not a fresh mount, and `MaterialApp` animates that change — a single frame lands mid-interpolation, not at the target color. Fixed with `pumpAndSettle`, not by loosening the assertion.

Gap 20 closed outright: `case_list_template.dart`'s medium-tier grid used `SliverGridDelegateWithFixedCrossAxisCount`'s fixed `childAspectRatio`, the only kind Flutter's grid delegates offer, so a card with more fields or 200%-scaled text had nowhere to grow. Reused `Wrap` (two fixed-width columns, each row following its tallest cell) rather than adding a package — the same "prefer what's already there" reasoning as gap 32's whole pass.

Gap 19 was not closed, at the user's explicit choice, but its row is sharper now: the heatmap ramp isn't blocked only on "no production heatmap to test against" — the overlay is backend-generated, so picking a ramp also means specifying to the backend what it sends and how transparency works, a cross-system contract this pass was not asked to write.

`flutter analyze` clean, `flutter test` at 564 passing (was 550).

---

## Conforming — do not re-litigate

| Rule | Evidence |
|---|---|
| Closed palette; no hex literals, no `_Palette` outside the token file | 0 occurrences |
| No `Theme.of(context).colorScheme` in custom widgets | 0 occurrences |
| No inline `BorderRadius.circular`, `Duration`, or `TextStyle` | 0 in production (2 `TextStyle` in `@Preview` helpers) |
| Pages apply no tokens directly (AGENTS.md) | All 7 pages clean |
| Severity and app status never share a component (DL §3.5) | Verified per file; only the token file contains both |
| No elevation stacking; every atom flat (DT §6) | All 7 `AppElevation` sites and their parents checked |
| `caption` restricted to non-clinical text (DL §4.5) | 2 sites, both timestamps/subtitles |
| No text-scale cap (DL §8.6) | Nothing clamps `TextScaler` — passes by omission |
| Raw Material colors confined to previews | 16 occurrences, all below a `── Previews ──` divider |
| `SeverityDot` renders a distinct icon per level, not just color (DL §3.6, D-003) | 4 shapes, verified in the widget and its test |
| Severity/status/muted-text contrast remediated (DL §8.7) | `_Palette` holds the fixed hex; every ratio recomputed and passing |
| `AppLayout`'s own comment no longer contradicts DT §9.6 | Reads "never `MediaQuery.of(context).size`" |
| `MetadataField` renders identifiers in `mono` and measurements/dates in `numeric`; neither truncates (DL §4.2, §4.6) | `metadata_field_test.dart`; wired at `study_info_card.dart`'s Study UID field |
| `mono`, `numeric`, and `bodyLg` are no longer unused app-wide | `MetadataField`'s value-kind API; `ChatBubble`'s message style |
| Severity labels render at `labelMd` (12px), not `labelSm` (10px) | `severity_chip.dart`, `finding_row.dart`; pinned by a floor test in each |
| `FindingRow`'s name un-clamps when `isExpanded` — the full value is reachable, not just the chevron (DL §4.6) | `finding_row_test.dart`'s collapsed/expanded pair |
| `ChatBubble` reads `LayoutBuilder` constraints, not `MediaQuery.of(context).size` (DT §9.6) | `chat_bubble_test.dart`'s box-vs-window test |
| `ChatBubble` message text renders in `bodyLg`, not `bodyMd` (DT §3.2) | `chat_bubble_test.dart` |
| Composer padding is generous (16/12); finding-row padding is dense (12/8) — not inverted (DL §7.1) | `chat_input_test.dart`, `finding_row_test.dart` |
| At most one Layer-5 alarm per viewport; multiples aggregate to one chip (DL §5.2) | `findings_panel_test.dart` counts w600 severity labels — 1 for three criticals, 1 for a lone critical, 0 below moderate |
| `normal` and `mild` never get alarm treatment, and keep label + dot anyway (DL §5.3, §3.6) | `FindingRow` ignores `isAlarm` for both levels; pinned per level |
| The diagnostic canvas is grounded in a mode-exempt token, not a semantic surface (DL §3.7, D-004) | `DiagnosticImageTokens.canvasGround`; both viewer and study-review image slot assert light == dark |
| Focus indication now reaches every interactive molecule, not just atoms (DL §8.4) | `nav_item_test.dart`, `finding_row_test.dart`, `image_thumbnail_test.dart`, `app_chip_test.dart` — transparent-then-visible pinned per widget, plus a dark-theme case |
| `OnboardingCarousel` survives 200% text scale — content scrolls instead of overflowing (DL §8.6, DT §3.7) | `onboarding_carousel_test.dart`'s 200%-scale and scroll-view tests |
| The default border clears the meaningful-border floor, matching dark mode's role for the same token (DL D-016) | `design_tokens_test.dart`'s contrast and deprecated-alias-parity tests |
| `NavigationTokens` and `ChatTokens` are context-aware, not flat light-only statics — every real consumer resolves correctly in dark mode (DL §6) | New dark-theme tests in `nav_item_test.dart`, `app_nav_bar_test.dart`, `conversation_drawer_test.dart`, `chat_bubble_test.dart`, `chat_input_test.dart`, `typing_indicator_test.dart` |
| Organism test coverage is 8 of 8 (AGENTS.md) | `status_bar_test.dart`, `chat_panel_test.dart`, `chat_message_list_test.dart` are new; `conversation_drawer_test.dart`, `app_nav_bar_test.dart` from the prior pass |
| All seven templates branch on real tiers and pane fit via `LayoutBuilder`, not a flat width and not `MediaQuery` (DL §9.1, §9.6) | A `layoutTier` boundary or pane-fit test per template — see each template's own test file |
| The 168px chat column is structurally impossible now — chat and study review gate their multi-pane layouts at `threePaneMinWidth`, not a flat 768 (DT §9.1) | `chat_template_test.dart`, `study_review_template_test.dart` boundary tests |
| `AuthTemplate`'s card caps at `formMaxWidth` (400) and carries no shadow — resting content, not raised (DT §9.5, gap 22) | `auth_template_test.dart` |
| Templates apply only the token classes their level allows — no molecule-shaped widget hides inside a template file (AGENTS.md) | `SectionCard`/`SectionIndexTile` extracted out of `settings_template.dart`; `section_card_test.dart`, `section_index_tile_test.dart` |
| `AppBar` titles render in the app's own type stack, not the platform default (DL §4.1) | `buildAppTheme()`'s `appBarTheme.titleTextStyle`; `design_tokens_test.dart`, `chat_page_test.dart` |
| The findings bottom sheet's height responds to the available screen height, not a width constant (DT §9.3) | `chat_template_test.dart`'s height-scaling case |
| `AppScrollbar` and `TooltipTokens` are brightness-aware — scrollbar colors reuse existing semantic fields, the tooltip surface derives a real dark value (DL §6, D-017) | `design_tokens_test.dart`'s `scrollbarTheme`/`tooltipTheme` groups |
| `NavItem` and `chat_input.dart`'s send/attach buttons meet the 44px touch-target floor (DL §8.5) | `nav_item_test.dart`, `chat_input_test.dart` size assertions per layout/button |
| Case List gains a dense, sortable worklist table at expanded and up, reflowing rather than clipping at scale (DT §9.5, D-010) | `CaseWorklistTable`; `case_worklist_table_test.dart`'s `dataRowMaxHeight`/`FlexColumnWidth`/sort/200%-scale cases |
| Settings has a real Appearance section — Dark/Light/System, persisted across launches (DT §10.5, DL D-013) | `theme_controller_test.dart`, `theme_mode_selector_test.dart`, `app_test.dart`, `settings_page_test.dart` |
| Chat's compact-tier findings sheet is genuinely draggable, not a fixed fraction (DT §9.5) | `draggable_findings_sheet_test.dart`'s resize/max-size cases |
| Chat gains a real medium-tier collapsed rail — conversations and findings reachable via `Scaffold` drawer/endDrawer, not a flat narrow/wide split (DT §9.5) | `collapsed_nav_rail_test.dart`; `chat_template_test.dart`'s medium-tier group |
| Bespoke widgets replaced with their native Flutter equivalent where one genuinely fits, not just where one superficially resembles it (AGENTS.md simplicity rule) | `AppNavBar`→`NavigationBar`, `ConversationDrawer`→`Drawer`, `ThemeModeSelector`/`SectionIndexTile`→`ListTile`; `Card`, `MaterialBanner`, `NavigationRail`, and `Badge` checked and declined, with reasoning, for the remaining card containers, status banners, the collapsed rail, and the thumbnail badge |
| Dark mode reaches every real screen — the last organism, molecule, and five templates read `context.colors` (DL §6) | `study_info_card_test.dart`, `status_banner_test.dart`, and a dark-theme case in each of `auth_template_test.dart`, `onboarding_template_test.dart`, `chat_template_test.dart`, `case_list_template_test.dart`, `study_review_template_test.dart` |
| `study_review_template.dart`'s `TabBar` styling moved into a new `AppTabBar` atom, matching this app's one-atom-per-Material-widget convention | `app_tab_bar_test.dart` |
| Case List's medium-tier grid reflows instead of clipping — a taller card grows its row, and 200% text scale survives (DT §3.7) | `case_list_template_test.dart`'s taller-slot and 200%-scale cases |

---

## High clinical risk

*No rows remain — gap 9, the last one, closed in the fifth pass (see Conforming).*

## Medium clinical risk

| # | Gap | Rule | Where | Effort | §12 |
|---|---|---|---|---|---|
| 19 | **Heatmap overlay built from status colours**, two of the three ARGB-identical to severity foregrounds. `DiagnosticImageTokens` now exists and carries the canvas ground (gap 6's pass), but **deliberately not the ramp**. Sharper than originally logged: this isn't only "no production heatmap to test against" — the overlay is backend-generated, so choosing a ramp also means specifying to the backend what it sends (per-pixel intensity? pre-rendered RGBA?) and how alpha/transparency works. That's a cross-system data-contract decision, not a color pick a frontend pass can make alone; deriving one without it risks a ramp the backend can't actually feed. The page never passes an overlay (`heatmap_viewer_page_test.dart` pins it null), `baseImage` is a debug `Placeholder`, and the offending gradient is preview-only code. | DL §3.7, D-004 | `heatmap_viewer_template.dart` previews | M | #5 |

## Low clinical risk

| # | Gap | Rule | Where | Effort | §12 |
|---|---|---|---|---|---|
| 23 | **Cursor tokens now consumed; hover color still entirely dead.** `AppButton` wires `mouseForbidden`/`mousePointer` through its `ButtonStyle.mouseCursor` — a real, narrower mechanism than the hover-overlay one this row describes. `MouseRegion` itself is still unused everywhere, and `hoverOverlayOpacity`, `NavigationTokens.sideNavHoverColor`, and the rest of the hover-color tokens remain dead. | DT §12 | whole app (hover color); button cursor wiring is the one exception | M | #6 |
| 27 | **Most colour assertions can't detect a migration regression, and all of them are scheduled to break.** 17 test files assert against the `@Deprecated` `AppColors.*` statics; 8 use the resolved `AppColorsData.light`/`.dark`. Because `AppColors.X` *is* an alias to `AppColorsData.light.X`, a light-theme assertion matches whether or not the widget was migrated — so these tests catch a hex change but not a widget that still reads the deprecated static directly. That is precisely the regression Steps 2–5 exist to prevent. Separately, Step 5's alias deletion breaks all 17 at once; its **S** estimate and its "tests to change" note account for none of them. `AppLoadingIndicator` is the clean illustration: the atom is correctly migrated (`app_loading_indicator.dart:23` reads `context.colors.interactivePrimary`), its test cannot tell (`:21,26,29`), and it never received the dark-theme test its `app_icon`/`app_text` siblings got in Step 2. | AGENTS.md | 17 files under `test/`; see `app_loading_indicator_test.dart` | M | — |

---

## One violation is pinned by a passing test

None remain. `severity_dot_test.dart:74` asserted `BoxShape.circle` — rewritten alongside the widget, closing gap 4. `heatmap_viewer_template_test.dart:91,139` asserted the canvas was `AppColors.surfaceBrand` — rewritten in gap 6's pass. `auth_template_test.dart:60` asserted `boxShadow == AppElevation.overlay` — rewritten to assert its absence in the seventh pass, closing gap 22. Kept as a heading rather than deleted: the pattern recurs (a test that pins a violation as correct), and it is worth a place to look.

---

# Remediation plan

## Why bottom-up

Templates own layout and nothing else — `AGENTS.md` permits them exactly two token classes (`AppSpacing`, `AppColors.surfacePage`). They are therefore *structurally incapable* of fixing typography, severity encoding, focus, or colour. Only **6 of the 26 gaps** live in templates or pages, and only **1 of the 10 high-risk gaps** does.

So the order follows the dependency rule the repo already enforces: tokens → atoms → molecules → organisms → templates+pages. Anything else means building on foundations that will move.

## The rule that shapes every step

**The dark-mode migration rides along with each layer's pass — it is never a separate sweep.** Step 1 introduces the `ThemeExtension` classes *and keeps every existing static token as a `@Deprecated` alias*, so the repo compiles and renders identically the moment it lands. Each later step then converts its own layer's colour reads to `context.colors` while it is already editing those files. The deprecated aliases are deleted at the end of step 5.

Without this, all 46 widget files get edited twice.

## Step 1 — Tokens

**Done, verified** — closes **10, 24**, part of **16, 18**. One item below was planned but, checked directly against the actual code, never built — **19a** stays open; **11** closed in a ninth pass, though narrower than this table's own wording (see the reconciliation note).

| Work | Gap | Effort | Status |
|---|---|---|---|
| `ThemeExtension` data classes for every colour-bearing token set, light + dark, plus `context.colors` accessors. Every existing static kept as a `@Deprecated` alias. | 18 | L | Done |
| Apply the specified severity/status foregrounds | 10 | S | Done |
| Wire `textTheme` and `fontFamily` into `buildAppTheme()` so Material widgets stop falling back to Roboto | 11 | S | **Done** — narrower than planned: `appBarTheme.titleTextStyle` only, not a repo-wide `textTheme` (see reconciliation note — the only 16 real bypass sites are almost all `AppBar` titles, and a full `textTheme` risked pulling in Material 3 default weights this app's fonts don't have files for) |
| Add `DiagnosticImageTokens` — canvas ground and a perceptual heatmap ramp | 19a | S | **Half done** — the class and `canvasGround` exist (gap 6's pass); the ramp is deliberately deferred, see gap 19 |
| Add pane minimums and tier boundaries; retire the six dead breakpoints | 16a | S | Done |
| Correct the `MediaQuery` comment that contradicts DT §9.6 | 24 | S | Done |

**Exit, as it actually turned out:** repo compiles, 355 tests pass (up from 324 — new tests added for the dark elevation ladder and the `onError` fix), app renders identically in light mode. Dark mode exists correctly in the token layer, verified field-by-field against DT §10.4, but nothing above the atom layer consumes it yet — matching what this exit criterion already anticipated.

## Step 2 — Atoms

**Done, verified** — closes **4**, part of **8, 18, 20, 23** (atom-level only; each stays open for the molecule/organism/template sites its own row still cites). **14** closed in full in a tenth pass — its own molecule site, `nav_item.dart`, needed the fix this table only applied to atoms.

| Work | Gap | Effort |
|---|---|---|
| `SeverityDot` gains a distinct silhouette per level — the missing redundancy channel | 4 | M |
| Focus rings on every interactive atom, wired to the existing `AppInteraction` tokens — **overclaimed**: `AppButton`/`AppTextField` got one, `AppChip` didn't; closed later in gap 8's own standalone pass | 8 (atoms only) | M |
| Explicit touch-target minimums; override Flutter's desktop `shrinkWrap`/`compact` defaults | 14 (atoms only) | M |
| Cursor wiring via `ButtonStyle.mouseCursor` — narrower than the `MouseRegion` hover-color mechanism 23 actually needs, which is still entirely unbuilt | 23 (cursor only) | M |
| Role enums (`AppTextRole`, `AppIconRole`) so call sites stay `const` and become mode-correct | 18 (atoms only) | M |
| `AppAvatar` survives 200% scale | 20 (closed) | S |

**Test changed:** `severity_dot_test.dart:74` no longer asserts `BoxShape.circle` — it asserts a distinct icon per level plus a uniqueness check. Done.

## Step 3 — Molecules

**Done, verified** — closes **1, 2, 3, 7, 12, 15, 21**, narrows **18** (3 of its 4 molecule files migrated). The largest clinical-risk reduction of any step, as anticipated.

One work item below was mis-filed under this step and was **not** executed as part of it: `ConversationDrawer` lives at `lib/ui/organisms/conversation_drawer.dart`, checked directly — an organism, not a molecule. Moved to Step 4's table, where it actually belongs; gap 20 stays fully open.

| Work | Gap | Effort | Status |
|---|---|---|---|
| `MetadataField` gains a value-kind API — identifiers render in `mono`, measurements and dates in `numeric`, neither truncates | 1, 2 | M | Done |
| Severity labels move off 10px `labelSm` to a size at or above the clinical floor | 3 | S | Done |
| `FindingRow` — either a real expand or a tooltip carrying the full description | 7 | S | Done — the name itself un-clamps when `isExpanded`, no tooltip needed |
| `ChatBubble` reads `LayoutBuilder` constraints, not the window | 12 | S | Done |
| `ChatBubble` message text moves to `bodyLg` | 21 | S | Done |
| Density correction — the composer becomes generous, scanning rows become dense | 15 | M | Done |
| ~~`ConversationDrawer` tiles drop the fixed-width-plus-clamp pattern~~ | 20b | M | **Mis-filed — moved to Step 4** |

**Migration rode along, per the rule above:** `finding_row.dart`, `metadata_field.dart`, and `severity_chip.dart` all converted their colour reads to `context.colors`/`context.severity` while already being edited for the fixes above — `SeverityChip.bgFor`/`colorFor` and `FindingRow`'s equivalents changed signature to take the resolved `SeverityData` rather than reading the deprecated static directly. `status_banner.dart` was not touched this step (no gap in this register required editing it) and remains on the deprecated alias.

**Exit:** `flutter analyze` clean, `flutter test` at 383 passing (was 362 — 21 new/changed tests across `metadata_field_test.dart`, `severity_chip_test.dart`, `finding_row_test.dart`, `chat_bubble_test.dart`, `chat_input_test.dart`, including new dark-theme resolution tests matching the pattern Step 2 established for atoms).

A fifth pass closed gap 9 and a gap this register never actually carried, found while answering a direct question about what the plan was missing. `OnboardingCarousel`'s `_SlidePage` moved from a bare `Column` to a `LayoutBuilder` + `SingleChildScrollView` + `ConstrainedBox(minHeight: ...)`, the standard shrink-when-short/scroll-when-tall pattern — the fixed 240px image keeps its height, and the title and description now have somewhere to grow at 200% scale instead of overflowing. Its remaining color reads moved to `context.colors` in the same edit, per the migration-rides-along rule; that drops gap 18's unmigrated-file count from 14 to 13 (`onboarding_carousel` leaves the list). The pass also, incidentally, raised organism test coverage from 2 of 8 to 3 of 8 (gap 26) — a side effect of testing this fix, not an attempt at that gap, which stays open for the other five.

The second finding was never a row here at all — only `design_tokens.md` §12's own gap 7 and an explicit "Open issue" note in `design_language.md`, neither of which this register had absorbed. Light mode's `border` token measured 1.74:1 against white, specified as "decorative only" — but real call sites already leaned on it as a meaningful boundary: `AppTextField`'s resting outline, `AppButton`'s secondary variant, Material's `ColorScheme.outline`. Dark mode's identically-named `border` token had already solved this same problem, at 3.15:1, "meaningful borders only" — light mode never followed suit. Fixed by reusing `gray500` (`#7D7D7D`, already in the palette, already used for `interactiveDisabledForeground`), which clears 3:1 against both `surfacePage` and `surface` — 3.74:1 and 4.12:1 — rather than deriving a new hex. `design_language.md` gains D-016 for the reasoning. No consumer needed to move to `borderSubdued` instead: nothing in production was actually relying on `border` reading as a faint decorative hairline; `AppDivider`, the one genuinely decorative consumer, already defaulted to `borderSubdued`. Assigned row 28 here, since this register's own row 7 was already closed (`FindingRow`'s truncation fix, Step 3) and unrelated to the border. `flutter analyze` clean, `flutter test` at 422 passing (was 415).

A sixth pass fixed something the user flagged directly as exactly the kind of gap this register exists to catch: `design_tokens.md` §1 marks `NavigationTokens` and `ChatTokens` "Mode-dependent: Yes — derives from §10.4," the same claim it makes for `AppColors` — but both were still flat `static const` classes aliasing the deprecated light-only statics, never migrated to the `ThemeExtension` mechanism Step 1 built. Worse, gap 18's own file count never caught this: it was compiled by grepping for literal `AppColors.` usage, which is invisible to a file that goes through `NavigationTokens`/`ChatTokens` instead — so `nav_item.dart`, `chat_bubble.dart`, `chat_input.dart`, and `typing_indicator.dart` were dark-mode-broken all along without ever appearing in the "still open" list. Fixed by converting every color member of both classes to a method taking `BuildContext` and resolving through `context.colors` — no new derivation needed, since every field was already a rename of an existing `AppColorsData` field (`drawerBackground` = `surfaceBrandSecondary`, `userBubble` = `interactivePrimary`, etc.). `NavigationTokens.sideNavHoverColor` stays a flat constant on purpose: nothing reads it yet (gap 23), so there is no live call site to derive a dark value against. Assigned row 29 here, closed the same pass. While investigating, found the identical defect in `AppScrollbar` and `TooltipTokens` — consumed only inside `buildAppTheme()`'s own `scrollbarTheme`/`tooltipTheme`, baked in at build time regardless of brightness — but neither has a ready-made semantic field to alias, and `TooltipTokens` may be intentionally mode-invariant rather than broken. Logged, not fixed, as row 30. `ConversationDrawer` also picked up gap 20b (its header, tile title, and tile subtitle now allow 2 lines instead of 1, so text has somewhere to grow at 200% scale) and half of gap 25 (`drawerWidth` is wired in place of a hardcoded `280`) in the same pass, since both were already in the exact file this work was touching. Organism test coverage rises to 5 of 8 (gap 26) as a side effect of proving the fix — `conversation_drawer_test.dart` and `app_nav_bar_test.dart` are new. `flutter analyze` clean, `flutter test` at 444 passing (was 422).

## Step 4 — Organisms

**Done, verified** — closes **5, 9, 26**; narrows **20** (the `ConversationDrawer` portion — `case_list_template.dart`'s fixed-ratio grid cells are a separate site the row also cites and stay open). **5** was taken early, out of step order, at the user's direction.

| Work | Gap | Effort | Status |
|---|---|---|---|
| `FindingsPanel` aggregates Layer-5 — one alarm per viewport, with `normal` and `mild` demoted out of alarm treatment | 5 | M | **Done** — adaptive: a lone alarm-level finding keeps its row chip (DL §5.4); two or more collapse to one header chip and every row goes quiet (DL §5.2) |
| `OnboardingCarousel` survives 200% scale — the fixed 240px image needs a scroll context | 9 | S | **Done** — `LayoutBuilder` + `SingleChildScrollView` + `ConstrainedBox(minHeight: ...)`; color reads migrated to `context.colors` in the same edit |
| Organism test coverage from 5 of 8 to 8 of 8 | 26 | M | **Done** — `status_bar_test.dart`, `chat_panel_test.dart`, `chat_message_list_test.dart` added; `status_bar.dart`/`chat_panel.dart` migrated to `context.colors` while already being touched |
| `ConversationDrawer` tiles drop the fixed-width-plus-clamp pattern (moved here from Step 3 — this is an organism, `lib/ui/organisms/conversation_drawer.dart`, not a molecule) | 20b | M | **Done** — header, tile title, and tile subtitle allow 2 lines instead of 1; also picked up `NavigationTokens`/`ChatTokens` context-awareness and gap 25's `drawerWidth` wiring in the same pass |

**Exit:** `flutter analyze` clean, `flutter test` at 462 passing (was 444). Organism test coverage reaches 8 of 8; `chat_message_list.dart` needed no color migration at all — it never touched a deprecated static, only spacing and motion tokens plus already-migrated child widgets.

## Step 5 — Templates and pages

Closes **13, 16, 17, 22, 25** (done); still to finish **18, 19, 20**. **6** was taken early, out of step order, at the user's direction — as was the tier-branching half of **16**, done in a seventh pass ahead of this step's own turn, at the user's direction to sequence tiers before per-page new UI; **25**, closed in a ninth pass alongside gaps 11 and 30 at the user's request to batch every remaining **S**-effort item; and **17**, closed in full in a tenth pass at the user's direction, after an initial narrower pick, to do all four of its sub-items in one go.

| Work | Gap | Effort | Status |
|---|---|---|---|
| Responsive tiers and pane-composition minimums across all seven templates; the four with no branching gain it | 16 | L | **Done** — seventh pass |
| Per-page specs: the Case List worklist table, the Settings Appearance section, ~~the heatmap right rail~~, the draggable findings sheet, the collapsed nav rail | 17 | L | **Done** — tenth pass; the heatmap right rail item was already done in the seventh pass (gap 16) and is struck here, not double-counted |
| ~~Diagnostic canvas becomes a forced-dark subtree using `DiagnosticImageTokens`, exempt from theme mode~~ — **done early**: `canvasGround` in both the viewer and `study_review_template`'s image slot, viewer chrome forced dark per DT §10.2 | 6 | M | Done |
| The 168px column dies with the pane minimums | 13 | M | **Done** — seventh pass, rides along with 16 |
| Heatmap overlay switches to the perceptual ramp — still blocked on deriving one, see gap 19 | 19b | S | |
| `AuthTemplate` drops the resting-content shadow and caps at `formMaxWidth` | 22 | S | **Done** — seventh pass |
| `panelMaxWidth` stops being used as a height | 25 | S | **Done** — ninth pass |
| Delete the deprecated static token aliases — **not S**: 17 test files assert against them and break together, see gap 27 | 18, 27 | M | |

**Tests to change:** deleting the aliases forces a rewrite of every `AppColors.*` assertion across **17 test files** — gap 27. Convert them to `AppColorsData.light`/`.dark` as they are touched, and add the dark-theme cases the older atom tests never got, rather than doing a mechanical find-and-replace that preserves their blind spot. (`auth_template_test.dart:60` and `heatmap_viewer_template_test.dart:91,139` used to sit here too — both rewritten now, in gap 6's pass and the seventh pass respectively.)

## Sequencing notes

- **Steps 2, 3 and 4 are independently shippable** once step 1 lands — each leaves the app working. Step 5 depends on 3 (templates consume the corrected molecules).
- **Step 1 is the only step that cannot be partially delivered.** The extension classes and the deprecated aliases must land together or the repo stops compiling.
- **The theme toggle** (Settings Appearance section) is in step 5, but dark mode is usable from step 1 for anyone flipping `themeMode` manually — useful for reviewing each step's work in both modes.
- **Verification per step:** `flutter analyze`, `flutter test`, and a rendered screenshot in both brightnesses. A step is not done while any of the three is outstanding.
- **Close the register as you go.** Delete each row here and its matching `design_tokens.md` §12 entry in the same commit as the fix, so the two never drift.
