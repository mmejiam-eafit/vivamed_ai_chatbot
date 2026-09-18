# Design tokens — quick reference

**[`design_tokens.md`](design_tokens.md) is the single normative source** for
every value below, with no exception — every hex, ratio, and figure here is
transcribed from it, section noted, so a spacing value or a color doesn't
require opening all ~650 lines. Where this disagrees with `design_tokens.md`,
that document wins — treat any mismatch here as a bug in this file, not in
it. (Light-mode color used to be the one gap: `design_tokens.md` §2 named
tokens by purpose only. §2.8 closed that, so light now has the same
computed-hex, computed-ratio treatment as dark's §10.4.)

## Color — light (§2, values §2.8)

| Token (`AppColors.*`) | Hex | Use for |
|---|---|---|
| `surfacePage` | `#F4F4F4` | Scaffold / page background |
| `surface` | `#FFFFFF` | Default card, dialog, input fill |
| `surfaceSubdued` | `#EEEEEE` | Striped rows, hover fills, empty states |
| `surfaceBrand` | `#0C2B4E` | Hero sections, headers |
| `surfaceBrandSecondary` | `#1A3D64` | Drawers, section accents |
| `surfaceAccent` | `#E9F3F7` | Selected items, highlighted rows |
| `surfaceBrandSubdued` | `#ECF0F5` | Selected items, info banners |
| `surfaceBrandSecondarySubdued` | `#EDF1F7` | Secondary brand-tinted light surface |
| `textPrimary` | `#1A1A1A` | Body text on light surfaces |
| `textSecondary` | `#4A4A4A` | Subtitles, descriptions |
| `textTertiary` | `#636363` | Helper text — AA only, not clinical strings |
| `textPlaceholder` / `textDisabled` | `#A0A0A0` | Input placeholders / inactive labels — under 4.5:1, but WCAG exempts inactive/placeholder text, so this is by design |
| `textMuted` | `#6E6E6E` | Timestamps, fine print — 4.64:1 on page. Remediated from a failing `#7D7D7D` (3.74:1); wired into `_Palette`. |
| `textOnBrand` | `#F4F4F4` | Text on `surfaceBrand` / `surfaceBrandSecondary` |
| `textOnAccent` | `#0F3545` | Text on `surfaceAccent` |
| `textOnBrandSubdued` | `#061625` | Text on `surfaceBrandSubdued` |
| `textOnBrandSecondarySubdued` | `#0F2640` | Text on `surfaceBrandSecondarySubdued` |
| `textLink` | `#267390` | Inline interactive text |
| `textLinkHover` | `#275F75` | Link hover — 6.41:1 on page, its own value. Used to share `#3D95B8` with `borderFocused` / `interactiveAccent` below and fail as text (3.08:1); those two keep that value, unaffected, since their 3:1 floor was never the problem. |
| `textLinkVisited` | `#0F3545` | Link visited |
| `icon` | `#636363` | Default icon |
| `iconOnBrand` | `#F4F4F4` | Icon on brand surfaces |
| `iconAccent` | `#1D546C` | Accented icon |
| `iconDisabled` | `#A0A0A0` | Disabled icon |
| `border` | `#7D7D7D` | Default border — 4.12:1 on `surface`, 3.74:1 on `surfacePage`; meaningful borders only |
| `borderSubdued` | `#DCDCDC` | Decorative separator |
| `borderFocused` | `#3D95B8` | Focus ring — unaffected by `textLinkHover`'s fix above; this token keeps the value |
| `borderSelected` | `#1D546C` | Selected state |
| `interactivePrimary` | `#1D546C` | Primary button / control fill |
| `interactivePrimaryForeground` | `#F4F4F4` | Text/icon on `interactivePrimary` |
| `interactiveSecondary` | `#FFFFFF` | Secondary button fill |
| `interactiveSecondaryForeground` | `#1D546C` | Text/icon on `interactiveSecondary` |
| `interactiveHover` | `#267390` | Hover state |
| `interactiveAccent` | `#3D95B8` | Accented control |
| `interactiveDisabled` | `#DCDCDC` | Disabled control fill |
| `interactiveDisabledForeground` | `#7D7D7D` | Text/icon on a disabled control |

## Color — dark (§10.4)

> **Official, wired, and live on real screens.** Ratified, computed, verified
> (DL D-012, D-013) — the `ThemeExtension` mechanism (§10.2) exists,
> `AppColorsData.dark` holds every one of these values, and every widget
> from atoms through templates reads it via `context.colors`. Settings'
> Appearance section gives users a real Dark/Light/System toggle. The only
> exceptions are deliberate: `AppLogo` (mode-invariant brand assets) and the
> `DiagnosticImageTokens` canvas ground (mode-exempt by rule).

**Elevation ladder** (~4 L\* apart):

| Token | Hex | L\* | Role |
|---|---|---|---|
| `surfacePage` | `#0E141B` | 6.1 | Scaffold ground |
| `surface` | `#151C25` | 10.0 | Cards, dialogs, input fill |
| `surfaceRaised` | `#1C242F` | 13.9 | Hovered cards, popovers |
| `surfaceOverlay` | `#232C38` | 17.7 | Dialogs, menus — plus a hairline border |

**Text ramp** (ratio on page → surface → raised → overlay):

| Token | Hex | Ratio |
|---|---|---|
| `textPrimary` | `#E4E8ED` | 15.04 · 13.93 · 12.71 · 11.46 |
| `textSecondary` | `#B4BCC6` | 9.65 · 8.94 · 8.15 · 7.35 |
| `textTertiary` | `#939CA8` | 6.66 · 6.17 · 5.63 · 5.08 — AA only, not clinical strings |
| `textMuted` | `#8B95A1` | 6.09 · 5.64 · 5.15 · 4.64 |

**Brand, accent, border:**

| Token | Hex | Note |
|---|---|---|
| `surfaceBrand` | `#16273D` | Elevated navy — *lighter* than the page, inverted from light mode |
| `surfaceBrandSecondary` | `#1B3049` | Same inversion |
| `textOnBrand` | `#E4E8ED` | 12.26 · 10.90 on the two above |
| `interactivePrimary` | `#4FA3C4` | Accent lifted two steps |
| `textLink` / `borderFocused` | `#6DB3CE` | 7.92 on page |
| `border` | `#5E6B7A` | Meaningful borders only — 3.15 vs surface |
| `borderSubdued` | `#2A3442` | Decorative, no contrast floor |

**Diagnostic canvas:** `#0A0C0E` — mode-exempt, same value in both themes.

## Status & severity (§2.5, §2.6, §10.4)

Two separate systems that share hues — status is app operations, severity is
clinical findings; never use one for the other.

| Level | Light foreground | Light container | On container | Was (failing) | Dark foreground | Dark container |
|---|---|---|---|---|---|---|
| Success / Normal | `#276A43` | `#D9F0E3` | 5.43 ✓ | `#2E7D4F` — 4.21 ✗ | `#7FD1A0` | `#14301F` |
| Mild severity | `#02639E` | `#DCEEF9` | 5.38 ✓ | `#0277BD` — 4.03 ✗ | `#8ECDF2` | `#12293A` |
| Warning / Moderate | `#855B06` | `#FFF4D6` | 5.48 ✓ | `#D4910A` — 2.44 ✗ | `#F0C070` | `#3A2A0F` |
| Error / Critical | `#A42121` | `#FFE0E0` | 6.03 ✓ | `#C62828` — 4.55 ✓ (AA only) | `#FF9A93` | `#421D1D` |
| Info status | `#23566A` | `#E9F3F7` | 7.14 ✓ | `#3D95B8` — 3.01 ✗ | — | — |

**Corrected:** this table used to show one combined "Info / Mild" row using
only Mild severity's hex — they're different colors (`statusInfo` is the
brand teal accent, `SeverityTokens.mild` a plain blue), and Info status has
its own row now. Its dark columns are empty on purpose: dark mode
deliberately reuses the Mild pair for Info status (§10.4), so there's no
separate dark value to show — a light-only asymmetry that predates any of
this, not something introduced here.

**Light's severity system used to fail or barely clear AA across the
board** — dark's was derived from scratch with a floor to hit; light's
predated that discipline and was never brought up to it, until now. Every
value above is computed and verified, hue held (checked in HLS, not
eyeballed), and wired into `_Palette` — `design_tokens.md` §2.8 has the
full ratio picture. Composition is done too: the widgets that render these
colors read `context.severity` directly, so the fix reaches every call
site in both light and dark mode. A severity indicator carries a label
**and** a distinct shape regardless — never hue alone (§2.6).

## Brand reference (§2.7)

Mode-invariant — logos and brand illustrations only; prefer the semantic
surface/interactive token everywhere else.

`brandPrimary #0C2B4E` · `brandSecondary #1A3D64` · `brandAccent #1D546C` ·
`brandLight #F4F4F4`

## Typography (§3)

| Family constant | Font | Role |
|---|---|---|
| `fontFamilyDisplay` | IBM Plex Sans | Headings, labels, buttons |
| `fontFamilyBody` | Inter | Body copy, descriptions, form fields |
| `fontFamilyMono` | IBM Plex Mono | DICOM tags, identifiers, technical output |

| Style | Family | Size | Weight | Use for |
|---|---|---|---|---|
| `displayLg` | Display | 32 | 700 | App title, welcome screens |
| `displayMd` | Display | 28 | 700 | Major section headers |
| `displaySm` | Display | 24 | 600 | Page titles in scrollable content |
| `headingLg` | Display | 22 | 600 | Card and dialog titles |
| `headingMd` | Display | 20 | 600 | Subsection headings |
| `headingSm` | Display | 18 | 600 | List group headers |
| `bodyLg` | Body | 16 | 400 | Primary body text, chat messages |
| `bodyMd` | Body | 14 | 400 | Secondary body text, descriptions |
| `bodySm` | Body | 12 | 400 | Captions, metadata |
| `caption` | Body | 11 | 400 | Non-clinical metadata only |
| `labelLg` | Display | 14 | 600 | Button text, tab labels, nav items |
| `labelMd` | Display | 12 | 600 | Chips, small buttons |
| `labelSm` | Display | 10 | 600 | Badge counts, overline |
| `mono` | Mono | 14 | 400 | DICOM tags, UIDs, technical output |
| `numeric` | Body | 14 | 400 | Measurements, dates, confidence in tables |

Only 400/600/700 exist as real files, for all three families — any other
weight is synthesized and banned (§3.5).

**OpenType feature sets:** `tabularFeatures` (`tnum`, `ss02`) on identifiers,
measurements, dates, numeric columns — never on prose. `monoFeatures`
(`zero`) is already applied to `mono`.

## Spacing (§4)

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

## Radius (§5)

Named by the component role that receives it, not by size.

| Token | Value | Use for |
|---|---|---|
| `inlineElement` | 4 | Table cells, inline code, tiny tags |
| `button` | 8 | Buttons, chips, small controls |
| `card` | 12 | Cards, containers, dialogs |
| `panel` | 16 | Large cards, image containers |
| `sheet` | 24 | Bottom sheets, modals |
| `input` | 999 | Text inputs, search bars, pill buttons |

## Elevation (§6)

Named by surface role. Never stack shadows from multiple levels; in dark
mode, depth is the lightness ladder above, not shadow (§6, §10.4) — the
concrete shadow parameters (blur, offset, opacity) live only in
`AppElevation` in Dart, since this section of `design_tokens.md` specifies
role, not literal values.

| Token | Use for | Max at level |
|---|---|---|
| `flat` | Relies on border or background for separation | Atom |
| `card` | Resting elevated surface | Molecule |
| `raised` | Hovered cards, FABs, popovers | Organism |
| `overlay` | Dialogs, dropdowns, tooltips | Template (overlays) |
| `modal` | Full-screen sheets, image viewers | Template (overlays) |

## Icon sizes (§7)

| Token | Value | Use for |
|---|---|---|
| `xs` | 12 | Indicators inside dense components |
| `sm` | 16 | List rows, chips, badges |
| `md` | 20 | Content icons, banners, nav items |
| `lg` | 24 | Buttons, app bars |
| `xl` | 32 | Empty states, illustration spots |

## Motion (§8)

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

## Responsive (§9)

> Implemented — the tier system and most pane minimums drive `LayoutBuilder`
> branching in all 9 templates (§12 gap 2). Five `AppLayout` tokens are
> still unwired: `templateSplitWidth`, `primaryColumnMin`, `panelMinWidth`,
> and the `sideNavWidth`/`sideNavRailWidth` aliases.

| Tier | Range | Posture |
|---|---|---|
| `compact` | < 600 | Phone — triage glance |
| `medium` | 600–1023 | Tablet portrait, small window |
| `expanded` | 1024–1599 | Workstation, tablet landscape |
| `ultrawide` | ≥ 1600 | Dual-monitor reading room |

Pane minimums (§9.3):

```
primaryColumnMin   480
panelMinWidth      320      panelMaxWidth 360
sideNavWidth       240      sideNavRailWidth 64
twoPaneMinWidth    900      = rail 64 + primary 480 + panel 360, rounded
threePaneMinWidth  1120     = nav 240 + primary 480 + panel 360, with slack
contentMaxWidth    840      text measure cap
formMaxWidth       400      auth card
```

## Runtime (§10.5)

The app opens dark — `themeMode` starts at `ThemeMode.dark`, not
`ThemeMode.system`. Settings' Appearance section orders the choice
Dark / Light / System, and remembers it across launches.
