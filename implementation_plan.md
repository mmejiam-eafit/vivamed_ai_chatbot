# Design Conformance Register

Does the implemented app satisfy [`design_language.md`](design_language.md) (DL) and [`design_tokens.md`](design_tokens.md) (DT)?

**Verdict: no, and the gap is large but structured.** Of ~25 normative rules audited, 8 conform, 16 are violated, and 8 are specified with no implementation at all. (Twelve more have since closed outright — 4, 10, 24 from the tokens/atoms reconciliation, 1, 2, 3, 7, 12, 15, 21 from Step 3, and 5, 6 taken early out of step order — folded into Conforming below; several others have real, verified partial progress. One row has been **added** since the original audit — 27, found while implementing rather than while auditing — so the numbering now runs to 27 even though fewer rows are open than at the start. See the reconciliation notes above and each updated row.)

The gap splits along one clean line. **Mechanical rules — the greppable ones — are at 100% in production code:** zero hex literals, zero `_Palette` references, zero `Theme.of(context)`, zero inline radii or durations. **Semantic rules — everything the design language newly articulated — are largely unimplemented:** the mono voice, tabular figures, severity redundancy, the truncation policy, the perceptual hierarchy, responsive tiers, focus, density, and dark mode.

That shape is expected rather than alarming. The design documents were written *after* the app and describe an intent it was never built to satisfy. The old rules were enforceable by grep and were enforced; the new rules describe judgment and nothing yet expresses them.

## How to read this

Rows are grouped by **clinical risk** — could a radiologist be misled, or miss something. **Effort** is S (hours), M (about a day), L (multi-day or architectural). Each row cites the rule it breaks and the code that breaks it.

This register supersedes the known-gaps table at `design_tokens.md` §12; the "§12" column records which entries it absorbs. When a gap closes, delete the row here and the matching §12 entry together.

Audited at commit `906e91f`. A reconciliation pass since then (uncommitted at audit time, atoms + tokens + `app.dart` only — no organism, molecule, or template touched) closed three rows outright (4, 10, 24) and made partial, atom-only progress on several others (8, 14, 16, 20, 23) — updated in place below rather than re-auditing from scratch. Two things the reconciliation *claimed* in its own step plan below turned out not to have happened when checked directly: gap 11 (no `textTheme`, still Roboto) and gap 19's `DiagnosticImageTokens` (doesn't exist) — corrected in place, not silently left to look done.

A third pass took gaps **5** and **6** out of order, both high clinical risk, also uncommitted. Two things it found that the rows themselves did not say. Gap 6's ground value was **already specified** — DT §10.4 has carried `#0A0C0E` all along with no token to live in — so it needed implementing, not deciding, and `design_language.md` needed no change at all (D-004 and DL §3.7 already carry the reasoning). And gap 6 was **latent, not live**: `heatmap_viewer_template.dart` reads the deprecated static, so its canvas was frozen light-navy and never actually brightened; the brightening would have begun the moment gap 18 migrated the file. Fixing it now is preventive. The same DL §3.7 clause turned out to be broken a second time in a file gap 6 never cited — `study_review_template.dart` grounded its image slot in off-white `surfacePage` — and that was fixed in the same pass.

A second pass executed Step 3 (Molecules), uncommitted at time of writing. Closes rows 1, 2, 3, 7, 12, 15, 21 outright and narrows row 18 (`finding_row`, `metadata_field`, `severity_chip` now read `context.colors`/`context.severity`; `status_banner` still doesn't — 15 files remain, not 18). One correction to this document's own Step 3 table: it listed a `ConversationDrawer` fix (gap 20b) as molecule-layer work, but `conversation_drawer.dart` lives in `lib/ui/organisms/` — checked directly. That item was not executed as part of this pass; moved to Step 4's table, where it actually belongs. `flutter analyze` clean, `flutter test` at 383 passing (was 362).

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

---

## High clinical risk

| # | Gap | Rule | Where | Effort | §12 |
|---|---|---|---|---|---|
| 8 | **Focus indication exists on atoms, nowhere else.** `AppButton` and `AppTextField` both now have a real offset ring reading `AppInteraction`/`context.colors.borderFocused` — the class is no longer dead code. But interactive molecules (`nav_item.dart`, chips) still have no focus treatment at all, so most of the app's actual controls remain uncovered. | DL §8.4 | `nav_item.dart` and other interactive molecules | M | — |
| 9 | **Onboarding overflows at 200% text scale.** A fixed 240px image sits in a `Column` with no scroll view, so the title and description have nowhere to grow. | DL §8.6, DT §3.7 | `onboarding_carousel.dart:130-157` | S | — |

## Medium clinical risk

| # | Gap | Rule | Where | Effort | §12 |
|---|---|---|---|---|---|
| 11 | **Material widgets render in Roboto.** `buildAppTheme()` sets no `textTheme` and no `fontFamily` — only three ad-hoc styles. Every `AppBar` title and any bare `Text` bypasses the type stack entirely; 21 such sites. | DL §4.1 | `design_tokens.dart:863-868` | S | — |
| 13 | **The 168px chat column is live.** 768 − 240 nav − 360 panel, with nothing checking whether the panes fit. | DT §9.1 | `chat_template.dart:39,54`; `study_review_template.dart:53,74` | M | #3 |
| 14 | **Touch targets fixed on atoms; the two originally-cited molecules still aren't.** `AppButton` and `AppTextField` now enforce `AppInteraction.minTouchTarget` (44px) explicitly. `chat_input.dart` and `nav_item.dart` — this row's own cited violation sites — are unchanged; the chat send button is still the app's most-used uncovered control. | DL §8.5 | `chat_input.dart:55-60`, `nav_item.dart` | M | — |
| 16 | **Tokens now exist; templates still don't branch on them.** `AppLayout` has real tier boundaries (`compactMaxWidth`… `ultrawideMinWidth`) and pane minimums (`primaryColumnMin`, `panelMinWidth`, `twoPaneMinWidth`, `threePaneMinWidth`, `formMaxWidth`) — the five/nine and six-dead-breakpoints gap is closed at the token layer. But no template reads any of them: four of seven still have no branching at all (§12 #10 lists three and misses `auth_template`). | DT §9.2-9.4 | all templates | L | #2, #10 |
| 17 | **Per-page layout specs absent** — zero `DataTable`, zero "Appearance" section, no right rail, no draggable sheet, no collapsed rail state. | DT §9.5 | templates | L | — |
| 18 | **Dark mode: real at the token layer and in three molecules, invisible everywhere else a user would see it.** `ThemeExtension` classes, `context.colors`/`context.severity`, every dark value matching DT §10.4, `app.dart`'s `darkTheme`/`themeMode: ThemeMode.dark` — all built and verified correct. Every atom reads it, `finding_row`/`metadata_field`/`severity_chip` now do too (Step 3), and `findings_panel` does (gap 5's pass). But 14 files above the atom layer (6 organisms, 1 molecule, all 7 templates) still read the light-only static alias directly, and since every screen composes down through templates → organisms → molecules → atoms, dark mode does not render on any actual page. Confirmed by rendering all four canvas-reviewed screens in both modes: the dark and light captures of Study Review are pixel-identical. Two defects also found and fixed in the token layer itself while verifying this: the dark elevation ladder was missing its 4th step (`surfaceOverlay`, `#232C38` — §10.4's ladder needs four, only three existed), and `buildAppTheme`'s `onError` resolved to a light-toned color against a light-toned dark-mode error fill (1.66:1; now 9.07:1 via `surfacePage`). | DL §6 | 14 files: organisms `app_nav_bar`, `chat_panel`, `conversation_drawer`, `onboarding_carousel`, `status_bar`, `study_info_card`; the molecule `status_banner`; all 7 templates | L | #1 |
| 19 | **Heatmap overlay built from status colours**, two of the three ARGB-identical to severity foregrounds. `DiagnosticImageTokens` now exists and carries the canvas ground (gap 6's pass), but **deliberately not the ramp** — no ramp values are specified in either normative document, so building one means deriving new color and authorising it against D-001 with a decision-log entry. Deferred on purpose: there is no production heatmap to validate a ramp against. The page never passes an overlay (`heatmap_viewer_page_test.dart` pins it null), `baseImage` is a debug `Placeholder`, and the offending gradient is preview-only code. | DL §3.7, D-004 | `heatmap_viewer_template.dart` previews | M | #5 |
| 20 | **Text-scale hazards, two of three sites remain.** `AppAvatar` now wraps its initials in `FittedBox` + padding and survives 200% scale — closed. Still open: a fixed-width drawer combined with single-line clamps (the pattern DT §3.7 names explicitly), and fixed-ratio grid cells that cannot reflow. | DT §3.7 | `conversation_drawer.dart:46,154-167`; `case_list_template.dart:65-70` | M | — |

## Low clinical risk

| # | Gap | Rule | Where | Effort | §12 |
|---|---|---|---|---|---|
| 22 | `AppElevation.overlay` applied to resting content, and the auth card caps at 360 rather than `formMaxWidth` 400. | DT §6, §9.5 | `auth_template.dart:22,28` | S | — |
| 23 | **Cursor tokens now consumed; hover color still entirely dead.** `AppButton` wires `mouseForbidden`/`mousePointer` through its `ButtonStyle.mouseCursor` — a real, narrower mechanism than the hover-overlay one this row describes. `MouseRegion` itself is still unused everywhere, and `hoverOverlayOpacity`, `NavigationTokens.sideNavHoverColor`, and the rest of the hover-color tokens remain dead. | DT §12 | whole app (hover color); button cursor wiring is the one exception | M | #6 |
| 25 | `panelMaxWidth` (a width) used as a height; `drawerWidth` is dead while 280 is hardcoded at the call site. | DT §9.3 | `chat_template.dart:77`; `conversation_drawer.dart:46` | S | — |
| 26 | Organism test coverage is 2 of 8, and no test enforces any design rule except typography. | AGENTS.md | `test/ui/organisms/` | M | #9 |
| 27 | **Most colour assertions can't detect a migration regression, and all of them are scheduled to break.** 17 test files assert against the `@Deprecated` `AppColors.*` statics; 8 use the resolved `AppColorsData.light`/`.dark`. Because `AppColors.X` *is* an alias to `AppColorsData.light.X`, a light-theme assertion matches whether or not the widget was migrated — so these tests catch a hex change but not a widget that still reads the deprecated static directly. That is precisely the regression Steps 2–5 exist to prevent. Separately, Step 5's alias deletion breaks all 17 at once; its **S** estimate and its "tests to change" note account for none of them. `AppLoadingIndicator` is the clean illustration: the atom is correctly migrated (`app_loading_indicator.dart:23` reads `context.colors.interactivePrimary`), its test cannot tell (`:21,26,29`), and it never received the dark-theme test its `app_icon`/`app_text` siblings got in Step 2. | AGENTS.md | 17 files under `test/`; see `app_loading_indicator_test.dart` | M | — |

---

## Found during dark-mode verification, not yet diagnosed

Not root-caused, so not forced into the numbered format above — logged as observed, per the decision to track rather than chase it now.

**`FindingsPanel` produces a visible Flutter overflow warning when rendered with an empty findings list.** Rendering `StudyReviewPage` (which constructs `FindingsPanel(findings: [])`) at 1440×900 shows the classic yellow/black overflow stripe inside the panel. Found while screenshotting real pages to verify the dark-mode reconciliation above — unrelated to that work; looks pre-existing. Whether this is reachable in the real app (does a study ever actually have zero findings, and if so does something upstream avoid this exact construction?) is unknown. Tracked in `design_tokens.md` §12 gap 15.

**Update from gap 5's pass — the attribution is probably wrong, but not provably.** `FindingsPanel`'s whole content sits inside a `SingleChildScrollView`, and a scroll viewport clips rather than emitting `RenderFlex overflowed`; the empty branch is also *smaller* than the populated one that `findings_panel_test.dart` already proves fits in 200px. So the panel is an unlikely culprit. The credible mechanism is one layer up, at `study_review_template.dart`'s narrow branch: `AspectRatio(aspectRatio: 4/3)` sits in a `Column`, so it demands `width × 0.75` regardless of the height available, and the stripe would land over the `TabBarView` — which is exactly where the findings panel renders, hence the misattribution. At 720×450 logical (a 1440×900 capture at DPR 2) that arithmetic overflows by ~154px. **The caveat that stops this being a conclusion:** at 1440×900 *logical* the wide branch runs instead and nothing overflows, and the original capture's device pixel ratio is not recoverable. Left open and unreassigned; the `AspectRatio` was deliberately not changed in that pass.

---

## One violation is pinned by a passing test

It asserts the wrong behaviour as correct, so remediation means changing the test, not only the widget. (Two used to be here. `severity_dot_test.dart:74` asserted `BoxShape.circle` — rewritten alongside the widget, closing gap 4. `heatmap_viewer_template_test.dart:91,139` asserted the canvas was `AppColors.surfaceBrand` — rewritten in gap 6's pass; those assertions now check `DiagnosticImageTokens.canvasGround` and, more usefully, that the ground is *identical* in light and dark, which is what makes D-004 checkable at all.)

| Test | Asserts | Blocks gap |
|---|---|---|
| `auth_template_test.dart:60` | `boxShadow == AppElevation.overlay` | 22 |

---

# Remediation plan

## Why bottom-up

Templates own layout and nothing else — `AGENTS.md` permits them exactly two token classes (`AppSpacing`, `AppColors.surfacePage`). They are therefore *structurally incapable* of fixing typography, severity encoding, focus, or colour. Only **6 of the 26 gaps** live in templates or pages, and only **1 of the 10 high-risk gaps** does.

So the order follows the dependency rule the repo already enforces: tokens → atoms → molecules → organisms → templates+pages. Anything else means building on foundations that will move.

## The rule that shapes every step

**The dark-mode migration rides along with each layer's pass — it is never a separate sweep.** Step 1 introduces the `ThemeExtension` classes *and keeps every existing static token as a `@Deprecated` alias*, so the repo compiles and renders identically the moment it lands. Each later step then converts its own layer's colour reads to `context.colors` while it is already editing those files. The deprecated aliases are deleted at the end of step 5.

Without this, all 46 widget files get edited twice.

## Step 1 — Tokens

**Done, verified** — closes **10, 24**, part of **16, 18**. Two items below were planned but, checked directly against the actual code, never built — **11** and **19a** stay fully open; see the reconciliation note at the top of this document.

| Work | Gap | Effort | Status |
|---|---|---|---|
| `ThemeExtension` data classes for every colour-bearing token set, light + dark, plus `context.colors` accessors. Every existing static kept as a `@Deprecated` alias. | 18 | L | Done |
| Apply the specified severity/status foregrounds | 10 | S | Done |
| ~~Wire `textTheme` and `fontFamily` into `buildAppTheme()` so Material widgets stop falling back to Roboto~~ | 11 | S | **Not done** — no `textTheme` in `buildAppTheme()`, verified directly |
| Add `DiagnosticImageTokens` — canvas ground and a perceptual heatmap ramp | 19a | S | **Half done** — the class and `canvasGround` exist (gap 6's pass); the ramp is deliberately deferred, see gap 19 |
| Add pane minimums and tier boundaries; retire the six dead breakpoints | 16a | S | Done |
| Correct the `MediaQuery` comment that contradicts DT §9.6 | 24 | S | Done |

**Exit, as it actually turned out:** repo compiles, 355 tests pass (up from 324 — new tests added for the dark elevation ladder and the `onError` fix), app renders identically in light mode. Dark mode exists correctly in the token layer, verified field-by-field against DT §10.4, but nothing above the atom layer consumes it yet — matching what this exit criterion already anticipated.

## Step 2 — Atoms

**Done, verified** — closes **4**, part of **8, 14, 18, 20, 23** (atom-level only; each stays open for the molecule/organism/template sites its own row still cites).

| Work | Gap | Effort |
|---|---|---|
| `SeverityDot` gains a distinct silhouette per level — the missing redundancy channel | 4 | M |
| Focus rings on every interactive atom, wired to the existing `AppInteraction` tokens | 8 (atoms only) | M |
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

## Step 4 — Organisms

Closes **9, 26**; narrows **20** (the `ConversationDrawer` portion — `case_list_template.dart`'s fixed-ratio grid cells are a separate site the row also cites and aren't touched by this step). **5** was taken early, out of step order, at the user's direction.

| Work | Gap | Effort | Status |
|---|---|---|---|
| `FindingsPanel` aggregates Layer-5 — one alarm per viewport, with `normal` and `mild` demoted out of alarm treatment | 5 | M | **Done** — adaptive: a lone alarm-level finding keeps its row chip (DL §5.4); two or more collapse to one header chip and every row goes quiet (DL §5.2) |
| `OnboardingCarousel` survives 200% scale — the fixed 240px image needs a scroll context | 9 | S | |
| Organism test coverage from 2 of 8 to 8 of 8 | 26 | M | |
| `ConversationDrawer` tiles drop the fixed-width-plus-clamp pattern (moved here from Step 3 — this is an organism, `lib/ui/organisms/conversation_drawer.dart`, not a molecule) | 20b | M | |

## Step 5 — Templates and pages

Closes **13, 16, 17, 22, 25**, finishes **18, 19, 20**. Your overhaul — one pass, not two. **6** was taken early, out of step order, at the user's direction.

| Work | Gap | Effort |
|---|---|---|
| Responsive tiers and pane-composition minimums across all seven templates; the four with no branching gain it | 16 | L |
| Per-page specs: the Case List worklist table, the Settings Appearance section, the heatmap right rail, the draggable findings sheet, the collapsed nav rail | 17 | L |
| ~~Diagnostic canvas becomes a forced-dark subtree using `DiagnosticImageTokens`, exempt from theme mode~~ — **done early**: `canvasGround` in both the viewer and `study_review_template`'s image slot, viewer chrome forced dark per DT §10.2 | 6 | M |
| The 168px column dies with the pane minimums | 13 | M |
| Heatmap overlay switches to the perceptual ramp — still blocked on deriving one, see gap 19 | 19b | S |
| `AuthTemplate` drops the resting-content shadow and caps at `formMaxWidth` | 22 | S |
| `panelMaxWidth` stops being used as a height | 25 | S |
| Delete the deprecated static token aliases — **not S**: 17 test files assert against them and break together, see gap 27 | 18, 27 | M |

**Tests to change:** `auth_template_test.dart:60` asserts the current violation as correct. (`heatmap_viewer_template_test.dart:91,139` used to sit here too; gap 6's pass rewrote them.) Beyond that, deleting the aliases forces a rewrite of every `AppColors.*` assertion across **17 test files** — gap 27. Convert them to `AppColorsData.light`/`.dark` as they are touched, and add the dark-theme cases the older atom tests never got, rather than doing a mechanical find-and-replace that preserves their blind spot.

## Sequencing notes

- **Steps 2, 3 and 4 are independently shippable** once step 1 lands — each leaves the app working. Step 5 depends on 3 (templates consume the corrected molecules).
- **Step 1 is the only step that cannot be partially delivered.** The extension classes and the deprecated aliases must land together or the repo stops compiling.
- **The theme toggle** (Settings Appearance section) is in step 5, but dark mode is usable from step 1 for anyone flipping `themeMode` manually — useful for reviewing each step's work in both modes.
- **Verification per step:** `flutter analyze`, `flutter test`, and a rendered screenshot in both brightnesses. A step is not done while any of the three is outstanding.
- **Close the register as you go.** Delete each row here and its matching `design_tokens.md` §12 entry in the same commit as the fix, so the two never drift.
