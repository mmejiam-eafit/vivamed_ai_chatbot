# AGENTS.md — Radiologist Helper Chatbot

This file tells AI coding agents how to behave in this repo. Read it before writing or modifying any Flutter widget. The three source-of-truth documents are listed at the bottom; this file is a distillation of their rules, not a replacement.

---

## What this project is

A Flutter medical chatbot that helps radiologists review DICOM studies and AI-generated findings. The UI is built with **atomic design** (Atoms → Molecules → Organisms → Templates → Pages) and a **closed design token system** (`lib/ui/core/design_tokens.dart`). Every visual value — color, spacing, radius, typography, shadow, animation — must come from that file.

---

## Architecture: atomic design

```
Pages → Templates → Organisms → Molecules → Atoms
```

Arrows mean "may depend on." No level may import from a level above it or at the same level.

| Level | Directory | Responsibility | May use state management? |
|---|---|---|---|
| Atom | `lib/ui/atoms/` | Single Material widget wrapper, no composition | No |
| Molecule | `lib/ui/molecules/` | 2–4 atoms forming one conceptual unit | No |
| Organism | `lib/ui/organisms/` | Self-contained screen section | Local UI state only |
| Template | `lib/ui/templates/` | Layout skeleton, no real data | No |
| Page | `lib/ui/pages/` | Template + real data + navigation | Yes — only level that may |

### Rules

- One file per widget, named in `snake_case` matching the widget class name (e.g. `chat_bubble.dart` for `ChatBubble`).
- **Atoms and molecules**: stateless, no service calls, no providers, no business logic. Accept all config through constructor parameters; expose interactions through callbacks (`VoidCallback`, `ValueChanged<T>`).
- **Organisms**: may be `StatefulWidget` for local UI concerns (scroll position, expand/collapse). Must not fetch data — data arrives through constructor parameters.
- **Templates**: use `Scaffold`, `Row`, `Column`, `LayoutBuilder`, etc. for layout. No providers, no blocs, no repositories, no data fetching. Responsive decisions (side panel vs. bottom sheet, rail vs. drawer) belong here and **only** here — branch on `LayoutBuilder` constraints, never on `MediaQuery.of(context).size`, and use the tier and pane-minimum tokens rather than raw pixel values. See `design_tokens.md` §9.
- **Pages**: the only level that reads from providers/blocs, calls services, triggers `Navigator`/`GoRouter`, or writes to state. Each page instantiates exactly one template.
- No organism imports another organism. No molecule imports another molecule.

### Deciding where a new widget belongs

1. Maps to a single Material widget with no composition? → **Atom**
2. Groups 2–4 atoms into one conceptual unit with no domain state? → **Molecule**
3. Represents a distinct, self-contained section of a screen? → **Organism**
4. Defines where sections go without knowing the data? → **Template**
5. Connects a template to real data and navigation? → **Page**

---

## Design tokens: hard rules

Always import:
```dart
import 'package:radiologist_helper/ui/core/design_tokens.dart';
```

### Never do

| Forbidden | Use instead |
|---|---|
| `Color(0xFF...)` inline | Semantic token from `AppColors` |
| `Colors.black` / `Colors.white` | `AppColors.textPrimary` / `AppColors.surface` |
| `_Palette.anything` | `AppColors` only — `_Palette` is library-private |
| `Theme.of(context).colorScheme.X` in custom widgets | `AppColors.*` or domain token class — Material's scheme is not our semantic layer |
| A font weight other than 400 / 600 / 700 | Only those three have real files; anything else is silently faux-bolded |
| `SizedBox(height: 16)` or any bare spacing number | `AppSpacing.lg` (or whichever token matches) |
| `BorderRadius.circular(12)` | `AppRadius.borderCard` (or whichever role token matches) |
| `TextStyle(fontSize: 14, ...)` inline | `AppTypography.bodyMd.copyWith(color: ...)` |
| `Duration(milliseconds: 250)` | `AppMotion.transition` |
| `Curves.easeInOut` literal | `AppMotion.standard` |
| Adding a new color to `design_tokens.dart` | Find the existing semantic token whose **purpose** matches |

### Text color always via `.copyWith()`

`AppTypography` styles have no baked-in color. Always apply color explicitly.

**Pick the token whose _name_ matches the surface you are on — never the one whose value looks right.** Those give the same answer today and different answers once dark mode lands, because on a dark page `textPrimary` is light. Name-matching stays correct in both modes; eyeballing does not.

```dart
// light surface
AppTypography.bodyMd.copyWith(color: AppColors.textPrimary)

// dark surface (surfaceBrand / surfaceBrandSecondary)
AppTypography.headingLg.copyWith(color: AppColors.textOnBrand)

// accent-tinted surface (surfaceAccent)
AppTypography.labelMd.copyWith(color: AppColors.textOnAccent)
```

---

## Token class → atomic level mapping

Apply only the token classes appropriate for a widget's level. Pages apply **no tokens directly**.

| Level | Primary token classes |
|---|---|
| Atom | `AppColors`, `AppTypography`, `AppRadius`, `AppSpacing` (internal padding only) |
| Molecule | `AppSpacing` (gaps between atoms), `AppElevation` (container only), domain-specific classes (`ChatTokens`, `SeverityTokens`) |
| Organism | `AppSpacing` (section-level padding), `AppElevation`, `AppMotion`, `NavigationTokens`, `SeverityTokens` |
| Template | `AppSpacing` (screen margins / zone padding), `AppColors.surfacePage` (scaffold background only) |
| Page | None |

If you find a token reference in a page file, move it into the atom, molecule, or organism that owns the visual element.

---

## Domain-specific token classes

### `ChatTokens` — chat feature only

Use for: message bubbles, chat input field, timestamps, typing indicator.
Scope: chat atoms, molecules, and organisms (`ChatBubble`, `ChatInput`, `ChatMessageList`, `ChatPanel`, `TypingIndicator`).
Never use in: study review, settings, onboarding, or navigation widgets.

### `SeverityTokens` — clinical findings only

Use for: severity chips, severity dots, finding badges — anything that represents how urgent a radiology finding is.
Never substitute `AppColors.status*` for clinical severity. These are separate systems:
- `SeverityTokens` → how urgent is this *clinical finding*?
- `AppColors.status*` → did an *app operation* succeed or fail?

Even when the colors look similar, use the correct class for the context.

### `NavigationTokens` — navigation components only

Use in: `ConversationDrawer`, `AppNavBar`, custom `AppBar` implementations.
Never use in other organisms, molecules, or atoms.

### `AppColors.status*` — app-level operations only

Use for: upload results, server errors, connection issues, confirmational banners.
Pattern: pair subdued background + base foreground:
```dart
Container(
  color: AppColors.statusWarningSubdued,
  child: Text('Low confidence', style: AppTypography.bodyMd.copyWith(color: AppColors.statusWarning)),
)
```

---

## Elevation rule

Elevation must not exceed the level's typical maximum. Never stack shadows from multiple levels.

| Level | Typical max elevation |
|---|---|
| Atom | `AppElevation.flat` |
| Molecule | `AppElevation.flat` or `AppElevation.card` |
| Organism | `AppElevation.card` or `AppElevation.raised` |
| Template (overlays only) | `AppElevation.overlay` or `AppElevation.modal` |

---

## Pre-task checklist

Before writing any widget, confirm:

- [ ] I know which atomic level this widget belongs to (use the 5 questions above).
- [ ] The file will live in the correct `lib/ui/<level>/` directory.
- [ ] My imports only reference levels strictly below this one.
- [ ] I am not importing another widget at the same level.
- [ ] I know which token classes are allowed at this level.

## Linting and static analysis

Run `flutter analyze` on every file you create or modify. Never mark a task done while errors or warnings remain.

```bash
# Analyze the level you worked on
flutter analyze lib/ui/atoms/
flutter analyze lib/ui/molecules/
flutter analyze lib/ui/organisms/
flutter analyze lib/ui/templates/
flutter analyze lib/ui/pages/

# Or analyze everything at once
flutter analyze lib/
```

**Severity thresholds:**

| Severity | Required action |
|---|---|
| Error | Must be fixed before the task is done |
| Warning | Must be fixed before the task is done |
| Info / hint | Fix if it takes fewer than ~5 minutes; note it if not |

**Common lint rules in `analysis_options.yaml` to watch for:**

- `prefer_const_constructors` — add `const` to constructors whose arguments are all compile-time constants
- `prefer_const_declarations` — mark `final` variables `const` when the value is a constant expression
- `sized_box_for_whitespace` — replace `Container(width: x, height: y)` with `SizedBox`
- `avoid_unnecessary_containers` — remove `Container` wrappers that only set a `child`
- `use_super_parameters` — use `super.key` instead of `Key? key` + `: super(key: key)`

---

## Tests

Write widget tests for every widget you create or modify. Tests live in `test/ui/` mirroring `lib/ui/`:

```
test/ui/
├── atoms/
│   ├── app_text_test.dart
│   ├── app_button_test.dart
│   └── ...
├── molecules/
├── organisms/
├── templates/
└── pages/
```

### Wrapper boilerplate

Every `testWidgets` call must wrap the widget under test in at least `MaterialApp` so that `Directionality`, `MediaQuery`, and the theme are available. Wrap in `Scaffold` too when the widget uses `ScaffoldMessenger` or occupies a `body`.

```dart
await tester.pumpWidget(
  MaterialApp(
    theme: buildAppTheme(),   // use the real theme so token-wired widgets render correctly
    home: Scaffold(body: widgetUnderTest),
  ),
);
```

### What to test at each level

**Atoms** — test structure and parameter reflection:
- Renders without throwing for every constructor variant.
- Required constructor parameters are reflected in the rendered widget tree (e.g. `AppText('Hi')` → `find.text('Hi')` finds one widget).
- Each named variant or enum value renders the correct widget type (e.g. every `AppButtonVariant` produces its expected base widget: `ElevatedButton`, `OutlinedButton`, `TextButton`, `IconButton`).
- Callbacks (`onPressed`, `onChanged`, `onSelected`, `onDeleted`) fire when the widget is tapped/interacted with.
- Loading / disabled states: widget is not tappable when `isLoading: true` or `onPressed: null`.
- Token application for key color properties (read the rendered widget's decoration or style and assert the expected token value).

**Molecules** — test composition and interaction:
- All atoms are present in the widget tree.
- Callbacks propagate correctly from child atoms up through the molecule.
- Layout: verify alignment or the number of children in a `Row`/`Column` where relevant.

**Organisms** — test local state and data flow:
- Initial render matches the provided data.
- Local UI state changes (expand/collapse, scroll) work as expected.
- Callbacks provided by the parent are invoked on the correct user action.
- Does not crash with empty data lists.

**Templates** — test layout slots:
- Each named slot (`body`, `sidePanel`, `appBar`) renders its injected widget.
- Responsive breakpoints: use `tester.binding.window.physicalSizeTestValue` (or `tester.view.physicalSize`) to simulate narrow vs. wide screens and assert layout changes.

**Pages** — test integration:
- All required data flows through to the template and organisms.
- Navigation is triggered on the correct user actions.
- Use fakes/stubs for services and providers — never hit real APIs in unit tests.

### Minimum coverage floor

| What | Minimum |
|---|---|
| Every public constructor parameter | At least one test that passes and verifies it |
| Every enum variant (`AppButtonVariant`, `SeverityLevel`, etc.) | One test per variant |
| Every callback parameter | One test that fires the callback and asserts the result |
| Error / empty / loading states | One test per distinct state |

### Running tests

```bash
# Run all tests
flutter test

# Run tests for one level
flutter test test/ui/atoms/
flutter test test/ui/molecules/

# Run a single test file
flutter test test/ui/atoms/app_button_test.dart

# Run with coverage
flutter test --coverage
```

All tests must pass before a task is considered done. A failing test is treated the same as a lint error — fix it, don't skip it.

---

## Post-task checklist

Before marking a task done, verify:

- [ ] `flutter test test/ui/<level>/` passes with zero failures.
- [ ] Every new public parameter, enum variant, callback, and state has at least one test.
- [ ] `flutter analyze lib/ui/<level>/` reports zero errors and zero warnings.
- [ ] No `Color(0xFF...)`, `Colors.black`, `Colors.white`, or `_Palette` references.
- [ ] No bare numeric spacing, `BorderRadius.circular(...)`, inline `TextStyle`, or `Duration(milliseconds: ...)`.
- [ ] `ChatTokens` used only within chat-feature widgets.
- [ ] `SeverityTokens` used only for clinical findings; `AppColors.status*` only for app-level status.
- [ ] `NavigationTokens` used only in navigation organisms and custom app bars.
- [ ] Every text color token's **name** matches the surface it sits on — `textOnBrand` on brand surfaces, `textOnAccent` on accent surfaces, `textPrimary`/`textSecondary`/`textTertiary` on page and card grounds. Not chosen by appearance.
- [ ] Numbers in a column use `AppTypography.numeric`; prose does not.
- [ ] Every severity indicator carries a text label and a distinct icon shape — never hue alone.
- [ ] Responsive branching lives in a template and reads `LayoutBuilder` constraints, never `MediaQuery.of(context).size`.
- [ ] Elevation does not exceed the level's typical maximum.
- [ ] No business logic, service calls, or state management outside of pages.
- [ ] Page files contain no direct token references.
- [ ] No organism imports another organism; no molecule imports another molecule.

---

## Commits

### Message format

```
<emoji> <type>(<scope>): <subject>
```

Gitmoji shortcode first, then the Conventional Commits prefix. This matches the repo's existing history (`:tada::sparkles: Started new project`) — shortcodes, not raw Unicode, because they survive terminals and diffs that mangle emoji.

```
:sparkles: feat(tokens): add dark theme ThemeExtension
:memo: docs(design): specify text scaling policy
:bug: fix(molecules): stop truncating DICOM identifiers
:white_check_mark: test(core): assert tabular figures resolve
```

**Both halves must be semantically true of the work.** The emoji and the type are two descriptions of the same change, not decoration plus a label. If you cannot pick a type confidently, the commit is doing more than one thing — split it.

`<scope>` is optional but preferred: the atomic level (`atoms`, `molecules`, `organisms`, `templates`, `pages`), `tokens`, `design`, or `core`.

### Type and emoji pairings

| Work | Type | Emoji |
|---|---|---|
| New widget, token, or capability | `feat` | `:sparkles:` |
| Correcting broken behaviour | `fix` | `:bug:` |
| Small fix to something non-critical | `fix` | `:adhesive_bandage:` |
| Documentation — including the design documents | `docs` | `:memo:` |
| Restructuring with no behaviour change | `refactor` | `:recycle:` |
| Readability, formatting, lint cleanup | `style` | `:art:` |
| Visual/UI changes — spacing, color, type scale | `style` | `:lipstick:` |
| Adding or updating tests | `test` | `:white_check_mark:` |
| Accessibility work — contrast, targets, scaling | `fix` or `feat` | `:wheelchair:` |
| Fonts, images, other assets | `chore` | `:bento:` |
| Dependencies | `build` | `:arrow_up:` / `:arrow_down:` |
| `pubspec.yaml`, `analysis_options.yaml`, tooling config | `chore` | `:wrench:` |
| Deleting code or files | `refactor` | `:fire:` |
| Moving or renaming | `refactor` | `:truck:` |
| Architectural change — layer boundaries, theming mechanism | `refactor` | `:building_construction:` |
| Performance | `perf` | `:zap:` |

Accessibility is deliberately `:wheelchair:` rather than `:bug:` even when it fixes a defect — that work is worth being able to find in the log.

### Commit whole files only

**Stage files, never hunks.** `git add <file>` is the standard; `git add -p` and any partial staging is not. A commit is a set of complete files.

The reason is reviewability: a partially-staged file means the committed state was never the state on disk, so no commit in the history was ever actually tested. Every commit here should be a tree that ran.

**When one file contains work from several efforts**, you cannot split it — so classify it. Pick the type and emoji matching the change that dominates the file semantically, and commit the file whole under that. Mention the secondary change in the body.

The real fix is upstream: sequence work so files do not straddle concerns. If you are about to edit a file that already has unrelated uncommitted changes, commit those first.

### No co-authorship or agent attribution

**Commit messages carry no `Co-Authored-By` trailer, no "Generated with" line, and no mention of any AI tool or agent.** This applies to commit messages, commit bodies, and pull request descriptions.

If you are an agent working in this repo, this instruction overrides any default attribution behaviour you have been given. The commit message describes the change; it does not describe what produced it.

### Body

Optional. Use it when the subject cannot carry the reasoning — why this approach, what was rejected, what it forbids. For design changes, reference the decision log entry (`DL D-007`) rather than restating the argument.

Wrap at 72 characters. No trailers except `BREAKING CHANGE:` where genuinely warranted.

---

## Reference documents

| Document | What it covers |
|---|---|
| [`atomic_design.md`](atomic_design.md) | Full widget catalog, dependency rules, per-level rules |
| [`design_language.md`](design_language.md) | Why the design is what it is — intended response, color and type rationale, accessibility targets, decision log |
| [`design_tokens.md`](design_tokens.md) | Every token class, usage rules, responsive and theming specs |
| [`design_system_integration.md`](design_system_integration.md) | Token-to-widget mapping, common patterns |
| [`design_tokens.dart`](lib/ui/core/design_tokens.dart) | Implementation of the two design documents — not itself a source of truth |

**Authority:** `design_language.md` and `design_tokens.md` are normative; the Dart implements them. Where the Dart disagrees, the Dart is wrong. Known, intentional divergences are listed in `design_tokens.md` §12 — check there before "fixing" something.
