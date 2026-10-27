# Design System Integration — Tokens × Atomic Design

This document bridges `design_tokens.md` (what visual values to use) with `atomic_design.md` (where widgets live in the hierarchy). Read those two documents first — this one assumes familiarity with both and adds no new rules, only the mapping between them. For *why* a value is what it is, see [`design_language.md`](design_language.md).

**Standing rule: this document never restates a numeric value that lives in a token.** Name the token instead. Two hardcoded numbers here had already drifted out of sync with `AppLayout`; naming tokens is what stops that recurring.

---

## Which token classes are relevant at each atomic level

| Atomic level | Primary token classes | Notes |
|---|---|---|
| **Atoms** | `AppColors`, `AppTypography`, `AppRadius`, `AppSpacing` (internal padding only) | Atoms are where tokens are directly applied. Every atom should reference token constants — never raw values. |
| **Molecules** | `AppSpacing` (gaps between atoms), `AppElevation` (if the molecule has a container), `ChatTokens` (chat molecules only) | Molecules arrange atoms. Their token usage is mostly spacing and occasional container decoration. Individual atom styling is handled by the atoms themselves. |
| **Organisms** | `AppSpacing` (section-level padding), `AppElevation`, `AppMotion`, `NavigationTokens`, `SeverityTokens` | Organisms add section-level layout spacing, shadows for card-like containers, and animation timing. Domain-specific token classes (`SeverityTokens`, `NavigationTokens`) are consumed here. |
| **Templates** | `AppSpacing` (screen-level margins, zone padding), `AppColors` (scaffold background) | Templates handle structural spacing only. They set screen margins and zone gaps but never style individual elements. |
| **Pages** | None directly | Pages wire data and state. They do not apply tokens — all visual decisions have been made in the levels below. |

---

## Token application by widget

This table maps specific widgets from `atomic_design.md` to the token classes and specific tokens they should use. It is a reference for implementation, not an exhaustive list — use judgment guided by `design_tokens.md` for any element not listed.

### Atoms

| Widget | Tokens applied |
|---|---|
| `AppText` | `AppTypography.*` for style, color applied via `.copyWith()` using `AppColors.textPrimary` / `textSecondary` / `textTertiary` or contextual color passed by parent |
| `AppIcon` | `AppColors.icon` default tint, `AppColors.iconAccent` for active states, `AppColors.iconOnBrand` on dark surfaces |
| `AppButton` (primary) | `AppColors.interactivePrimary` background, `AppColors.interactivePrimaryForeground` foreground, `AppRadius.borderButton`, `AppTypography.labelLg` |
| `AppButton` (secondary) | `AppColors.interactiveSecondary` background, `AppColors.interactiveSecondaryForeground` foreground + border, `AppRadius.borderButton` |
| `AppButton` (ghost) | Transparent background, `AppColors.interactiveSecondaryForeground` foreground, no border |
| `AppTextField` | Reads from `buildAppTheme()` `InputDecorationTheme` automatically. Custom instances use `ChatTokens.input*` |
| `AppAvatar` | `AppColors.surfaceBrandSecondary` default background, `AppColors.textOnBrand` initials text |
| `AppBadge` | `AppColors.statusError` or `AppColors.interactivePrimary` background depending on context, `AppColors.interactivePrimaryForeground` text, `AppRadius.borderInput` |
| `AppChip` | `AppColors.surfaceAccent` fill, `AppColors.textOnAccent` text, `AppRadius.borderButton` |
| `SeverityDot` | `SeverityTokens.normal` / `mild` / `moderate` / `critical` — one of the four foreground colors |

### Molecules

| Widget | Tokens applied |
|---|---|
| `ChatBubble` (user) | `ChatTokens.userBubble`, `ChatTokens.userBubbleText`, `ChatTokens.bubbleRadiusUser`, internal padding `AppSpacing.lg` horizontal / `AppSpacing.md` vertical |
| `ChatBubble` (assistant) | `ChatTokens.assistantBubble`, `ChatTokens.assistantBubbleText`, `ChatTokens.assistantBubbleBorder`, `ChatTokens.bubbleRadiusAssistant` |
| `ChatInput` | `ChatTokens.input*` constants, `AppSpacing.sm` gap between field and send button |
| `SeverityChip` | `SeverityTokens.*Bg` background, `SeverityTokens.*` text, `AppRadius.borderButton`, `AppTypography.labelSm` |
| `FindingRow` | `AppSpacing.md` vertical padding, `AppTypography.bodyMd` for finding text, `AppColors.borderSubdued` bottom border |
| `StatusBanner` | `AppColors.statusSuccess` / `statusWarning` / `statusError` / `statusInfo` icon, matching `status*Subdued` background, `AppTypography.bodyMd`, `AppRadius.borderButton` |
| `TypingIndicator` | `ChatTokens.typingIndicator` dot color, `AppMotion.transition` animation duration |
| `ImageThumbnail` | `AppRadius.borderCard` clip, `AppElevation.card` shadow, `diagnosticCanvasGround` letterbox (`BoxFit.contain`, DL D-020), `AppColors.surfaceSubdued` loading placeholder |

### Organisms

| Widget | Tokens applied |
|---|---|
| `ChatMessageList` | `AppSpacing.sm` gap between bubbles, `AppSpacing.lg` horizontal padding, `AppTypography.caption` + `ChatTokens.timestamp` for date separators |
| `ChatPanel` | `AppColors.surfacePage` background, `AppSpacing.sm` gap between message list and input |
| `FindingsPanel` | `AppColors.surface` background, `AppElevation.card` or `AppColors.borderSubdued` border, `AppSpacing.lg` internal padding, `AppTypography.headingMd` section header |
| `StudyInfoCard` | `AppColors.surface` surface, `AppElevation.card`, `AppRadius.borderCard`, `AppSpacing.xl` padding, `AppTypography.headingLg` title, `AppTypography.mono` for study UID |
| `ConversationDrawer` | `NavigationTokens.drawerBackground`, `NavigationTokens.drawerForeground`, `AppSpacing.lg` item padding |
| `AppNavBar` | `NavigationTokens.bottomNav*` colors, `AppTypography.labelSm` labels |
| `StatusBar` | Full-width, no border radius, `AppSpacing.md` vertical padding |

### Templates

| Widget | Tokens applied |
|---|---|
| `ChatTemplate` | `AppColors.surfacePage` scaffold background, `AppSpacing.lg` zone padding on wide screens; side panel gated on `AppLayout.threePaneMinWidth` (see `design_tokens.md` §9) |
| `StudyReviewTemplate` | Same scaffold background, `AppSpacing.xl` between top and bottom zones |
| `SettingsTemplate` | `AppSpacing.lg` horizontal padding, `AppSpacing.xxl` between setting sections |
| `OnboardingTemplate` | No page-level padding (full-bleed), `AppSpacing.xl` bottom action area padding |
| `AuthTemplate` | Centered card with `AppElevation.overlay`, `AppRadius.borderPanel`, capped at `AppLayout.formMaxWidth` |

### Pages

Pages apply **no tokens directly**. They instantiate a template with populated organisms and handle state. If you find yourself writing a color or spacing constant in a page file, move that styling into the organism, molecule, or atom that owns the visual element.

---

## Common patterns

### Status-driven containers

When a container's visual treatment depends on a status (success, warning, error, info), always pair the subdued background (`AppColors.status*Subdued`) with the base foreground (`AppColors.status*`) for text and icons. This pattern is used identically whether the container is an atom (`AppBadge`), a molecule (`StatusBanner`), or part of an organism.

### Severity-driven elements

Radiology severity uses `SeverityTokens`, not `AppColors.status*`. These are separate systems: status colors are for **app-level operations** (did an upload succeed?), severity tokens are for **clinical findings** (how urgent is this observation?). Even when the colors look similar, always use the correct token class for the context.

### Dark-surface vs light-surface text

Any widget rendered on a dark surface (`surfaceBrand`, `surfaceBrandSecondary`) uses `AppColors.textOnBrand` for primary text. Any widget on a light surface (`surfacePage`, `surface`, `surfaceSubdued`) uses `AppColors.textPrimary` for primary text, `textSecondary` for secondary, `textTertiary` for tertiary. Widgets on accent-tinted surfaces (`surfaceAccent`) use `AppColors.textOnAccent`.

### Elevation progression through levels

Elevation increases as you move up the atomic hierarchy. Atoms are flat. Molecules rarely have shadows. Organisms use `AppElevation.card` for card-like containers. Templates use elevation only for overlays. This prevents shadow stacking — a card inside a panel inside a sheet should not accumulate three layers of shadow.

| Level | Typical max elevation |
|---|---|
| Atom | `flat` |
| Molecule | `flat` or `card` |
| Organism | `card` or `raised` |
| Template (overlays only) | `overlay` or `modal` |

---

## Checklist for code review

This checklist supplements the individual checklists in `design_tokens.md` and `atomic_design.md`. Run all three.

1. Every token usage in the widget matches the token class appropriate for its atomic level (see table above).
2. No page file contains direct token references.
3. `SeverityTokens` are used only for clinical findings; `AppColors.status*` are used only for app-level status.
4. Text on dark surfaces uses `textOnBrand`; text on light surfaces uses `textPrimary` / `textSecondary` / `textTertiary`; text on accent surfaces uses `textOnAccent`.
5. Elevation does not exceed the level's typical max (atoms `flat`, organisms `card`/`raised`, templates `overlay`/`modal` for overlays only).
6. `ChatTokens` are used exclusively within the chat feature's atoms, molecules, and organisms — not in study review, settings, or onboarding.
7. `NavigationTokens` are used exclusively within navigation organisms (`ConversationDrawer`, `AppNavBar`) and the `AppBar` configuration.
