# Palette — quick reference

**This is a compiled index, not a source of truth.** [`design_tokens.md`](design_tokens.md)
§2 (light, semantic) and §10.4 (dark, values) are authoritative; where this
page disagrees with either, they win. This exists so both modes' hex values
are visible in one place without cross-referencing the Dart and the docs —
nothing here is derived independently of them.

**A note on how this file came to exist:** an earlier `PALETTE.md` lived only
in Claude's scratchpad while the dark palette was being worked out, never
committed to the repo, and didn't survive a machine reset. Its draft numbers
were promoted into `design_tokens.md` §10.4 once finalized, so nothing of
substance was lost — but the working notes themselves are gone, and this file
is a fresh compilation from the current authoritative sources, not a recovery
of that draft. See [`design/canvas/README.md`](design/canvas/README.md) for
the fuller story.

## Light — shipped in `lib/ui/core/design_tokens.dart`

| Token (`AppColors.*`) | Hex | Palette name |
|---|---|---|
| `surfacePage` | `#F4F4F4` | `offWhite` |
| `surface` | `#FFFFFF` | `white` |
| `surfaceSubdued` | `#EEEEEE` | `gray100` |
| `surfaceBrand` | `#0C2B4E` | `deepNavy` |
| `surfaceBrandSecondary` | `#1A3D64` | `mediumNavy` |
| `surfaceAccent` | `#E9F3F7` | `tealBlue50` |
| `surfaceBrandSubdued` | `#ECF0F5` | `deepNavy50` |
| `surfaceBrandSecondarySubdued` | `#EDF1F7` | `mediumNavy50` |
| `textPrimary` | `#1A1A1A` | `gray900` |
| `textSecondary` | `#4A4A4A` | `gray700` |
| `textTertiary` | `#636363` | `gray600` — AA only, not for clinical strings |
| `textPlaceholder` / `textDisabled` | `#A0A0A0` | `gray400` |
| `textMuted` | `#7D7D7D` | `gray500` |
| `textOnBrand` | `#F4F4F4` | `offWhite` |
| `textOnAccent` | `#0F3545` | `tealBlue800` |
| `textOnBrandSubdued` | `#061625` | `deepNavy900` |
| `textOnBrandSecondarySubdued` | `#0F2640` | `mediumNavy800` |
| `textLink` | `#267390` | `tealBlue600` |
| `textLinkHover` | `#3D95B8` | `tealBlue400` |
| `textLinkVisited` | `#0F3545` | `tealBlue800` |
| `icon` | `#636363` | `gray600` |
| `iconOnBrand` | `#F4F4F4` | `offWhite` |
| `iconAccent` | `#1D546C` | `tealBlue` |
| `iconDisabled` | `#A0A0A0` | `gray400` |
| `border` | `#C4C4C4` | `gray300` |
| `borderSubdued` | `#DCDCDC` | `gray200` |
| `borderFocused` | `#3D95B8` | `tealBlue400` |
| `borderSelected` | `#1D546C` | `tealBlue` |
| `interactivePrimary` | `#1D546C` | `tealBlue` |
| `interactivePrimaryForeground` | `#F4F4F4` | `offWhite` |
| `interactiveSecondary` | `#FFFFFF` | `white` |
| `interactiveSecondaryForeground` | `#1D546C` | `tealBlue` |
| `interactiveHover` | `#267390` | `tealBlue600` |
| `interactiveAccent` | `#3D95B8` | `tealBlue400` |
| `interactiveDisabled` | `#DCDCDC` | `gray200` |
| `interactiveDisabledForeground` | `#7D7D7D` | `gray500` |

**Status** (app operations — §2.5) and **severity** (clinical findings — §2.6)
are separate systems that currently share hues:

| Level | Foreground | Container |
|---|---|---|
| Success / Normal | `#2E7D4F` `green700` | `#D9F0E3` `green50` |
| Info / Mild | `#0277BD` `blue700` | `#DCEEF9` `blue50` |
| Warning / Moderate | `#D4910A` `amber700` | `#FFF4D6` `amber50` |
| Error / Critical | `#C62828` `red700` | `#FFE0E0` `red50` |

**Brand reference** (logos, brand illustrations only — mode-invariant):
`brandPrimary #0C2B4E` · `brandSecondary #1A3D64` · `brandAccent #1D546C` ·
`brandLight #F4F4F4`.

## Dark — specified in `design_tokens.md` §10.4, not yet in Dart

Same hue family as light; chroma and lightness move, not the palette itself.
Full derivation, every contrast ratio, and the candidates that failed are in
§10.4 — this is the hex list only.

**Elevation ladder** (~4 L\* apart):

| Token | Hex | L\* |
|---|---|---|
| `surfacePage` | `#0E141B` | 6.1 |
| `surface` | `#151C25` | 10.0 |
| `surfaceRaised` | `#1C242F` | 13.9 |
| `surfaceOverlay` | `#232C38` | 17.7 |

**Text ramp:** `textPrimary #E4E8ED` · `textSecondary #B4BCC6` ·
`textTertiary #939CA8` (AA only, same rule as light) · `textMuted #8B95A1`.

**Brand, accent, border:** `surfaceBrand #16273D` · `surfaceBrandSecondary #1B3049`
(both *lighter* than the page — inverted from light mode) · `textOnBrand #E4E8ED` ·
`interactivePrimary #4FA3C4` · `textLink` / `borderFocused #6DB3CE` ·
`border #5E6B7A` (meaningful borders only) · `borderSubdued #2A3442`.

**Severity / status** (light tint foreground, darkened container — inverted
construction from light mode):

| Level | Foreground | Container |
|---|---|---|
| Normal | `#7FD1A0` | `#14301F` |
| Mild | `#8ECDF2` | `#12293A` |
| Moderate | `#F0C070` | `#3A2A0F` |
| Critical | `#FF9A93` | `#421D1D` |

**Diagnostic canvas:** `#0A0C0E` — mode-exempt, deliberately not the chrome
navy, same value in both themes.
