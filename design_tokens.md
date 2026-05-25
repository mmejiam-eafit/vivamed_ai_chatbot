# Design Tokens — Radiologist Helper Chatbot

This document is the single source of truth for visual styling in the Flutter app. Every widget you create, modify, or refactor **must** use the tokens defined in `design_tokens.dart`. Never hard-code colors, font sizes, spacing values, or shadow definitions inline.

## File location

```
lib/ui/core/design_tokens.dart
```

Import it as:

```dart
import 'package:radiologist_helper/ui/core/design_tokens.dart';
```

---

## Token classes at a glance

| Class | Purpose |
|---|---|
| `AppColors` | Semantic color tokens organized by purpose: surfaces, text, icons, borders, interactive, status, brand |
| `AppSpacing` | Consistent padding, margin, and gap values |
| `AppRadius` | Corner radii named by component role, with pre-built `BorderRadius` objects |
| `AppElevation` | Box shadow presets named by surface role (card, raised, overlay, modal) |
| `AppTypography` | Text styles with font family, size, weight, height, and letter-spacing |
| `ChatTokens` | Colors, radii, and layout constants specific to the chat interface |
| `NavigationTokens` | AppBar, drawer, and bottom navigation bar colors |
| `SeverityTokens` | Foreground + background pairs for radiology finding severity badges |
| `AppMotion` | Animation durations (by interaction type) and curves (by motion intent) |
| `buildAppTheme()` | Pre-wired `ThemeData` — pass to `MaterialApp(theme:)` |

Raw hex values are stored in `_Palette`, a library-private class. Never reference `_Palette` in widget code — always go through the semantic `AppColors` layer.

---

## Color system

### Architecture

The color system has two layers. `_Palette` holds raw hex values organized by color family — this is the internal foundation and is never used directly in widgets. `AppColors` sits on top and exposes every color by **purpose**, organized into six semantic categories: surfaces, text, icons, borders, interactive, and status.

When you need a color, ask "what is this color FOR?" and find the matching token name. Never ask "what color do I want?" and scan for a hex value.

### Surfaces

Background and fill colors for containers, pages, and panels.

| Token | When to use |
|---|---|
| `AppColors.surfacePage` | Main scaffold / page background |
| `AppColors.surface` | Default card, dialog, and input fill |
| `AppColors.surfaceSubdued` | Subtle alternate: striped rows, hover fills, empty states |
| `AppColors.surfaceBrand` | Primary brand dark surface: hero sections, headers |
| `AppColors.surfaceBrandSecondary` | Secondary brand dark surface: drawer panels, section accents |
| `AppColors.surfaceAccent` | Accent-tinted light surface: selected items, highlighted rows, chips |
| `AppColors.surfaceBrandSubdued` | Primary brand-tinted light surface: selected primary items, info banners |
| `AppColors.surfaceBrandSecondarySubdued` | Secondary brand-tinted light surface: secondary selections |

### Text

Foreground colors for readable text. Each token describes the text's role, not its visual weight.

| Token | When to use |
|---|---|
| `AppColors.textPrimary` | Primary body text on light surfaces |
| `AppColors.textSecondary` | Subtitles, descriptions, less-prominent copy |
| `AppColors.textTertiary` | Helper text, supplementary labels |
| `AppColors.textPlaceholder` | Placeholder text inside input fields |
| `AppColors.textDisabled` | Inactive labels, unavailable options |
| `AppColors.textMuted` | Timestamps, fine print, low-priority metadata |
| `AppColors.textOnBrand` | Text on brand-dark surfaces (`surfaceBrand`, `surfaceBrandSecondary`) |
| `AppColors.textOnAccent` | Text inside accent-tinted surfaces (`surfaceAccent`) |
| `AppColors.textOnBrandSubdued` | Text inside primary brand-tinted surfaces (`surfaceBrandSubdued`) |
| `AppColors.textOnBrandSecondarySubdued` | Text inside secondary brand-tinted surfaces |
| `AppColors.textLink` | Link text and inline interactive text |

### Icons

| Token | When to use |
|---|---|
| `AppColors.icon` | Default icon tint on light surfaces |
| `AppColors.iconOnBrand` | Icon tint on brand-dark surfaces |
| `AppColors.iconAccent` | Active states, selected tabs |
| `AppColors.iconDisabled` | Disabled, unavailable icons |

### Borders

| Token | When to use |
|---|---|
| `AppColors.border` | Default border: cards, containers, sections |
| `AppColors.borderSubdued` | Subtle separators, inner dividers |
| `AppColors.borderFocused` | Focused input fields |
| `AppColors.borderSelected` | Selected items, active outlines |

### Interactive

Colors for actionable elements: buttons, toggles, links.

| Token | When to use |
|---|---|
| `AppColors.interactivePrimary` | Primary action fill: main CTA buttons |
| `AppColors.interactivePrimaryForeground` | Text/icon on primary action fill |
| `AppColors.interactiveSecondary` | Secondary action fill: outlined / subdued buttons |
| `AppColors.interactiveSecondaryForeground` | Text/icon on secondary action fill |
| `AppColors.interactiveHover` | Hover/pressed tint for interactive elements |
| `AppColors.interactiveAccent` | Progress bars, sliders, active indicators |
| `AppColors.interactiveDisabled` | Disabled interactive element fill |
| `AppColors.interactiveDisabledForeground` | Text on disabled interactive elements |

### Status

App-level operational status. **NOT** for clinical severity — use `SeverityTokens` for that.

| Token pair | When to use |
|---|---|
| `AppColors.statusSuccess` / `statusSuccessSubdued` | Upload complete, study processed, positive confirmation |
| `AppColors.statusWarning` / `statusWarningSubdued` | Low-confidence AI result, connection issue, stale data |
| `AppColors.statusError` / `statusErrorSubdued` | Failed upload, invalid input, server error |
| `AppColors.statusInfo` / `statusInfoSubdued` | Informational banners, tips, non-actionable notices |

Pattern: use the subdued variant as the container background and the base as the text/icon color.

```dart
Container(
  color: AppColors.statusWarningSubdued,
  child: Text('Low confidence', style: TextStyle(color: AppColors.statusWarning)),
)
```

### Brand reference

For rare cases where the purpose is literally "show the brand color" — logo rendering, brand illustrations, marketing elements.

| Token | When to use |
|---|---|
| `AppColors.brandPrimary` | Prefer `surfaceBrand` for backgrounds |
| `AppColors.brandSecondary` | Prefer `surfaceBrandSecondary` for backgrounds |
| `AppColors.brandAccent` | Prefer `interactivePrimary` for buttons |
| `AppColors.brandLight` | Prefer `surfacePage` for scaffold backgrounds |

### Hard rules

1. **Never use `Colors.black` or `Colors.white`** from Flutter's material library. Use `AppColors.textPrimary` for dark text and `AppColors.surface` for white fills.
2. **Never use `Color(0xFF...)` inline and never add new colors to `design_tokens.dart`.** The palette is closed. If the exact color you want doesn't exist, find the token whose *semantic meaning* best matches your intent — don't try to guess by hex value. Ask yourself: "Is this a surface? Text? A border? A status indicator?" Then pick the token that answers that question. For example, a subtle highlighted row uses `AppColors.surfaceAccent`, not an invented hex.
3. **Never reference `_Palette` in widget code.** It is library-private and exists only as the foundation for `AppColors`.
4. **Never use `Theme.of(context).colorScheme` directly for one-off styling.** It's there for Material widgets that read it automatically. When you style custom widgets, reference `AppColors` or the domain-specific token class.

---

## Typography

### Font families

| Constant | Family | Use for |
|---|---|---|
| `AppTypography.fontFamilyDisplay` | Plus Jakarta Sans | Headings, display text, labels, buttons |
| `AppTypography.fontFamilyBody` | Source Sans 3 | Body copy, descriptions, form fields |
| `AppTypography.fontFamilyMono` | JetBrains Mono | DICOM metadata, technical IDs, code snippets |

### Type scale and when to use each level

| Style | Size | Use case |
|---|---|---|
| `displayLg` | 32 | App title on welcome/onboarding screens only |
| `displayMd` | 28 | Major section headers (e.g., "Case Review") |
| `displaySm` | 24 | Page titles in scrollable content |
| `headingLg` | 20 | Card titles, dialog titles |
| `headingMd` | 18 | Subsection headings inside cards |
| `headingSm` | 16 | List group headers, bold inline labels |
| `bodyLg` | 16 | Primary body text, chat messages |
| `bodyMd` | 14 | Secondary body text, descriptions |
| `bodySm` | 12 | Captions, metadata, footnotes |
| `caption` | 11 | Timestamps, fine print, attribution |
| `labelLg` | 14 | Button text, tab labels, nav items |
| `labelMd` | 12 | Chips, small buttons, tag text |
| `labelSm` | 10 | Badge counts, overline text |
| `mono` | 13 | DICOM tags, study UIDs, technical output |

### Applying color to text

Text styles in `AppTypography` do **not** include color. Apply color via `.copyWith()`:

```dart
Text(
  'Findings Summary',
  style: AppTypography.headingLg.copyWith(color: AppColors.textPrimary),
)
```

On dark backgrounds:

```dart
Text(
  'Radiologist Helper',
  style: AppTypography.displayMd.copyWith(color: AppColors.textOnBrand),
)
```

---

## Spacing

Use `AppSpacing` for all padding, margin, `SizedBox` gaps, and layout spacing. Never write a bare numeric literal for spacing.

| Token | Value | Guidance |
|---|---|---|
| `xxs` | 2 | Hairline gaps (icon-to-badge offset) |
| `xs` | 4 | Tight inline spacing (icon-to-label in a chip) |
| `sm` | 8 | Default gap between related elements in a row |
| `md` | 12 | Inner padding for compact containers (chips, small cards) |
| `lg` | 16 | Standard content padding, list item vertical padding |
| `xl` | 24 | Section spacing, card internal padding |
| `xxl` | 32 | Major section breaks within a scroll view |
| `xxxl` | 48 | Screen-level vertical padding, hero spacing |
| `huge` | 64 | Top/bottom padding on welcome or empty-state screens |

Example pattern:

```dart
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.xl,
  ),
  child: Column(
    spacing: AppSpacing.md, // Flutter 3.27+ Column.spacing
    children: [...],
  ),
)
```

---

## Border radius

`AppRadius` tokens are named by the **component role** that receives the radius, not by relative size.

| Token | Value | Use case |
|---|---|---|
| `inlineElement` / `borderInlineElement` | 4 | Table cells, inline code blocks, tiny tags |
| `button` / `borderButton` | 8 | Buttons, chips, small interactive controls |
| `card` / `borderCard` | 12 | Standard cards, containers, dialogs |
| `panel` / `borderPanel` | 16 | Large cards, image containers, panels |
| `sheet` / `borderSheet` | 24 | Bottom sheets, modals, large overlays |
| `input` / `borderInput` | 999 | Text inputs, search bars, fully rounded action buttons |

---

## Elevation / Shadows

`AppElevation` tokens are named by the **surface role** they apply to, not by relative size.

| Token | Use case |
|---|---|
| `flat` | Elements that rely on border or background for separation |
| `card` | Default elevated surface at rest: cards, list items |
| `raised` | Hovered or focused cards, floating action buttons, popovers |
| `overlay` | Dialogs, dropdown menus, tooltips |
| `modal` | Full-screen modal sheets, image viewers, top-level overlays |

```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.borderCard,
    boxShadow: AppElevation.card,
  ),
)
```

---

## Chat interface tokens

All chat UI must use `ChatTokens`. Do not mix in raw `AppColors` for chat-specific elements.

### Message bubbles

- **User messages**: `ChatTokens.userBubble` background, `ChatTokens.userBubbleText` text, `ChatTokens.bubbleRadiusUser` border radius (tail on bottom-right).
- **Assistant messages**: `ChatTokens.assistantBubble` background, `ChatTokens.assistantBubbleText` text, 1px `ChatTokens.assistantBubbleBorder` outline, `ChatTokens.bubbleRadiusAssistant` border radius (tail on top-left).
- Max width: `ChatTokens.bubbleMaxWidthFraction` (78% of screen width).

```dart
Container(
  constraints: BoxConstraints(
    maxWidth: MediaQuery.of(context).size.width * ChatTokens.bubbleMaxWidthFraction,
  ),
  decoration: BoxDecoration(
    color: isUser ? ChatTokens.userBubble : ChatTokens.assistantBubble,
    borderRadius: isUser ? ChatTokens.bubbleRadiusUser : ChatTokens.bubbleRadiusAssistant,
    border: isUser ? null : Border.all(color: ChatTokens.assistantBubbleBorder),
  ),
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  ),
  child: Text(
    message,
    style: AppTypography.bodyLg.copyWith(
      color: isUser ? ChatTokens.userBubbleText : ChatTokens.assistantBubbleText,
    ),
  ),
)
```

### Input field

The `buildAppTheme()` function already configures `InputDecorationTheme` with the chat input tokens (pill radius, focused accent border). If you build a custom input, read from `ChatTokens.input*` constants.

### Timestamps and indicators

- Timestamps below bubbles: `AppTypography.caption` + `ChatTokens.timestamp`.
- Typing indicator dots: `ChatTokens.typingIndicator`.

---

## Navigation tokens

| Token | Use |
|---|---|
| `NavigationTokens.appBarBackground` / `appBarForeground` | Already wired into `buildAppTheme()`. Use for custom app bars too. |
| `NavigationTokens.drawerBackground` / `drawerForeground` | Side drawer / conversation history panel. |
| `NavigationTokens.bottomNavBackground` | Bottom navigation bar fill. |
| `NavigationTokens.bottomNavSelected` / `bottomNavUnselected` | Icon + label colors for active/inactive tabs. |

---

## Severity tokens (radiology domain)

Use `SeverityTokens` when displaying clinical finding severity — typically in chips, badges, or inline indicators next to AI-generated findings. These are **separate** from `AppColors.status*` tokens, which are for app-level operational status.

| Level | Foreground | Background | When to use |
|---|---|---|---|
| Normal | `SeverityTokens.normal` | `SeverityTokens.normalBg` | No pathology detected, healthy findings |
| Mild | `SeverityTokens.mild` | `SeverityTokens.mildBg` | Minor observations, low clinical significance |
| Moderate | `SeverityTokens.moderate` | `SeverityTokens.moderateBg` | Findings requiring attention or follow-up |
| Critical | `SeverityTokens.critical` | `SeverityTokens.criticalBg` | Urgent findings, immediate action needed |

Pattern for a severity chip:

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
  decoration: BoxDecoration(
    color: SeverityTokens.moderateBg,
    borderRadius: AppRadius.borderButton,
  ),
  child: Text(
    'MODERATE',
    style: AppTypography.labelSm.copyWith(color: SeverityTokens.moderate),
  ),
)
```

---

## Motion

Use `AppMotion` for all animation durations and curves. Do not hard-code `Duration(milliseconds: 300)` or use `Curves.linear`.

### Durations (by interaction type)

| Token | Value | Use case |
|---|---|---|
| `AppMotion.microInteraction` | 150ms | Icon color change, checkbox toggle, ripple |
| `AppMotion.transition` | 250ms | Page fade, card expand, tab switch |
| `AppMotion.complexTransition` | 400ms | Bottom sheet slide, image viewer open |
| `AppMotion.reveal` | 600ms | Onboarding animations, first-launch reveals |

### Curves (by motion intent)

| Token | Value | Use case |
|---|---|---|
| `AppMotion.standard` | easeInOut | General-purpose balanced ease |
| `AppMotion.enter` | easeOut | Elements appearing on screen |
| `AppMotion.exit` | easeIn | Elements leaving the screen |
| `AppMotion.emphasis` | easeInOutCubicEmphasized | Hero transitions, dramatic reveals |

```dart
AnimatedContainer(
  duration: AppMotion.transition,
  curve: AppMotion.standard,
  // ...
)
```

---

## Using `buildAppTheme()`

Call it once at the root of the app:

```dart
MaterialApp(
  theme: buildAppTheme(),
  // ...
)
```

This pre-configures `ColorScheme`, `AppBarTheme`, `CardTheme`, `InputDecorationTheme`, and `ElevatedButtonTheme` from the tokens. Material widgets that read from `Theme.of(context)` will automatically pick up these values. You should still use the token classes directly for custom widgets, non-Material components, and any property not covered by `ThemeData`.

---

## Checklist for code review

Before submitting any UI code, verify:

1. No hex color literals (`Color(0xFF...)`) appear anywhere — not inline, not added to `design_tokens.dart`.
2. No references to `_Palette` in widget code — only `AppColors` and domain-specific token classes.
3. No bare numeric spacing values (`SizedBox(height: 16)`) — use `AppSpacing.*`.
4. No inline `BorderRadius.circular(...)` calls — use `AppRadius.border*`.
5. No inline `TextStyle(fontSize: ...)` definitions — use `AppTypography.*` and `.copyWith()`.
6. No `Duration(milliseconds: ...)` literals — use `AppMotion.*`.
7. Chat UI exclusively uses `ChatTokens`, not raw `AppColors`.
8. Clinical severity badges use `SeverityTokens`, not `AppColors.status*`.
9. Text on dark surfaces uses `textOnBrand` — never `Colors.white`.
10. Text on light surfaces uses `textPrimary` / `textSecondary` / `textTertiary` — never `Colors.black`.
11. No new colors have been introduced — if a needed color wasn't in `AppColors`, the closest semantic match was used instead.
