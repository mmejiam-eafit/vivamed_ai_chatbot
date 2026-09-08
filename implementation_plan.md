# Design Conformance Register

Does the implemented app satisfy [`design_language.md`](design_language.md) (DL) and [`design_tokens.md`](design_tokens.md) (DT)?

**Verdict: no, and the gap is large but structured.** Of ~25 normative rules audited, 8 conform, 16 are violated, and 8 are specified with no implementation at all. (Three more have since closed — 4, 10, 24, folded into Conforming below — and the token/atom layer has real, verified partial progress on several others; see the reconciliation note above and each updated row.)

The gap splits along one clean line. **Mechanical rules — the greppable ones — are at 100% in production code:** zero hex literals, zero `_Palette` references, zero `Theme.of(context)`, zero inline radii or durations. **Semantic rules — everything the design language newly articulated — are largely unimplemented:** the mono voice, tabular figures, severity redundancy, the truncation policy, the perceptual hierarchy, responsive tiers, focus, density, and dark mode.

That shape is expected rather than alarming. The design documents were written *after* the app and describe an intent it was never built to satisfy. The old rules were enforceable by grep and were enforced; the new rules describe judgment and nothing yet expresses them.

## How to read this

Rows are grouped by **clinical risk** — could a radiologist be misled, or miss something. **Effort** is S (hours), M (about a day), L (multi-day or architectural). Each row cites the rule it breaks and the code that breaks it.

This register supersedes the known-gaps table at `design_tokens.md` §12; the "§12" column records which entries it absorbs. When a gap closes, delete the row here and the matching §12 entry together.

Audited at commit `906e91f`. A reconciliation pass since then (uncommitted at audit time, atoms + tokens + `app.dart` only — no organism, molecule, or template touched) closed three rows outright (4, 10, 24) and made partial, atom-only progress on several others (8, 14, 16, 20, 23) — updated in place below rather than re-auditing from scratch. Two things the reconciliation *claimed* in its own step plan below turned out not to have happened when checked directly: gap 11 (no `textTheme`, still Roboto) and gap 19's `DiagnosticImageTokens` (doesn't exist) — corrected in place, not silently left to look done.

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

---

## High clinical risk

| # | Gap | Rule | Where | Effort | §12 |
|---|---|---|---|---|---|
| 1 | **`MetadataField` breaks three typography rules at once.** Renders every clinical value in `bodyMd` rather than `mono`, without tabular figures, clamped to one line with an ellipsis and no escape. It is the single funnel for all clinical data in the app — a clipped Study UID is indistinguishable from a complete one. No API to opt out: the widget takes only `label` and `value`. | DL §4.2, §4.3, §4.6 | `metadata_field.dart:26-33` | M | #11 |
| 2 | **`mono` and `numeric` are used zero times app-wide.** The mono voice is DL's named safety feature and it reaches nothing. `1.2.840.10008.5.1.4.1.1.2` renders as body text. `bodyLg` is also unused. | DL §4.2, §4.3 | whole app | M | — |
| 3 | **Severity labels render at 10px** (`labelSm`), two steps below the 12px clinical floor — and this is the channel carrying colour-vision redundancy. | DL §4.5, §8.2 | `severity_chip.dart:53`, `finding_row.dart:80` | S | — |
| 5 | **Layer 5 is unbounded.** N findings produce N full-chroma chips with no aggregation, and all four levels get alarm treatment including `normal` — so nothing is left for a critical finding to win against. | DL §5.2, §5.3 | `findings_panel.dart:72-86`, `finding_row.dart:64-85` | M | — |
| 6 | **The diagnostic canvas is themed with chrome navy.** `surfaceBrand` was chosen for being "the darkest available semantic token" — the appearance-based reasoning D-001 forbids. Worse, DT §10.4 makes `surfaceBrand` *lighter* in dark mode, so the evidence surround will brighten under a user preference. | DL §3.7, §6.5, D-004 | `heatmap_viewer_template.dart:32,42` | M | — |
| 7 | **Finding descriptions clamp behind a non-functional escape.** `isExpanded` is read at exactly one line — it swaps the chevron glyph and renders nothing else. The affordance that would make clamping legal is decorative. | DL §4.6 | `finding_row.dart:56-61,88` | S | #12 |
| 8 | **Focus indication exists on atoms, nowhere else.** `AppButton` and `AppTextField` both now have a real offset ring reading `AppInteraction`/`context.colors.borderFocused` — the class is no longer dead code. But interactive molecules (`nav_item.dart`, chips) still have no focus treatment at all, so most of the app's actual controls remain uncovered. | DL §8.4 | `nav_item.dart` and other interactive molecules | M | — |
| 9 | **Onboarding overflows at 200% text scale.** A fixed 240px image sits in a `Column` with no scroll view, so the title and description have nowhere to grow. | DL §8.6, DT §3.7 | `onboarding_carousel.dart:130-157` | S | — |

## Medium clinical risk

| # | Gap | Rule | Where | Effort | §12 |
|---|---|---|---|---|---|
| 11 | **Material widgets render in Roboto.** `buildAppTheme()` sets no `textTheme` and no `fontFamily` — only three ad-hoc styles. Every `AppBar` title and any bare `Text` bypasses the type stack entirely; 21 such sites. | DL §4.1 | `design_tokens.dart:863-868` | S | — |
| 12 | **`ChatBubble` measures the window, not its box.** At 1600px it computes a 480px cap inside a 360px pane, which overflows rather than merely mis-proportions. Also places responsive logic in a molecule. | DT §9.6 | `chat_bubble.dart:26-29` | S | #4 |
| 13 | **The 168px chat column is live.** 768 − 240 nav − 360 panel, with nothing checking whether the panes fit. | DT §9.1 | `chat_template.dart:39,54`; `study_review_template.dart:53,74` | M | #3 |
| 14 | **Touch targets fixed on atoms; the two originally-cited molecules still aren't.** `AppButton` and `AppTextField` now enforce `AppInteraction.minTouchTarget` (44px) explicitly. `chat_input.dart` and `nav_item.dart` — this row's own cited violation sites — are unchanged; the chat send button is still the app's most-used uncovered control. | DL §8.5 | `chat_input.dart:55-60`, `nav_item.dart` | M | — |
| 15 | **Density is inverted.** The chat composer — the rule's own example of a *generous* surface — is the tightest in the app at 12/8, while the findings rows it should contrast against use 16/12. No component is dense. | DL §7.1 | `chat_input.dart:30-33` vs `finding_row.dart:49-52` | M | — |
| 16 | **Tokens now exist; templates still don't branch on them.** `AppLayout` has real tier boundaries (`compactMaxWidth`… `ultrawideMinWidth`) and pane minimums (`primaryColumnMin`, `panelMinWidth`, `twoPaneMinWidth`, `threePaneMinWidth`, `formMaxWidth`) — the five/nine and six-dead-breakpoints gap is closed at the token layer. But no template reads any of them: four of seven still have no branching at all (§12 #10 lists three and misses `auth_template`). | DT §9.2-9.4 | all templates | L | #2, #10 |
| 17 | **Per-page layout specs absent** — zero `DataTable`, zero "Appearance" section, no right rail, no draggable sheet, no collapsed rail state. | DT §9.5 | templates | L | — |
| 18 | **Dark mode: real at the token layer, invisible everywhere a user would see it.** `ThemeExtension` classes, `context.colors`/`context.severity`, every dark value matching DT §10.4, `app.dart`'s `darkTheme`/`themeMode: ThemeMode.dark` — all built and verified correct. Every atom reads it. But 18 files above the atom layer (7 organisms, 4 molecules, all 7 templates) still read the light-only static alias directly, and since every screen composes down through templates → organisms → molecules → atoms, dark mode does not render on any actual page. Confirmed by rendering all four canvas-reviewed screens in both modes: the dark and light captures of Study Review are pixel-identical. Two defects also found and fixed in the token layer itself while verifying this: the dark elevation ladder was missing its 4th step (`surfaceOverlay`, `#232C38` — §10.4's ladder needs four, only three existed), and `buildAppTheme`'s `onError` resolved to a light-toned color against a light-toned dark-mode error fill (1.66:1; now 9.07:1 via `surfacePage`). | DL §6 | 18 files: organisms `app_nav_bar`, `chat_panel`, `conversation_drawer`, `findings_panel`, `onboarding_carousel`, `status_bar`, `study_info_card`; molecules `finding_row`, `metadata_field`, `severity_chip`, `status_banner`; all 7 templates | L | #1 |
| 19 | **Heatmap overlay built from status colours**, which are ARGB-identical to the severity foregrounds — so it violates both clauses of D-004 at once. No perceptual ramp token exists to migrate to — and, checked directly, still doesn't: the reconciliation's own step plan below claimed `DiagnosticImageTokens` as a Step-1 deliverable, but it was never actually built. Nothing about this row has changed. | DL §3.7, D-004 | `heatmap_viewer_template.dart:70-79` | M | #5 |
| 20 | **Text-scale hazards, two of three sites remain.** `AppAvatar` now wraps its initials in `FittedBox` + padding and survives 200% scale — closed. Still open: a fixed-width drawer combined with single-line clamps (the pattern DT §3.7 names explicitly), and fixed-ratio grid cells that cannot reflow. | DT §3.7 | `conversation_drawer.dart:46,154-167`; `case_list_template.dart:65-70` | M | — |

## Low clinical risk

| # | Gap | Rule | Where | Effort | §12 |
|---|---|---|---|---|---|
| 21 | Chat messages use `bodyMd`, one step below the specified `bodyLg`. | DT §3.2 | `chat_bubble.dart:48` | S | — |
| 22 | `AppElevation.overlay` applied to resting content, and the auth card caps at 360 rather than `formMaxWidth` 400. | DT §6, §9.5 | `auth_template.dart:22,28` | S | — |
| 23 | **Cursor tokens now consumed; hover color still entirely dead.** `AppButton` wires `mouseForbidden`/`mousePointer` through its `ButtonStyle.mouseCursor` — a real, narrower mechanism than the hover-overlay one this row describes. `MouseRegion` itself is still unused everywhere, and `hoverOverlayOpacity`, `NavigationTokens.sideNavHoverColor`, and the rest of the hover-color tokens remain dead. | DT §12 | whole app (hover color); button cursor wiring is the one exception | M | #6 |
| 25 | `panelMaxWidth` (a width) used as a height; `drawerWidth` is dead while 280 is hardcoded at the call site. | DT §9.3 | `chat_template.dart:77`; `conversation_drawer.dart:46` | S | — |
| 26 | Organism test coverage is 2 of 8, and no test enforces any design rule except typography. | AGENTS.md | `test/ui/organisms/` | M | #9 |

---

## Found during dark-mode verification, not yet diagnosed

Not root-caused, so not forced into the numbered format above — logged as observed, per the decision to track rather than chase it now.

**`FindingsPanel` produces a visible Flutter overflow warning when rendered with an empty findings list.** Rendering `StudyReviewPage` (which constructs `FindingsPanel(findings: [])`) at 1440×900 shows the classic yellow/black overflow stripe inside the panel. Found while screenshotting real pages to verify the dark-mode reconciliation above — unrelated to that work; looks pre-existing. Whether this is reachable in the real app (does a study ever actually have zero findings, and if so does something upstream avoid this exact construction?) is unknown. Tracked in `design_tokens.md` §12 gap 15.

---

## Two violations are pinned by passing tests

These assert the wrong behaviour as correct, so remediation means changing tests, not only widgets. (A third used to be here — `severity_dot_test.dart:74` asserting `BoxShape.circle` — but that test was rewritten alongside the widget; it now asserts a distinct icon per level and a uniqueness check across all four, closing gap 4.)

| Test | Asserts | Blocks gap |
|---|---|---|
| `heatmap_viewer_template_test.dart:91,139` | canvas is `AppColors.surfaceBrand` | 6 |
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
| ~~Add `DiagnosticImageTokens` — canvas ground and a perceptual heatmap ramp~~ | 19a | S | **Not done** — no such class exists, verified directly |
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

Closes **1, 2, 3, 7, 12, 15, 21**, part of **18, 20**. The largest clinical-risk reduction of any step.

| Work | Gap | Effort |
|---|---|---|
| `MetadataField` gains a value-kind API — identifiers render in `mono`, measurements and dates in `numeric`, neither truncates | 1, 2 | M |
| Severity labels move off 10px `labelSm` to a size at or above the clinical floor | 3 | S |
| `FindingRow` — either a real expand or a tooltip carrying the full description | 7 | S |
| `ChatBubble` reads `LayoutBuilder` constraints, not the window | 12 | S |
| `ChatBubble` message text moves to `bodyLg` | 21 | S |
| Density correction — the composer becomes generous, scanning rows become dense | 15 | M |
| `ConversationDrawer` tiles drop the fixed-width-plus-clamp pattern | 20b | M |

## Step 4 — Organisms

Closes **5, 9, 26**.

| Work | Gap | Effort |
|---|---|---|
| `FindingsPanel` aggregates Layer-5 — one alarm per viewport, with `normal` and `mild` demoted out of alarm treatment | 5 | M |
| `OnboardingCarousel` survives 200% scale — the fixed 240px image needs a scroll context | 9 | S |
| Organism test coverage from 2 of 8 to 8 of 8 | 26 | M |

## Step 5 — Templates and pages

Closes **6, 13, 16, 17, 22, 25**, finishes **18, 19, 20**. Your overhaul — one pass, not two.

| Work | Gap | Effort |
|---|---|---|
| Responsive tiers and pane-composition minimums across all seven templates; the four with no branching gain it | 16 | L |
| Per-page specs: the Case List worklist table, the Settings Appearance section, the heatmap right rail, the draggable findings sheet, the collapsed nav rail | 17 | L |
| Diagnostic canvas becomes a forced-dark subtree using `DiagnosticImageTokens`, exempt from theme mode | 6 | M |
| The 168px column dies with the pane minimums | 13 | M |
| Heatmap overlay switches to the perceptual ramp | 19b | S |
| `AuthTemplate` drops the resting-content shadow and caps at `formMaxWidth` | 22 | S |
| `panelMaxWidth` stops being used as a height | 25 | S |
| Delete the deprecated static token aliases | 18 | S |

**Tests to change:** `heatmap_viewer_template_test.dart:91,139` and `auth_template_test.dart:60` both assert the current violations as correct.

## Sequencing notes

- **Steps 2, 3 and 4 are independently shippable** once step 1 lands — each leaves the app working. Step 5 depends on 3 (templates consume the corrected molecules).
- **Step 1 is the only step that cannot be partially delivered.** The extension classes and the deprecated aliases must land together or the repo stops compiling.
- **The theme toggle** (Settings Appearance section) is in step 5, but dark mode is usable from step 1 for anyone flipping `themeMode` manually — useful for reviewing each step's work in both modes.
- **Verification per step:** `flutter analyze`, `flutter test`, and a rendered screenshot in both brightnesses. A step is not done while any of the three is outstanding.
- **Close the register as you go.** Delete each row here and its matching `design_tokens.md` §12 entry in the same commit as the fix, so the two never drift.
