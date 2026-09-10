# Design Tokens — Radiologist Helper

The technical reference for the design system: every token class, what it is for, and how to apply it.

## Authority

This document is **normative**. [`lib/ui/core/design_tokens.dart`](lib/ui/core/design_tokens.dart) implements it. Where the two disagree, the Dart is wrong.

The reasoning behind these values lives in [`design_language.md`](design_language.md). This document says *what*; that one says *why*. Sections here reference it as **DL §n** — follow those links before changing a value, because most of these numbers are load-bearing for a stated principle.

To change a design decision: amend `design_language.md`, then this document, then the Dart.

**Reading paths.** Adding a widget → §2 through §8. Questioning a value → `design_language.md`. Making something responsive → §9. Looking for what is broken → §12.

## Import

```dart
import 'package:radiologist_helper/ui/core/design_tokens.dart';
```

---

## 1. Token classes at a glance

| Class | Purpose | Mode-dependent? |
|---|---|---|
| `AppColors` | Semantic colors by purpose: surfaces, text, icons, borders, interactive, status, brand | Yes — values in §10.4 |
| `AppTypography` | Text styles, font families, OpenType feature sets | No |
| `AppSpacing` | Padding, margin, gap values | No |
| `AppRadius` | Corner radii by component role, plus pre-built `BorderRadius` | No |
| `AppElevation` | Shadow presets by surface role | Geometry no; rendering yes — the dark ladder is in §10.4 |
| `AppIconSize` | Icon size scale | No |
| `AppMotion` | Durations by interaction type, curves by intent | No |
| `AppLayout` | Breakpoints and content constraints | No |
| `AppInteraction` | Hover/focus/press opacities, focus ring, cursors | Partly |
| `AppScrollbar` | Scrollbar geometry and colors | Yes — derives from §10.4 |
| `ChatTokens` | Chat-specific colors, radii, layout | Yes — derives from §10.4 |
| `NavigationTokens` | App bar, drawer, side nav, bottom nav | Yes — derives from §10.4 |
| `SeverityTokens` | Clinical finding severity pairs | Yes — values in §10.4 |
| `TooltipTokens` | Tooltip surface and text | Yes — derives from §10.4 |
| `DiagnosticImageTokens` | Ground behind and around diagnostic pixel data | **No — mode-exempt by rule** (§2.10) |
| `buildAppTheme()` | Pre-wired `ThemeData` for `MaterialApp` | — |

Raw hex values live in `_Palette`, which is library-private. **Never reference `_Palette` in widget code** — always go through the semantic layer.

Classes marked mode-dependent take their dark values from §10.4, which is **official** — ratified, computed, verified, not a proposal, and wired into the `ThemeExtension` mechanism (`AppColorsData`, `SeverityData`) that every atom now reads via `context.colors`/`context.severity`. The `static const` forms stay as `@Deprecated` aliases for call sites that haven't migrated — most of the codebase above the atom layer, still (§12, gap 1).

---

## 2. Color

### 2.1 How to choose a token

Ask **"what is this color FOR?"** and find the token whose name answers. Never ask "what color do I want?" and scan for a hex value.

The palette is closed (**DL §3.3**). If the exact color you want does not exist, the correct move is to find the token whose *purpose* matches your intent — not to add one.

### 2.2 Surfaces

| Token | Use for |
|---|---|
| `surfacePage` | Scaffold / page background |
| `surface` | Default card, dialog, input fill |
| `surfaceSubdued` | Striped rows, hover fills, empty states |
| `surfaceBrand` | Primary brand dark surface: hero sections, headers |
| `surfaceBrandSecondary` | Secondary brand dark surface: drawers, section accents |
| `surfaceAccent` | Accent-tinted light surface: selected items, highlighted rows |
| `surfaceBrandSubdued` | Primary brand-tinted light surface: selected items, info banners |
| `surfaceBrandSecondarySubdued` | Secondary brand-tinted light surface |

The page is intentionally darker than a card, so cards read as raised without a border (**DL §3.4**).

### 2.3 Text

Each token names the text's **role**, not its appearance.

| Token | Use for |
|---|---|
| `textPrimary` | Body text on light surfaces |
| `textSecondary` | Subtitles, descriptions |
| `textTertiary` | Helper text, supplementary labels — **AA but not AAA, so not for clinical strings** (DL §8.2) |
| `textPlaceholder` | Input placeholders |
| `textDisabled` | Inactive labels |
| `textMuted` | Timestamps, fine print |
| `textOnBrand` | Text on `surfaceBrand` / `surfaceBrandSecondary` |
| `textOnAccent` | Text on `surfaceAccent` |
| `textOnBrandSubdued` | Text on `surfaceBrandSubdued` |
| `textOnBrandSecondarySubdued` | Text on `surfaceBrandSecondarySubdued` |
| `textLink` / `textLinkHover` / `textLinkVisited` | Inline interactive text |

**The pairing rule:** use the text token whose **name** matches the surface you are on. Never pick by how the value looks — that reasoning breaks the moment dark mode lands, because the token that "looks right" on a light page is the wrong one on a dark page while the *name* stays correct in both.

### 2.4 Icons, borders, interactive

| Group | Tokens |
|---|---|
| Icons | `icon`, `iconOnBrand`, `iconAccent`, `iconDisabled` |
| Borders | `border`, `borderSubdued`, `borderFocused`, `borderSelected` |
| Interactive | `interactivePrimary` / `…Foreground`, `interactiveSecondary` / `…Foreground`, `interactiveHover`, `interactiveAccent`, `interactiveDisabled` / `…Foreground` |

### 2.5 Status — app operations only

**Not** for clinical severity (**DL §3.5**). Pair the subdued variant as container with the base as foreground.

| Pair | Use for |
|---|---|
| `statusSuccess` / `statusSuccessSubdued` | Upload complete, study processed |
| `statusWarning` / `statusWarningSubdued` | Low-confidence result, connection issue, stale data |
| `statusError` / `statusErrorSubdued` | Failed upload, invalid input, server error |
| `statusInfo` / `statusInfoSubdued` | Informational banners, non-actionable notices |

### 2.6 Severity — clinical findings only

A separate system from status, and the separation is deliberate even where hues coincide (**DL §3.5**).

| Level | Tokens | Meaning |
|---|---|---|
| Normal | `normal` / `normalBg` | No pathology detected |
| Mild | `mild` / `mildBg` | Minor observation, low significance |
| Moderate | `moderate` / `moderateBg` | Requires attention or follow-up |
| Critical | `critical` / `criticalBg` | Urgent, immediate action |

**Never hue alone (DL §3.6).** A severity indicator must carry a text label *and* a distinct icon shape. A bare dot as sole carrier is a defect.

### 2.7 Brand reference

`brandPrimary`, `brandSecondary`, `brandAccent`, `brandLight` exist for cases where the purpose is literally "render the brand" — a logo or brand illustration. For anything else prefer the semantic surface or interactive token. These four do **not** change with theme mode.

| Token | Value |
|---|---|
| `brandPrimary` | `#0C2B4E` |
| `brandSecondary` | `#1A3D64` |
| `brandAccent` | `#1D546C` |
| `brandLight` | `#F4F4F4` |

**Not every pair of these four passes contrast against each other** — they were tuned as accents on light surfaces, not as a palette meant to combine freely. `brandAccent`/`brandSecondary` on `brandPrimary` measure 1.72:1 / 1.29:1, both well under any floor; only `brandLight` clears `brandPrimary` (12.98:1). A logo needing a dark ground goes monochrome (`brandLight` on `brandPrimary`) rather than reaching for a fifth color — see `assets/brand/README.md` and DL D-015 for the derivation, and `AppLogo` (`lib/ui/atoms/app_logo.dart`) for the shipped mark.

### 2.8 Light values

Normative — companion to §10.4's dark values, same discipline: every ratio below is computed, never estimated. §2.2–§2.7 give purpose; this section resolves each token to hex against the grounds that matter, so light mode stops being the one half of this document that names tokens without settling what they resolve to.

**Surfaces** (§2.2):

| Token | Value |
|---|---|
| `surfacePage` | `#F4F4F4` |
| `surface` | `#FFFFFF` |
| `surfaceSubdued` | `#EEEEEE` |
| `surfaceBrand` | `#0C2B4E` |
| `surfaceBrandSecondary` | `#1A3D64` |
| `surfaceAccent` | `#E9F3F7` |
| `surfaceBrandSubdued` | `#ECF0F5` |
| `surfaceBrandSecondarySubdued` | `#EDF1F7` |

**Text ramp** (§2.3) — ratio on page → surface:

| Token | Value | Ratio |
|---|---|---|
| `textPrimary` | `#1A1A1A` | 15.82 · 17.40 |
| `textSecondary` | `#4A4A4A` | 8.06 · 8.86 |
| `textTertiary` | `#636363` | 5.46 · 6.01 — AA only, not clinical strings |
| `textMuted` | `#6E6E6E` | 4.64 on page · 5.10 on surface — remediated per DL §8.7, D-014 (was `#7D7D7D`, 3.74 · 4.12, failing AA) |
| `textPlaceholder` / `textDisabled` | `#A0A0A0` | 2.38 · 2.61 — WCAG exempts inactive/placeholder text from the 4.5:1 floor, so this is by design, not a defect |

Text-on-tinted-surface pairs, each checked against its own surface:

| Token | Value | Ratio |
|---|---|---|
| `textOnBrand` | `#F4F4F4` | 12.98 on `surfaceBrand` · 10.07 on `surfaceBrandSecondary` |
| `textOnAccent` | `#0F3545` | 11.53 on `surfaceAccent` |
| `textOnBrandSubdued` | `#061625` | 15.97 on `surfaceBrandSubdued` |
| `textOnBrandSecondarySubdued` | `#0F2640` | 13.51 on `surfaceBrandSecondarySubdued` |
| `textLink` | `#267390` | 4.85 on page · 5.33 on surface |
| `textLinkHover` | `#275F75` | 6.41 on page · 7.05 on surface — its own value now, no longer sharing `#3D95B8` with `borderFocused` / `interactiveAccent` (which stay put, unaffected). Was `#3D95B8`, 3.08 · 3.39, failing the 4.5:1 text floor — found while compiling this table, not previously in DL §8.7's audit. |
| `textLinkVisited` | `#0F3545` | 11.82 on page · 13.00 on surface |

**Icons** (§2.4) reuse hexes already in the ramp above — no separate palette:

| Token | Value | Same as |
|---|---|---|
| `icon` | `#636363` | `textTertiary` |
| `iconOnBrand` | `#F4F4F4` | `textOnBrand` |
| `iconAccent` | `#1D546C` | `borderSelected` / `interactivePrimary` |
| `iconDisabled` | `#A0A0A0` | `textPlaceholder` |

**Borders** (§2.4) — meaningful borders need 3:1; decorative ones don't:

| Token | Value | Ratio | Note |
|---|---|---|---|
| `border` | `#7D7D7D` | 3.74 on page · 4.12 on surface | **Meaningful borders only** — reuses `gray500`; matches dark mode's role for the same token (D-016) |
| `borderSubdued` | `#DCDCDC` | 1.25 · 1.37 | Decorative, no floor |
| `borderFocused` | `#3D95B8` | 3.08 on page · 3.39 on surface | Clears 3:1 — fine as a border at this value. `textLinkHover` used to share this hex and fail as text; it now has its own separate value instead, so `borderFocused` is unaffected. |
| `borderSelected` | `#1D546C` | 7.53 · 8.28 | Clears with margin |

**Interactive** (§2.4):

| Token | Value | Ratio |
|---|---|---|
| `interactivePrimary` | `#1D546C` | fill — see `interactivePrimaryForeground` |
| `interactivePrimaryForeground` | `#F4F4F4` | 7.53 on `interactivePrimary` |
| `interactiveSecondary` | `#FFFFFF` | fill — see `interactiveSecondaryForeground` |
| `interactiveSecondaryForeground` | `#1D546C` | 8.28 on `interactiveSecondary` |
| `interactiveHover` | `#267390` | same value as `textLink` |
| `interactiveAccent` | `#3D95B8` | same value as `borderFocused`. `textLinkHover` used to share it too; it now has its own value instead (above). |
| `interactiveDisabled` | `#DCDCDC` | WCAG-exempt (disabled control) |
| `interactiveDisabledForeground` | `#7D7D7D` | WCAG-exempt (disabled control) |

**Status and severity** (§2.5, §2.6) — remediated and wired into `_Palette`:

**Correction:** an earlier version of this table showed one combined "Info / Mild" row, using only `SeverityTokens.mild`'s hex. They're different colors in the Dart — `statusInfo` is `_Palette.tealBlue750` (the brand accent family, distinct from `borderFocused`/`interactiveAccent`'s `tealBlue400`), `SeverityTokens.mild` is `_Palette.blue700`, unrelated. Deriving real remediation colors forced the distinction back into view; both get their own row below.

| Level | Color | On container | Vs page | Was (failing) |
|---|---|---|---|---|
| Success / Normal | `#276A43` | 5.43 ✓ | 5.91 ✓ | `#2E7D4F` — 4.21 on container |
| Mild severity | `#02639E` | 5.38 ✓ | 5.82 ✓ | `#0277BD` — 4.03 on container |
| Warning / Moderate | `#855B06` | 5.48 ✓ | 5.46 ✓ | `#D4910A` — 2.44 on container |
| Error / Critical | `#A42121` | 6.03 ✓ | 6.78 ✓ | `#C62828` — 4.55 (AA only) |
| Info status | `#23566A` | 7.14 ✓ | 7.31 ✓ | `#3D95B8` — 3.01 on container |

Every value clears its target with hue held (checked in HLS: every hue shift under 0.4°, saturation held within 0.005 — only lightness moved) and its container unchanged. Full derivation, including why Info status needed its own value distinct from both Mild severity and `textLinkHover`'s fix above (three colors in the same hue family, each needing real separation from its neighbors, not just its own passing ratio) lives in **DL §8.7**, D-014.

**These are the current, shipped values** — `_Palette` no longer holds the failing originals. What's still open is composition, not color: organisms, molecules, and templates mostly read the light-only static aliases directly rather than `context.severity`/`context.colors`, which happen to resolve to these same corrected values in light mode — so the fix already reaches every current light-mode call site. It does not yet reach dark mode, because those same call sites never resolve `context.severity`/`context.colors` at all (§12, the composition-layer gap).

### 2.9 Forbidden

1. **Never** `Colors.black` or `Colors.white`.
2. **Never** an inline `Color(0xFF…)`, and never add a color to `design_tokens.dart`.
3. **Never** reference `_Palette` outside the token file.
4. **Never** `Theme.of(context).colorScheme.X` in a custom widget — Material's scheme is not our semantic layer. (This is distinct from reading *our* tokens from context, which §10 makes mandatory.)

### 2.10 Diagnostic image

`DiagnosticImageTokens` grounds diagnostic pixel data. It sits outside every other rule in this section because **DL §3.7** and **D-004** put it outside the theme: pixel data is evidence, and the perceived contrast of an image depends on its surround, which must not vary with a user preference.

| Token | Value | Use for |
|---|---|---|
| `canvasGround` | `#0A0C0E` | The ground behind and around diagnostic imagery — the viewer canvas, and any slot a DICOM image is dropped into |

**This value is not new.** §10.4 has specified it all along; it simply had no token to live in. It is deliberately *not* the chrome navy — the boundary between interface and evidence has to stay sharp.

Three rules follow:

1. **Never read this through `context.colors`.** It is mode-exempt: identical in light and dark, by design. A canvas that follows theme mode is a defect, not a preference.
2. **Never ground a diagnostic image in a semantic surface token.** `surfaceBrand` is app chrome; `surfacePage` is a page ground. Reaching for either because it "looks dark enough" is the appearance-based reasoning **D-001** forbids.
3. **Never tint the pixels themselves.** Overlays and heatmaps need a dedicated perceptual ramp, never repurposed status or severity colors (**DL §3.7**). That ramp is **not yet built** — it remains §12 gap 5, and this class does not yet carry it.

---

## 3. Typography

### 3.1 The three voices

| Constant | Family | Role |
|---|---|---|
| `fontFamilyDisplay` | IBM Plex Sans | Headings, labels, buttons — structure |
| `fontFamilyBody` | Inter | Body copy, descriptions, form fields |
| `fontFamilyMono` | IBM Plex Mono | DICOM tags, identifiers, technical output |

All three are SIL OFL 1.1; license files sit beside the fonts in `assets/fonts/`. Rationale: **DL §4.1**. Rejected candidates and why: **DL §4.8**.

### 3.2 Scale

Display and body are **separate ladders that do not overlap in size**. Inter's x-height (0.546 em) exceeds Plex Sans's (0.516 em), so a heading set at body size is out-measured by body text and the hierarchy inverts (**DL §5.1**, D-007).

| Style | Family | Size | Weight | Use for |
|---|---|---|---|---|
| `displayLg` | Display | 32 | 700 | App title, welcome screens |
| `displayMd` | Display | 28 | 700 | Major section headers |
| `displaySm` | Display | 24 | 600 | Page titles in scrollable content |
| `headingLg` | Display | 22 | 600 | Card and dialog titles |
| `headingMd` | Display | 20 | 600 | Subsection headings |
| `headingSm` | Display | 18 | 600 | List group headers — **18, not 16** |
| `bodyLg` | Body | 16 | 400 | Primary body text, chat messages |
| `bodyMd` | Body | 14 | 400 | Secondary body text, descriptions |
| `bodySm` | Body | 12 | 400 | Captions, metadata |
| `caption` | Body | 11 | 400 | **Non-clinical metadata only** — below the 12px clinical floor (DL §4.5) |
| `labelLg` | Display | 14 | 600 | Button text, tab labels, nav items |
| `labelMd` | Display | 12 | 600 | Chips, small buttons |
| `labelSm` | Display | 10 | 600 | Badge counts, overline |
| `mono` | Mono | 14 | 400 | DICOM tags, UIDs, technical output |
| `numeric` | Body | 14 | 400 | Measurements, dates, confidence in tables |

Labels intentionally share sizes with body text: rank is carried by weight, scope by size (**DL §4.4**).

### 3.3 OpenType features

Features are **inert unless requested** (**DL §4.3**). Two prepared sets:

| Set | Contains | Apply to |
|---|---|---|
| `AppTypography.tabularFeatures` | `tnum`, `ss02` | Identifiers, measurements, dates, any numeric column |
| `AppTypography.monoFeatures` | `zero` | Already applied to `mono` |

**Inter's digits are proportional by default** — its `1` is far narrower than its `0`, so an unfeatured numeric column shifts horizontally as values change. Use `numeric` (which carries the set) for numbers in tables and rows.

**Do not put `tabularFeatures` on prose.** Tabular figures read wrong mid-sentence and the disambiguation set alters letterforms distractingly in running text. `bodyMd` deliberately does not carry them, and a test enforces this.

Plex Mono needs no `tnum`: monospaced, so its figures are already tabular.

### 3.4 Color is applied separately

Styles carry no color. Apply via `copyWith`:

```dart
Text('Findings Summary',
  style: AppTypography.headingLg.copyWith(color: AppColors.textPrimary))
```

Pick the color token whose **name** matches the surface — see §2.3.

### 3.5 Weights

Only 400, 600, and 700 exist as real files, for all three families. **Requesting any other weight produces a synthesized face** — see **DL §4.7** for why that is banned. Registration lives in `pubspec.yaml`.

### 3.6 Overflow

Truncation is a content decision, not a styling one (**DL §4.6**).

| Content | Policy |
|---|---|
| Identifiers, measurements, values | **Never truncate.** Wrap, or give the layout room. |
| Descriptive clinical text | May clamp to a line count **only** with the full value reachable — tooltip, expand, or detail view — and exposed intact to assistive technology. |
| Wayfinding text — conversation titles, nav labels, section headers | Truncate freely. |

Any value a human might transcribe also renders in `mono`, not `bodyMd` (**DL §4.2**). Those two rules travel together: a transcribable value in the wrong voice *and* clipped is the failure case **DL §4.6** describes.

### 3.7 Text scaling

The OS text-scale setting is honoured in full, to 200% and beyond, with **no cap** (**DL §8.6**). Implications for token use:

- **Never set a fixed height on a box containing text.** Height follows content. `AppSpacing` values are padding, not row heights.
- **Never combine a single-line clamp with a fixed width** on text that can grow.
- **Tier selection reads the scaled dimension.** A 1280px window at 200% scale has the effective content width of a 640px one and should get that tier's layout — see §9.
- Touch-target minimums (**DL §8.5**) are floors that scale up, never ceilings that scale down.

---

## 4. Spacing

Never write a bare numeric spacing literal.

| Token | Value | Use for |
|---|---|---|
| `xxs` | 2 | Hairline gaps |
| `xs` | 4 | Icon-to-label in a chip |
| `sm` | 8 | Default gap between related elements |
| `md` | 12 | Inner padding, compact containers |
| `lg` | 16 | Standard content padding, list item padding |
| `xl` | 24 | Section spacing, card internal padding |
| `xxl` | 32 | Major section breaks |
| `xxxl` | 48 | Screen-level vertical padding |
| `huge` | 64 | Welcome and empty-state screens |

Which end of the scale to reach for is a **task** question, not a screen-size question — dense for scanning, generous for deciding (**DL §7.1**).

---

## 5. Radius

Named by the **component role** that receives the radius, not by size. Each has a matching pre-built `BorderRadius` (`borderCard`, `borderButton`, …).

| Token | Value | Use for |
|---|---|---|
| `inlineElement` | 4 | Table cells, inline code, tiny tags |
| `button` | 8 | Buttons, chips, small controls |
| `card` | 12 | Cards, containers, dialogs |
| `panel` | 16 | Large cards, image containers |
| `sheet` | 24 | Bottom sheets, modals |
| `input` | 999 | Text inputs, search bars, pill buttons |

Radius is geometry, so it does not change with theme mode (**DL §6.2**).

---

## 6. Elevation

Named by the **surface role**. Never stack shadows from multiple levels.

| Token | Use for | Max at level |
|---|---|---|
| `flat` | Relies on border or background for separation | Atom |
| `card` | Resting elevated surface | Molecule |
| `raised` | Hovered cards, FABs, popovers | Organism |
| `overlay` | Dialogs, dropdowns, tooltips | Template (overlays) |
| `modal` | Full-screen sheets, image viewers | Template (overlays) |

**Elevation splits under dark mode.** Its *geometry* is mode-independent, but shadows are nearly invisible on a dark ground, so depth is rendered there as a step up in surface lightness plus a hairline border at the top steps (**DL §6.3**). The rule above is unchanged in form: "do not stack shadows" becomes "do not stack lightness steps."

---

## 7. Icon sizes

| Token | Value | Use for |
|---|---|---|
| `xs` | 12 | Indicators inside dense components |
| `sm` | 16 | List rows, chips, badges |
| `md` | 20 | Content icons, banners, nav items |
| `lg` | 24 | Buttons, app bars |
| `xl` | 32 | Empty states, illustration spots |

---

## 8. Motion

Motion signals state change and never decorates (**DL §7.2**).

| Duration | Value | Use for |
|---|---|---|
| `microInteraction` | 150ms | Icon color change, toggle, ripple |
| `transition` | 250ms | Page fade, card expand, tab switch |
| `complexTransition` | 400ms | Sheet slide, viewer open |
| `reveal` | 600ms | Onboarding, first-launch |

| Curve | Value | Use for |
|---|---|---|
| `standard` | easeInOut | General purpose |
| `enter` | easeOut | Elements appearing |
| `exit` | easeIn | Elements leaving |
| `emphasis` | easeInOutCubicEmphasized | Hero transitions |

---

## 9. Responsive

> **Status: specified, not yet implemented.** `AppLayout` currently exposes a single `templateSplitWidth` of 768 plus five unused breakpoints. This section defines the replacement.

### 9.1 Two independent mechanisms

**Tiers** drive nav pattern and density. **Pane minimums** drive layout. Keeping them separate is the whole point (**DL D-011**).

A single breakpoint fails because it cannot see composition. At exactly 768px with navigation and a findings panel present, the chat column computes to `768 − 240 − 360 = 168px`. The breakpoint was satisfied; the layout was unusable. A template must branch on whether the panes it wants actually *fit*, not on how wide the window is.

### 9.2 Tiers

| Tier | Range | Posture |
|---|---|---|
| `compact` | < 600 | Phone — triage glance |
| `medium` | 600–1023 | Tablet portrait, small window |
| `expanded` | 1024–1599 | Workstation, tablet landscape |
| `ultrawide` | ≥ 1600 | Dual-monitor reading room |

### 9.3 Pane minimums

```
primaryColumnMin   480
panelMinWidth      320      panelMaxWidth 360
sideNavWidth       240      sideNavRailWidth 64
twoPaneMinWidth    900      = rail 64 + primary 480 + panel 360, rounded
threePaneMinWidth  1120     = nav 240 + primary 480 + panel 360, with slack
contentMaxWidth    840      text measure cap
formMaxWidth       400      auth card
```

**Content caps govern text measure, never images.** A diagnostic viewer absorbs all available width; a paragraph does not.

### 9.4 Disposition of existing tokens

| Token | Fate |
|---|---|
| `mobileMaxWidth` 599 | Delete — a boundary is one number |
| `tabletMinWidth` 600 | Rename → `mediumMinWidth` |
| `tabletMaxWidth` 959 | Delete — redundant |
| `desktopMinWidth` 960 | Retune + rename → `expandedMinWidth` 1024 |
| `wideMinWidth` 1440 | Retune + rename → `ultrawideMinWidth` 1600 |
| `templateSplitWidth` 768 | Delete after migration |

Six breakpoints (five unused) become three tier boundaries and two pane minimums, all used.

### 9.5 Per-page specification

| Page | compact | medium | expanded / ultrawide | Density |
|---|---|---|---|---|
| **Login** | Full-bleed card minus `lg`, no shadow, scrolls above keyboard | Centered card at `formMaxWidth` | As medium, centered in a 640 column | Generous |
| **Onboarding** | Full-bleed carousel; image top, copy below | Content capped 560 | Two columns — image left, copy right, capped `contentMaxWidth` | Generous |
| **Chat** | Conversations in overlay drawer; findings in draggable bottom sheet | Conversations collapse to 64px rail; findings slide over above `twoPaneMinWidth` | Three panes: nav │ chat │ findings, gated at `threePaneMinWidth` | Comfortable chat, compact findings |
| **Study Review** | Viewer 4:3 on top, `Findings │ Chat` tabs below | Viewer left / tabs right above `twoPaneMinWidth`, else viewer top | Three zones, gated at `threePaneMinWidth`. **Ultrawide: viewer and findings side by side, viewer absorbs the extra width** | Comfortable → compact |
| **Case List** | Single-column card list | Two-column grid capped `contentMaxWidth` | **Dense sortable table** — patient, modality, date, confidence, severity. Ultrawide adds columns, caps 1440 | Comfortable → compact → dense |
| **Heatmap Viewer** | Full-screen canvas, controls in bottom bar over scrim | As compact, 56px control bar | Canvas centered, controls in a 280px right rail | 44px touch to `expanded`, then 32px |
| **Settings** | Single-column section list | Single column capped 640 | Two columns — 200px index left, content right capped 720 | Generous |

Case List switching from grid to table at `expanded` is deliberate: a worklist is a scanning task, and scanning tasks want tables (**DL §7.1**).

Settings gains an **Appearance** section at every tier for the theme control (§10.4).

### 9.6 Where responsive logic lives

**Templates only.** Branch on `LayoutBuilder` constraints, never on `MediaQuery.of(context).size` — window size is not the size of the box your widget occupies. See §12 for the current violation.

---

## 10. Theming

> **Status: palette official, mechanism built, composition pending.** Every dark value in §10.4 is final — decided, computed, and verified, not a proposal — and implemented: `AppColorsData`/`SeverityData` exist, `buildAppTheme(Brightness)` builds either theme correctly, and `app.dart` sets `darkTheme`/`themeMode: ThemeMode.dark`. What's outstanding is that only atoms read it — organisms, molecules, and templates mostly still read the light-only static alias directly, so dark mode is real in the token layer and invisible everywhere a user would actually see it (§12, gap 1).

### 10.1 The split

| Stays `static const` | Becomes context-aware |
|---|---|
| `AppSpacing`, `AppRadius`, `AppIconSize` | `AppColors` |
| `AppMotion`, `AppLayout` | `ChatTokens`, `NavigationTokens` |
| Typography metrics | `SeverityTokens`, `TooltipTokens`, `AppScrollbar` |
| Elevation *geometry* | Elevation *rendering* |

Structural tokens are brightness-invariant by definition (**DL §6.2**), and keeping them const preserves `const` constructors at most call sites.

### 10.2 Mechanism: `ThemeExtension`

Color-bearing tokens move into immutable `ThemeExtension` data classes, reached through a context accessor:

```dart
extension AppThemeContext on BuildContext {
  AppColorsData get colors   => Theme.of(this).extension<AppColorsData>() ?? AppColorsData.light;
  SeverityData  get severity => Theme.of(this).extension<SeverityData>()  ?? SeverityData.light;
}
```

`context.colors.textPrimary` reads the same as `AppColors.textPrimary` and is one token longer.

Chosen over a bespoke `InheritedWidget` for three reasons, the third decisive:

1. `MaterialApp`'s `theme` / `darkTheme` / `themeMode` already solves mode resolution and system-brightness following.
2. `ThemeData` interpolates extensions, so a mode switch cross-fades custom widgets in step with Material ones instead of snapping.
3. **The forced-dark subtree** required by **DL §6.5** works with no widget changes: the viewer wraps its canvas in `Theme(data: …copyWith(extensions: darkSet))` and every descendant follows. This subsumes the hand-rolled dark surface in `heatmap_viewer_template.dart`.

### 10.3 Atom role enums

Atoms take a **role** rather than a `Color`, so call sites stay `const` and become mode-correct for free:

```dart
const AppText('Sign in to your account', role: AppTextRole.secondary)
```

`Color?` remains as an escape hatch. Molecules and above read `context.colors` directly — they own composition, not primitives.

### 10.4 Dark palette derivation

No new brand. **Hue is invariant; chroma and lightness move.**

- **The dark ground is a desaturated deep-navy derivative**, not deep navy itself — the brand navy is too chromatic for a full-screen ground and too light to let surfaces step above it. **L\* 6.1**, never `#000000` and never below roughly L\* 5, where primary text begins to bloom (**DL §6.4**, D-012).
- **Elevation becomes a four-step lightness ladder**, ~4 L\* apart.
- **`surfaceBrand` inverts its relationship, not its role.** Dark navy chrome on a dark page has no separation, so in dark mode it becomes *elevated* navy — lighter than the page.
- **Severity and status invert their construction**: a light tint of the hue as foreground, a deeply darkened low-chroma version as container. Reusing the light-mode foregrounds fails contrast badly on a dark ground.
- **Brand reference tokens do not change** (§2.7).
- Most of the currently unused `_Palette` entries get consumed, so the private palette barely grows.

Every dark pair ships with computed contrast ratios, same as **DL §8.7**.

#### The values

**Official.** Not a draft, not a proposal under review — ratified per **DL D-012, D-013**. Normative: the Dart implements these — `AppColorsData.dark`/`SeverityData.dark` hold every value below exactly, verified field by field — and where anything disagrees, the Dart is wrong. The one thing not yet true is that anything above the atom layer *reads* them (§12 gap 1) — that is a composition gap, not a reason to treat any value below as provisional.

**Elevation ladder** — the four steps, and what "depth is lightness" means in practice:

| Step | Value | L\* | Role |
|---|---|---|---|
| `surfacePage` | `#0E141B` | 6.1 | Scaffold ground |
| `surface` | `#151C25` | 10.0 | Cards, dialogs, input fill |
| `surfaceRaised` | `#1C242F` | 13.9 | Hovered cards, popovers |
| `surfaceOverlay` | `#232C38` | 17.7 | Dialogs, menus — plus a hairline border |

**Text ramp** — check every level of the ladder, not just the page. Muted text failed at 4.35:1 on the raised surface before it was lifted:

| Token | Value | On page → overlay |
|---|---|---|
| `textPrimary` | `#E4E8ED` | 15.04 · 13.93 · 12.71 · 11.46 |
| `textSecondary` | `#B4BCC6` | 9.65 · 8.94 · 8.15 · 7.35 |
| `textTertiary` | `#939CA8` | 6.66 · 6.17 · 5.63 · 5.08 |
| `textMuted` | `#8B95A1` | 6.09 · 5.64 · 5.15 · 4.64 |

`textTertiary` clears AA but not AAA, so it stays off clinical strings in both modes (§2.3).

**Brand, accent and border:**

| Token | Value | Note |
|---|---|---|
| `surfaceBrand` | `#16273D` | Elevated navy — *lighter* than the page, inverting its light-mode relationship |
| `surfaceBrandSecondary` | `#1B3049` | Same inversion |
| `textOnBrand` | `#E4E8ED` | 12.26 · 10.90 on the two above |
| `interactivePrimary` | `#4FA3C4` | Accent lifted two steps |
| `textLink` / `borderFocused` | `#6DB3CE` | 7.92 on page |
| `border` | `#5E6B7A` | **Meaningful borders only** — 3.15 vs surface. Three lighter-looking candidates failed 3:1 first |
| `borderSubdued` | `#2A3442` | Decorative separator, no contrast floor |

**Severity and status** — the light-mode construction inverts: a light tint of the hue in front, a darkened low-chroma version behind.

| Level | Foreground | Container | On container | Vs page |
|---|---|---|---|---|
| Normal | `#7FD1A0` | `#14301F` | 7.83 | 10.16 |
| Mild | `#8ECDF2` | `#12293A` | 8.66 | 10.72 |
| Moderate | `#F0C070` | `#3A2A0F` | 8.22 | 11.00 |
| Critical | `#FF9A93` | `#421D1D` | 7.22 | 9.07 |

App status reuses these four pairs under its own token names — the two systems stay separately named so they can diverge later (**DL §3.5**).

**Diagnostic canvas:** `#0A0C0E`. Mode-exempt, and deliberately *not* the chrome navy — the boundary between interface and evidence has to stay sharp (**DL §3.7**). It is listed here because this is where the value was first written down, but it is **not a dark-mode value** — it is the same in both modes. It lives in `DiagnosticImageTokens.canvasGround` (§2.10).

### 10.5 Runtime

`buildAppTheme(Brightness)`; `MaterialApp` gets `theme`, `darkTheme`, and `themeMode`.

**The app opens dark** — `themeMode` starts at `ThemeMode.dark`, not `ThemeMode.system` (**DL §6.5**, D-013). The Settings Appearance section exposes Dark / Light / System in that order, and the user's choice is remembered across launches. Following the system preference remains available; it is just not the default.

---

## 11. Rules and review

### 11.1 Forbidden patterns

| Never | Instead |
|---|---|
| `Color(0xFF…)` inline | Semantic token |
| `Colors.black` / `Colors.white` | `textPrimary` / `surface` |
| `_Palette.anything` | The semantic layer |
| `Theme.of(context).colorScheme.X` | Our tokens — see §2.9 |
| `SizedBox(height: 16)` | `AppSpacing.lg` |
| `BorderRadius.circular(12)` | `AppRadius.borderCard` |
| `TextStyle(fontSize: 14)` | `AppTypography.bodyMd` |
| `Duration(milliseconds: 250)` | `AppMotion.transition` |
| A font weight with no real file | 400, 600, or 700 only |
| `MediaQuery.of(context).size` for layout | `LayoutBuilder` constraints, in a template |
| Adding a color | Find the token whose purpose matches |

### 11.2 Checklist

- [ ] No hex literals, `_Palette` references, or new colors.
- [ ] No bare spacing numbers, inline radii, inline `TextStyle`, or raw `Duration`.
- [ ] Text color token **name** matches its surface (§2.3).
- [ ] Chat UI uses `ChatTokens`; navigation uses `NavigationTokens`.
- [ ] Clinical severity uses `SeverityTokens`; app operations use `AppColors.status*`. Never both in one component.
- [ ] Every severity indicator carries a label **and** a distinct shape (**DL §3.6**).
- [ ] At most one Layer-5 element in the viewport (**DL §5.2**).
- [ ] Elevation within the level's maximum; no stacking.
- [ ] Numbers in columns use `numeric`; prose does not.
- [ ] Only registered font weights requested.
- [ ] No identifier, measurement, or value truncates; anything transcribable uses `mono` (§3.6).
- [ ] No fixed heights on text containers; layout survives 200% text scale (§3.7).
- [ ] Responsive branching lives in a template and reads `LayoutBuilder` constraints.

---

## 12. Known gaps

Live defects and unimplemented specifications. Delete entries as they close.

| # | Gap | Where |
|---|---|---|
| 1 | **Dark mode: tokens, atoms, and three molecules done, composition otherwise not.** The `ThemeExtension` mechanism is built and correct (`AppColorsData`/`SeverityData`, `context.colors`/`context.severity`), every dark value matches §10.4 exactly, `app.dart` wires `darkTheme`/`themeMode: ThemeMode.dark` per §10.5, every atom reads `context.colors`, and `finding_row`/`metadata_field`/`severity_chip`/`findings_panel` now do too. But 14 files above the atom layer still read the deprecated light-only statics directly — organisms `app_nav_bar`, `chat_panel`, `conversation_drawer`, `onboarding_carousel`, `status_bar`, `study_info_card`; the molecule `status_banner`; all 7 templates. Since every real screen composes down through templates → organisms → molecules → atoms, dark mode does not currently render on any page — confirmed by rendering all four canvas-reviewed screens in both modes: the dark and light captures of Study Review are pixel-identical. | 15 files listed above |
| 2 | **Responsive tiers unimplemented.** §9 is specification only. One breakpoint at 768; five dead tokens. | `AppLayout`, all templates |
| 3 | **The 168px chat column.** At 768 with nav and panel present, the primary column collapses. Fixed by §9.3. | `chat_template.dart`, `study_review_template.dart` |
| 5 | **Heatmap overlay built from status colors.** Violates **DL §3.7** — needs the dedicated perceptual ramp. `DiagnosticImageTokens` now exists (§2.10) but carries only the canvas ground; the ramp is deliberately unbuilt, because deriving one means new color needing a decision-log entry against D-001, and there is no production heatmap to validate it against — the offending gradient is preview-only code. | `heatmap_viewer_template.dart` previews |
| 6 | **`AppInteraction` hover tokens unwired.** Documented as web-only, but no `MouseRegion` anywhere reads them. | all levels |
| 13 | **Text scaling unverified.** §3.7 is specification only. No layout has been tested at 200%, and fixed-height rows may exist. | all levels |
