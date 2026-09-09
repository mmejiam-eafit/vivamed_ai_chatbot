# Brand mark — working files

The RadAsk mark: a speech-bubble icon, optionally paired with the "RadAsk"
wordmark. Built to replace an earlier draft that used an unrelated dark
navy and a bright cyan — neither came from `design_tokens.md` §2.7's brand
palette, so the mark didn't actually read as this app's brand.

**`logo-mark.svg` and `logo-full.svg` are what the app renders.**
[`AppLogo`](../../lib/ui/atoms/app_logo.dart) loads them directly via
`flutter_svg`'s `SvgPicture.asset` — this project's first production
dependency (fonts were the only declared asset type before this). An
earlier version hand-painted the same geometry with a `CustomPainter` to
avoid that dependency; it was dropped before it shipped; a `CustomPainter`
meant hand-transcribing the SVG path into Dart's `Path` API and keeping
the two in sync by hand, for a dependency that's small, standard, and
already what most Flutter apps reach for to render a static vector asset.
`logo-reversed.svg` has no in-app call site yet (§ below on why it's
monochrome) and stays out of `pubspec.yaml`'s `assets:` list until one
exists.

## Files

| File | What it is |
|---|---|
| `logo-mark.svg` | Icon only — the speech bubble, no wordmark. `brandPrimary` stroke, transparent ground. |
| `logo-full.svg` | The primary lockup — icon + wordmark, `brandPrimary`/`brandAccent` two-tone. Transparent ground; meant for a light/near-white surface (`surfacePage`, `surface`, or literally `brandLight`). |
| `logo-reversed.svg` | A self-contained badge for dark or unknown-background contexts — rounded-rect `brandPrimary` fill, monochrome `brandLight` bubble + wordmark. |

All three use only the four tokens `design_tokens.md` §2.7 names for
exactly this purpose — `brandPrimary` (`#0C2B4E`), `brandSecondary`
(`#1A3D64`, unused here), `brandAccent` (`#1D546C`), `brandLight`
(`#F4F4F4`) — mode-invariant, so the mark looks the same regardless of the
app's active theme. No new hex was introduced.

Text is a live `<text>`/`<tspan>` element (`IBM Plex Sans` with a system
fallback stack), not outlined to paths — editable, but not guaranteed to
render identically without that font installed. No path-outlining tool
was available in the environment this was built in; if a fully
font-independent export is ever needed, that's a redo, not an edit.

## Why `logo-reversed.svg` is monochrome, not two-tone

The original draft's whole premise — bright accent text on a dark navy
badge — doesn't survive contact with the real palette:

```
brandAccent (#1D546C) on brandPrimary (#0C2B4E)  →  1.72:1
brandSecondary (#1A3D64) on brandPrimary (#0C2B4E) → 1.29:1
```

Both fail even the 3:1 floor for graphical objects, let alone 4.5:1 for
text — computed with the same sRGB relative-luminance method as
`design/canvas/cr.py`, not estimated. `brandAccent` and `brandSecondary`
are tuned as accents *on light surfaces* (buttons, links), not as a bright
pop against `brandPrimary` itself — the two darkest brand shades sit too
close in lightness to each other for that to work. The only brand token
that clears contrast against `brandPrimary` is `brandLight`, at 12.98:1:

```
brandLight (#F4F4F4) on brandPrimary (#0C2B4E)  →  12.98:1
brandAccent (#1D546C) on brandLight (#F4F4F4)   →   7.53:1
```

Rather than invent a fifth brand color to keep the two-tone look on a dark
ground — which `AGENTS.md`'s "never add a new color, find the existing
token whose purpose matches" rule rules out on its own — the reversed
badge goes monochrome, and the two-tone treatment lives in `logo-full.svg`
instead, on the light ground the tokens actually support it on. See
`design_language.md` D-015.
