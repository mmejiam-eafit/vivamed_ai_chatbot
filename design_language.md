# Design Language — Radiologist Helper

This document explains **why** the design system is the way it is: what response the interface is engineered to produce in a radiologist, and which decisions are load-bearing for that response.

It is the **authoritative** source for design intent. [`design_tokens.md`](design_tokens.md) specifies how these principles become tokens, and [`lib/ui/core/design_tokens.dart`](lib/ui/core/design_tokens.dart) implements them. When the code disagrees with this document, **the code is wrong**.

To change a design decision: amend this document first, then update `design_tokens.md`, then change the Dart. Never the reverse — a value changed in Dart without a reason recorded here is how a design system decays into a pile of hex codes.

This document deliberately names no Dart identifiers. If you are looking for a token name, you want `design_tokens.md`.

---

## 1. Who this is for

### 1.1 The reading-room session

A radiologist using this tool is four to eight hours into a shift, in a room deliberately dimmed to somewhere between 25 and 75 lux — perhaps a tenth of normal office lighting. The room is dark because it has to be: ambient light reflecting off a diagnostic display washes out the low-contrast detail that a diagnosis depends on.

This app is not the diagnostic display. It sits on a secondary monitor, or a tablet propped beside the workstation. It lives in the radiologist's peripheral vision most of the time and gets direct attention in short bursts.

That physical situation drives more of this document than any aesthetic preference does.

### 1.2 Three postures

Each of these is a real design target, not a responsive afterthought:

| Posture | Situation | What matters |
|---|---|---|
| **Workstation** | Dim room, dual monitor, mouse and keyboard | Density, keyboard reachability, not competing with the diagnostic display |
| **Tablet** | Rounds, consults, upright, touch | Touch targets, one-thumb reach, glare from overhead lighting |
| **Phone** | Triage glance, notification follow-up, one-handed | Speed to the single fact being checked |

### 1.3 What this tool is not

It is **advisory**. It is not a PACS, and it is not a regulated diagnostic device. The radiologist decides; the tool suggests.

That constrains how much visual authority the interface may claim, and the constraint cuts both ways. An interface that presents AI findings with the visual confidence of a measured fact invites automation bias — the well-documented tendency to defer to a machine's judgment over one's own. An interface that hedges everything into visual mush gets ignored, and an ignored safety tool is worse than no tool because it consumed budget and attention.

The design has to land between those. Several rules below exist specifically to hold that line.

---

## 2. The response we are engineering

### 2.1 Three goals

**Trust without deference.** The interface should read as *instrumentation* — something calibrated, that reports. Not a chatbot with a personality, and not an oracle. The radiologist should feel like they are reading an instrument panel, where they remain the one interpreting.

**Calm under time pressure.** In the resting state, nothing competes for attention. A worklist with forty cases should not feel like forty things shouting. Visual quiet is what makes the one urgent thing visible when it appears.

**Instant severity legibility.** A critical finding should be locatable by peripheral vision, before a deliberate scan — within a single saccade. This is the one place where the design is allowed to be loud, and it is only loud because everything else is quiet.

### 2.2 Anti-goals

Written down because they are what the constraints elsewhere in this system exist to enforce:

- **No delight.** No easter eggs, no personality in microcopy, no animated flourish on success. A tool used for eight hours a day under time pressure has a delight budget of zero.
- **No gamification.** No streaks, no completion celebrations, no progress rewards. Throughput pressure in radiology is already a patient-safety concern; the interface must not add to it.
- **No marketing surface.** No gradients, no hero imagery, no decorative color.
- **No alarm fatigue.** Every urgent signal spends down a finite budget of attention. See §5.2.

---

## 3. Color as meaning

### 3.1 Why navy is the ground of clinical authority

The chrome — app bar, navigation, panel frames — is deep navy. Three arguments, in order of how load-bearing they are:

**It does not compete with the diagnostic canvas.** Medical image data is displayed on black. If the application chrome were also black, the boundary between "interface" and "evidence" would blur exactly where it most needs to be sharp. Navy is the darkest chrome that still reads as *deliberate color* rather than as absence of light. The user can always tell, pre-attentively, which pixels are the app and which are the patient.

**It reads as "system," not "content."** Blue-family chrome is the established idiom of medical instrumentation and PACS software. Borrowing that idiom means the chrome is understood as framing rather than as information, which frees the user's attention for the content inside it.

**It is far from every clinical signal hue.** Navy sits nowhere near the greens, ambers, and reds that carry severity. No piece of chrome can ever be misread as a finding.

The alternatives fail concretely, not just aesthetically. Black chrome competes with the canvas. White or light-grey chrome is a glare source in a 25-lux room. A warm or green brand would collide with the severity system — the moment a brand color and a severity color are neighbours in hue, every severity indicator becomes slightly ambiguous.

### 3.2 The chroma budget

The chrome is **low-chroma by rule.** This is the mechanism, not a style preference: saturated color is a rationed resource, and every saturated pixel spent on decoration is stolen from a severity chip.

An interface where the navigation is vivid, the buttons are vivid, and the badges are vivid has no way left to say *this one matters*. Restraint everywhere else is what buys the severity system its power.

### 3.3 The closed palette

No new colors may be added. When the color you want does not exist, the correct move is to find the token whose **purpose** matches your intent — not to approximate a hex value.

This is not bureaucratic tidiness. A closed palette is the enforcement mechanism for §3.2. Once anyone can add a color, the chroma budget has no accounting, and clinical color stops being meaningful within about two quarters.

### 3.4 Why the page is off-white and not white

The page ground is slightly darker than the cards that sit on it. That inverts the naive arrangement, and it is deliberate: cards earn attention by being *brighter than their surround*. It is the cheapest hierarchy signal available — no border, no shadow, no color required — and it survives inversion into dark mode, where the same relationship simply runs the other way.

### 3.5 Two color systems, deliberately separate

**Clinical severity** answers *how urgent is this finding?* **App status** answers *did this operation succeed?*

These stay separate systems even where their hues coincide, for three reasons:

1. They answer different questions, and a reader who has learned one mapping should not have to disambiguate by context.
2. The consequences of misreading differ by orders of magnitude. A misread upload-failure banner costs a retry. A misread severity chip costs a missed finding.
3. They must be able to diverge later without a rename. If severity red and error red are the same token, the first time clinical review asks for a different critical red, every error state changes with it.

**Rule: the two systems never appear inside the same component.**

### 3.6 Severity is never carried by hue alone

Roughly 8% of men have some form of red-green color vision deficiency, and the normal/critical pair — green and red — is precisely the canonical failure case.

The obvious mitigation is to make severity monotonic in lightness as well as hue, so the level survives as a brightness ordering. **We tested this and rejected it.** Holding the WCAG floor on each tinted container across four hues leaves the four foregrounds separated by roughly 0.007 in relative luminance — a difference that is not perceptible. Lightness ordering cannot be made to carry severity without breaking contrast somewhere else.

So the mitigation is redundant encoding in channels that actually work:

- Every severity indicator carries a **text label**.
- Every severity indicator carries a **distinct icon shape**, and the shapes differ in silhouette, not merely in detail.
- A severity dot is **never the sole carrier** of severity — it always accompanies a label or, at minimum, a tooltip.

Hue remains, and it remains useful for the majority who can use it. It is simply never the only thing present. This also covers the uncalibrated-secondary-monitor case, which is common and which no amount of careful color choice can fix.

### 3.7 The diagnostic image is not part of the UI palette

Pixel data is **evidence**. It follows that:

- No application color may tint, overlay, or bleed into image data.
- The canvas surround is dark in **both** light and dark mode. It is not themed, because the perceived contrast of an image depends on what surrounds it, and that must not change with a user preference.
- Heatmap and overlay ramps use a **dedicated perceptual ramp**, never repurposed status or severity colors.

That last rule has a live violation: the heatmap viewer currently builds its overlay gradient from app-status colors. It is recorded as a known gap in `design_tokens.md`.

---

## 4. Typography as hierarchy

### 4.1 The three voices

| Voice | Typeface | Role |
|---|---|---|
| **Display** | IBM Plex Sans | Structure and authority — anything that names or frames a region |
| **Body** | Inter | Sustained clinical reading |
| **Mono** | IBM Plex Mono | Machine truth — anything transcribable |

Plex Sans is institutional rather than friendly, which is the register §2.1 asks for; it is also metric-matched to Plex Mono, so the framing and data voices share design DNA. Inter has the largest x-height and aperture of the faces considered, which is what carries 14px prose in a dim room.

### 4.2 Why the mono voice is a safety feature

A study UID, accession number, or measurement that a clinician transcribes into a report must be unambiguous. `0` versus `O`; `1` versus `l` versus `I`. Mono signals *this string is data — copy it exactly*, and its letterforms are drawn so the distinction survives.

**Rule: any value a human might transcribe renders in the mono voice.**

### 4.3 Legibility features must be requested, not assumed

Choosing a typeface with good disambiguation accomplishes nothing on its own — the features are inert unless explicitly enabled. Two specifics, both verified against the shipped font files:

**Inter's digits are proportional by default.** Its `1` is materially narrower than its `0`. In a worklist column, that means numbers shift horizontally as values change, which destroys the vertical alignment that makes a column scannable. Tabular figures must be requested for every numeric context. Prose is the exception — tabular figures read wrong mid-sentence.

**Inter's disambiguation set is opt-in.** The letterforms that separate `I`, `l`, and `1` and slash the zero are a stylistic set that must be switched on. It belongs on identifiers and data, and stays off in running text where altered letterforms are a distraction.

Plex Mono needs neither: being monospaced, its figures are inherently tabular. It only needs its slashed zero enabled.

### 4.4 Weight is rank, size is scope

Two independent axes:

- **Size** says how much of the interface this text governs — a page, a section, a row.
- **Weight** says how important it is within its scope.

Keeping them independent is what stops contributors reaching for a bigger size when what they mean is "this matters more." A 14px semibold label and a 14px regular value are the same scope at different ranks, and that is a legitimate, frequently correct construction.

### 4.5 The reading contract

- **12px is the floor for any clinical string.** The 11px caption style is reserved for non-clinical metadata — timestamps, attribution, fine print. If a clinician has to read it to do their job, it is not a caption.
- Line height stays generous for body copy. Dense does not mean cramped; §7.1 is about how much fits on screen, not about how tightly set the text is.
- Measure is capped. Long clinical prose in a wide panel must not run to 140-character lines. Aim for 60–80 characters.

### 4.6 Clinical strings never truncate silently

An ellipsis is a claim that the hidden part does not matter. For a clinical string that claim is false, and it is dangerous in a specific way: **a truncated identifier still looks like a complete value.** A reader who transcribes `1.2.840.113619.2.55.3…` has no signal that they have copied a fragment. This defeats the entire purpose of the mono voice (§4.2) — there is no point guaranteeing a UID is unambiguous if the row cuts it off.

The rule:

- **Identifiers, measurements, and values may never be truncated.** They wrap, or the layout gives them the room. If neither is possible, the layout is wrong.
- **Descriptive clinical text may clamp to a line count** — a findings list is an index, and long descriptions have to fit — but only when the full value is reachable without losing the reader's place: a tooltip, an expand affordance, or a detail view one tap away. Clamped text also carries its full value to assistive technology.
- **Non-clinical text may truncate freely.** Conversation titles, section labels, and navigation entries are wayfinding, not evidence.

The test: *if a clinician transcribed what is visible, could they be wrong without knowing it?* If yes, it cannot truncate.

### 4.7 Never faux-bold

When a requested weight has no real font file, the renderer synthesizes one by artificially thickening strokes. This degrades stroke contrast and distorts letterforms — precisely the qualities §4.2 depends on.

**Rule: only weights backed by a real font file may be requested.** Every weight in the type scale is registered as an actual file.

### 4.8 Typefaces considered and rejected

Recorded so the stack is not re-litigated:

| Candidate | Why not |
|---|---|
| **Satoshi** | ITF Free Font License, not OFL. Forbids redistributing the font files and requires written consent to self-host as a webfont — incompatible with committing files to a repo and serving them from a web build. |
| **Quicksand** | Documented irregular numeral kerning and curve defects on `0` and `8`. A rounded display face in the friendly register §2.2 rules out. |
| **Sora** | Low x-height; weak for sustained prose at 14px. |
| **Lexend** | Genuine reading-science credentials, and the right choice for a patient-facing tool. Its wide tracking and expanded proportions cost the column density a worklist needs. |
| **Space Grotesk** | Strong display voice, but trend-adjacent in a way a clinical instrument should not age into. |

---

## 5. How typography and color interact

This section is the core of the document. Neither type nor color establishes hierarchy alone — each rank is defined by a **pairing** of the two.

### 5.1 Five layers

| Layer | Type treatment | Color treatment | Answers |
|---|---|---|---|
| **1 — Ground** | — | Lowest-contrast surface | "Where am I?" |
| **2 — Structure** | Display voice, semibold | Chrome navy, or a brand surface | "What region is this?" |
| **3 — Content** | Body voice, regular, generous leading | Neutral text ramp on neutral ground | "What does it say?" |
| **4 — Emphasis** | Semibold, *same size as its context* | Accent, or a step up in lightness | "What should I look at next?" |
| **5 — Alarm** | Label voice, small, high weight | Full-chroma severity pair | "What must I not miss?" |

### 5.2 At most one Layer-5 element per viewport

If a screen would show two alarms, the design is wrong — aggregate them into one. "3 critical findings" is one Layer-5 element; three separate critical chips are three, and three alarms are indistinguishable from none.

This is the concrete, checkable mechanism behind the alarm-fatigue anti-goal in §2.2.

### 5.3 The two channels cannot substitute for each other

A red 11px caption is **not** more urgent than a 16px neutral heading, and a heading is **not** made urgent by tinting it. Each layer requires *both* of its treatments. Half a layer is a bug.

The most common way this rule gets broken: reaching for a status color to add emphasis to text that is not, in fact, a status. That is Layer 4 work, and Layer 4 uses accent or lightness — never a clinical or status hue.

### 5.4 Worked example: a finding row

A row in the findings list contains four elements at three different layers:

| Element | Layer | Why |
|---|---|---|
| Row background and divider | 1 | Ground. Carries no information; exists to separate. |
| Finding description | 3 | Content. Body voice, neutral. The thing you actually read. |
| Location / measurement metadata | 3, one step down | Same layer, lower rank — smaller and lighter, because it qualifies the finding rather than stating it. |
| Severity chip | 5 | Alarm. Small, high-weight label voice in a full-chroma pair. |

The chip is physically the smallest element in the row and wins the eye anyway. That works *only* because layers 1 and 3 are low-chroma. Tint the row background, or color the finding text, and the chip stops being findable in peripheral vision.

This is the whole system in one row: **restraint everywhere else is what makes the one loud thing work.**

---

## 6. Light and dark: two grounds, one system

### 6.1 Dark mode is a functional requirement

Radiologists dim the room to raise effective contrast on the diagnostic display and eliminate reflected glare. A bright secondary interface beside a dark diagnostic display forces the eye to re-adapt every time attention moves between them — repeatedly, for hours.

That is measurable fatigue, not a preference. **Dark mode is therefore a functional requirement of this product, not a feature.**

### 6.2 Inversion is not negation

Across modes:

| Invariant | Variant |
|---|---|
| Meaning of every token | Luminance relationships |
| Rank in the perceptual hierarchy | How depth is encoded |
| Geometry — spacing, radius, target size | Accent lift |
| Motion | Severity contrast strategy |
| Every semantic token **name** | |

A component's *description* should be identical in both modes. Only the values move.

### 6.3 Depth on a dark ground is luminance, not shadow

Shadows are close to invisible on dark surfaces. In dark mode, elevation is expressed as a **step up in surface lightness**, with a hairline border at the highest steps.

This has a non-obvious consequence: elevation is not a purely structural property. Its geometry is mode-independent, but how it *renders* is not.

### 6.4 No pure black, no pure white

Pure black around a medical image alters the perceived contrast of the image itself — the surround is part of what the eye calibrates against. And near-white text on near-black halates, blooming into the background and reducing effective sharpness.

Both grounds stay off their extremes. The dark ground sits at **L\* 6.1**, where primary text lands at 15.0:1 — dark enough that a dimmed room does not fight it, light enough that the text stays crisp. Below roughly L\* 5 the same text passes 15.5:1 and starts to bloom, which costs sharpness rather than adding it; that is the floor, and it is a real one, not a round number.

**Every L\* figure in these documents is computed, never estimated.** The band originally written here was guessed, and nothing in the system satisfied it — see D-012.

### 6.5 Mode selection

**The app opens dark, regardless of the system setting**, and the user can override it.

This is a deliberate departure from the usual convention. §6.1 makes dark mode functional rather than decorative: it exists to stop the eye re-adapting between a bright panel and a dark diagnostic display. An OS preference is set for a different context — a laptop in an office, a phone outdoors — and inheriting it would mean the tool arrives bright in exactly the room it was designed for. A radiologist who wants light can say so once.

The override is remembered per user, and the control lives in Settings (§9, D-013).

**The diagnostic canvas is exempt** from all of this and stays dark in both modes, per §3.7.

---

## 7. Density, motion, cognitive load

### 7.1 Dense where they scan, generous where they decide

Two different tasks need two different densities:

- **Scanning** — worklists, findings lists, metadata tables. The user is looking *for* something. More rows visible means fewer scroll actions and better comparison. These go dense.
- **Deciding** — the chat composer, confirmation actions, onboarding, settings. The user is committing to something. Space reduces error rate. These go generous.

Density is therefore a property of the task, not of the screen size. A worklist stays dense on a phone; a confirmation dialog stays generous on a workstation.

### 7.2 Motion signals state change and never decorates

Every animation must answer "what changed?" A transition that exists to look smooth is spending attention for nothing. Durations are short enough to feel immediate and long enough to be followed.

Reduced-motion preferences are respected — this is an accessibility requirement, not an enhancement.

### 7.3 Interruption design

How things enter the visual field without stealing it:

- **Status** is peripheral and dismissible. It reports on the app, and the app is not what the user is thinking about.
- **Severity** is inline and persistent. It belongs to the content and disappears only when the content does.
- **Nothing is modal** unless the user's next action would otherwise be unsafe. A modal is an interruption with no opt-out, and it should be reserved for cases that genuinely warrant one.

---

## 8. Accessibility as a clinical requirement

### 8.1 Targets

- **WCAG 2.2 AA is the floor, everywhere.** 4.5:1 for normal text, 3:1 for large text and non-text/UI elements.
- **AAA (7:1) is the target for clinical strings.**

### 8.2 What counts as a clinical string

Severity labels, finding descriptions, patient and study identifiers, measurements, dates, and confidence values — anything that could be transcribed, compared, or acted on. When in doubt, it is clinical.

### 8.3 Colour vision deficiency

Per §3.6: redundant encoding via label and icon shape. Testable as a rule — a severity indicator with no text label and no distinct shape is a defect regardless of how it looks to trichromatic vision.

### 8.4 Keyboard and pointer

The workstation posture is keyboard-and-mouse. Focus is always visibly indicated, at a minimum of 3:1 against **both** the element and its surrounding surface — a focus ring that only clears contrast against one of them is invisible half the time.

### 8.5 Touch targets

44px minimum in the compact and medium postures. 32px is permitted in expanded, where a mouse is the primary input.

### 8.6 Text scaling

WCAG 1.4.4 requires text to scale to **200% without loss of content or function**, and it is part of the AA floor claimed in §8.1. The OS font-size setting is honoured in full — there is no cap.

That has a real consequence for the dense layouts §7.1 asks for, and the consequence is the design, not a compromise:

- **Dense tables reflow rather than clip.** As scale increases, a multi-column worklist row becomes a stacked card. The information is identical; only the arrangement changes. A table that clips columns, or that forces horizontal scrolling to reach a severity chip, is a 1.4.4 failure.
- **Nothing is sized in a way that scaling can break.** Fixed-height rows, single-line clamps on text that will grow, and containers that cannot expand are all defects. Height follows content.
- **Layout tiers respond to scale, not just to window width.** A workstation at 200% has the effective text density of a tablet, and should get the tablet's arrangement. Tier selection reads the scaled dimension, not the raw one.
- **Touch targets never shrink.** They may grow with scale; they may not be traded away for density.

The reflow point is therefore not a fixed pixel width — it is where the content stops fitting. This is the same reasoning as §9's pane minimums in `design_tokens.md`: layout follows what fits, not what the window measures.

### 8.7 Compliance audit

Measured, not asserted. Every ratio below was computed from the actual token values.

**Brand and neutral pairs — unchanged. All clear AA; all but one clear AAA:**

| Pair | Ratio | |
|---|---|---|
| Primary text on card ground | 17.40 | AAA |
| Text on primary-tinted surface | 15.97 | AAA |
| Primary text on page ground | 15.82 | AAA |
| Text on secondary-tinted surface | 13.51 | AAA |
| Text on brand-dark surface | 12.98 | AAA |
| Text on accent-tinted surface | 11.53 | AAA |
| Text on secondary brand-dark surface | 10.07 | AAA |
| Secondary text on page ground | 8.06 | AAA |
| Foreground on primary action fill | 7.53 | AAA |
| Tertiary text on page ground | 5.46 | AA — not AAA, so not for clinical strings |

**Severity and status — remediation now has real colors, not yet applied to the code.** These are not brand colors, and every one of them failed. A clinical severity label at 2.44:1 is not defensible in a medical tool. This table used to specify each fix as a target ratio only — no hex had actually been chosen. That gap is closed:

| Pair | Color | On container | On page | Measured today |
|---|---|---|---|---|
| Normal severity / Success status | `#276A43` | 5.43 ✓ | 5.91 ✓ | 4.21 ✗ |
| Mild severity | `#02639E` | 5.38 ✓ | 5.82 ✓ | 4.03 ✗ |
| Moderate severity / Warning status | `#855B06` | 5.48 ✓ | 5.46 ✓ (6.01 ✓ on white) | 2.44 ✗ |
| Critical severity / Error status | `#A42121` | 6.03 ✓ | 6.78 ✓ | 4.55 ✗ (AA only) |
| Info status | `#23566A` | 7.14 ✓ | 7.31 ✓ (8.04 ✓ on white) | 3.01 ✗ |
| Muted text | `#6E6E6E` | — | 4.64 ✓ | 3.74 ✗ |

**Info status is not Mild severity.** They read as the same idea and were treated as one pair while only a ratio existed — but the code holds them as genuinely different colors (`statusInfo` is a teal-blue brand accent; `SeverityTokens.mild` is a plain blue). Deriving real hex forced the distinction back into view: Info status gets its own remediation above, independent of Mild's.

Hues were held; only the foregrounds darkened, verified in HLS — every hue shift below 0.4°, saturation held within 0.005. Containers are unchanged.

**A seventh pair, found while deriving these, not in the original six:** `textLinkHover` (`#3D95B8`, shared with `borderFocused` and `interactiveAccent`) measures 3.08:1 on page / 3.39:1 on surface as text — under the 4.5:1 floor, though it clears the 3:1 floor the other two tokens actually need. One raw color was doing four jobs with two different floors; giving text its own value was the only fix that didn't touch the two tokens already passing. New value: `#275F75`, 6.41 ✓ on page, 7.05 ✓ on surface.

The first candidate for this one cleared 4.5:1 by itself and still failed: it landed at L 0.363 against `textLink`'s own L 0.357 — visually the same brightness as the resting link color, which would make hover unreadable as a state change even though the arithmetic passed. Contrast ratio is necessary, not sufficient, for a color that has to be *distinct from its neighbor*, not just legible on its own. The real fix holds a real gap: `#275F75` sits 0.051 below `textLink` in lightness, and the new `#23566A` for Info status sits a further 0.029 below that — a five-step ladder from `#3D95B8` (L 0.480) down to `textLinkVisited` (L 0.165) with no two steps closer than 0.029.

**Resolved:** the default border color measured 1.74:1 against white — fine for a decorative separator, not for any border that carries meaning. See D-016.

**Dark scheme — every pair computed, all passing.** Values in `design_tokens.md` §10.4.

| Pair | Ratio | |
|---|---|---|
| Primary text on page / surface / raised / overlay | 15.04 · 13.93 · 12.71 · 11.46 | AAA |
| Secondary text, across the same four | 9.65 · 8.94 · 8.15 · 7.35 | AAA |
| Tertiary text, across the same four | 6.66 · 6.17 · 5.63 · 5.08 | AA |
| Muted text, across the same four | 6.09 · 5.64 · 5.15 · 4.64 | AA |
| Text on brand surfaces | 12.26 · 10.90 | AAA |
| Accent, link and focus ring | 6.02–7.92 | passes the 3:1 UI floor with margin |
| Meaningful border vs surface / page | 3.15 · 3.40 | passes 3:1 |
| Severity — normal / mild / moderate / critical on their containers | 7.83 · 8.66 · 8.22 · 7.22 | AAA, clinical target met |
| Severity foregrounds against the page | 9.07–11.00 | chips stay legible off their containers |

Two values were replaced during derivation, and the reasons generalise. **Muted text failed at 4.35:1 on the raised surface** — a text ramp that passes on the page can still fail two elevation steps up, so every level of the ladder has to be checked, not just the ground. And **a border that carries meaning has to be far lighter on a dark ground than intuition suggests**: three successive candidates failed 3:1 before `#5E6B7A` cleared it. The decorative separator is a different token and carries no floor.

---

## 9. Decision log

Append-only. Each entry records what was decided, why, and what it forbids.

---

**D-001 — The palette is closed.**
*Why:* Saturated color is the only channel that can carry urgency, and it only works if it is rationed (§3.2).
*Forbids:* Adding colors; inline hex values; approximating a token by appearance rather than purpose.

---

**D-002 — Clinical severity and app status are separate systems.**
*Why:* Different questions, different consequences of misreading, and they must be able to diverge without a rename (§3.5).
*Forbids:* Using a status color for a finding, or a severity color for an operation. Both systems in one component.

---

**D-003 — Severity is never encoded by hue alone.**
*Why:* ~8% of men have red-green CVD, and normal/critical is the canonical failure pair. Lightness ordering was tested as an alternative mitigation and rejected — holding contrast across four hues leaves ~0.007 luminance separation, which is imperceptible (§3.6).
*Forbids:* A severity indicator with no text label and no distinct icon shape. A bare severity dot as sole carrier.

---

**D-004 — The diagnostic canvas is outside the theme.**
*Why:* Pixel data is evidence; the perceived contrast of an image depends on its surround, which must not vary with a user preference (§3.7).
*Forbids:* Theming the canvas. Tinting image data. Building overlay ramps from status or severity colors.

---

**D-005 — Dark mode is a functional requirement.**
*Why:* Repeated pupil re-adaptation between a bright UI and a dark diagnostic display is measurable fatigue across a shift (§6.1).
*Forbids:* Light-only components. Hardcoded colors that cannot respond to mode.

---

**D-006 — Type stack is IBM Plex Sans / Inter / IBM Plex Mono.**
*Why:* Inter ships verified disambiguation and tabular-figure support and has the largest x-height of the candidates; Plex Sans is institutional in register and metric-matched to Plex Mono. All three are SIL OFL, so they can be committed and self-hosted (§4.1, §4.7).
*Forbids:* Satoshi, on licensing. Quicksand, on numeral defects. Requesting a font weight with no real file behind it.

---

**D-007 — The display scale sits above the body scale.**
*Why:* Inter's x-height (0.546 em) exceeds IBM Plex Sans's (0.516 em). At equal nominal size the body face out-measures a heading, inverting Layer 2 against Layer 3. The smallest heading is therefore 18px, not 16px (§5.1).
*Forbids:* Setting a heading at the same nominal size as body text.

---

**D-008 — Severity and status foregrounds were darkened to meet AA.**
*Why:* Six pairs failed WCAG AA, the worst at 2.44:1 on a clinical severity label (§8.6).
*Forbids:* Reverting to the original values. Adding a color pair without computing its ratio.

---

**D-009 — Clinical strings never truncate silently.**
*Why:* A truncated identifier still looks like a complete value, so a reader can transcribe a fragment without any signal that they have (§4.6). This defeats the reason the mono voice exists.
*Forbids:* Ellipsizing an identifier, measurement, or value. Clamping descriptive clinical text without a reachable full value. Applies regardless of how unlikely overflow seems.

---

**D-010 — Text scales to 200% with no cap; dense tables reflow.**
*Why:* WCAG 1.4.4 is part of the AA floor already claimed, and capping scale would be a documented failure (§8.6). Reflowing preserves every piece of information; clipping does not.
*Forbids:* A scale ceiling. Fixed-height rows. Single-line clamps on text that grows. Horizontal scrolling to reach content. Trading touch-target size for density.

---

**D-011 — Layout tiers are driven by pane-composition minimums, not a single breakpoint.**
*Why:* A single split at 768px produced a 168px chat column once navigation and a side panel were subtracted. Tier names drive nav pattern and density; pane minimums drive layout.
*Forbids:* Adding a raw pixel breakpoint. Making a layout decision from window size rather than local constraints.

---

**D-012 — The dark ground sits at L\* 6.1, and every L\* figure is computed.**
*Why:* The range first written into `design_tokens.md` §10.4 — "roughly L\* 9–12" — was guessed before any value existed, and nothing in the system satisfied it. Raising the ground into that band would have cost reading-room benefit and broken two tokens at the higher elevation steps (a meaningful border at 2.41:1, muted text at 4.32:1). The intent behind the range survives; the number did not (§6.4).
*Forbids:* Quoting an L\* value that has not been computed. A ground below roughly L\* 5, where primary text begins to bloom. Checking a text ramp against the page alone rather than every step of the elevation ladder.

---

**D-013 — The app opens dark regardless of the system setting.**
*Why:* Dark mode here is functional, not decorative (§6.1). An OS preference is set for a different room; inheriting it delivers a bright panel into the one context the design exists to serve (§6.5).
*Forbids:* Defaulting to the system preference. Removing the user override, or failing to remember it.

---

**D-014 — Severity, status, and link-hover remediation are real colors now, not target ratios.**
*Why:* D-008 said these foregrounds "were darkened" and forbade reverting to the originals — past tense, as if done. No hex had actually been chosen; only a target ratio existed per pair (§8.7). Deriving the colors surfaced two things a ratio alone couldn't: `statusInfo` and `SeverityTokens.mild` are different colors that had been treated as one pair, and `textLinkHover` — found only now, not in D-008's original six — shares a raw value with `borderFocused` and `interactiveAccent`, tokens that need a 3:1 floor rather than text's 4.5:1. The first candidate for the shared value cleared 4.5:1 and still failed: at L 0.363 it was visually the same brightness as `textLink` (L 0.357), which would make a hover state unreadable as a state change regardless of what the ratio said.
*Forbids:* Treating a target ratio as a closed gap when no color implements it. Deriving a replacement foreground by contrast alone without checking its lightness against every token it sits next to in the same family. Sharing one raw palette value across tokens that carry different contrast floors without checking each one separately.

---

**D-015 — The RadAsk mark uses only the four brand-reference tokens, and the dark badge is monochrome because of it.**
*Why:* An early logo draft paired a bright cyan with a near-black navy — neither was `brandPrimary`/`brandSecondary`/`brandAccent`/`brandLight` (§2.7), so the mark didn't read as this app's brand at all. Rebuilding it from the actual four surfaced that they don't all combine freely: `brandAccent` and `brandSecondary` are tuned as accents on light surfaces, and both measure under 2:1 against `brandPrimary` — nowhere near the 3:1 floor for a graphical object, let alone 4.5:1 for text. Only `brandLight` clears `brandPrimary` (12.98:1). The primary lockup (`assets/brand/logo-full.svg`) stays two-tone — `brandPrimary` + `brandAccent` — on a light ground, exactly where the tokens support it; the reversed badge for dark grounds (`logo-reversed.svg`) goes monochrome `brandLight`-on-`brandPrimary` rather than inventing a fifth color to preserve a two-tone look the palette doesn't actually clear. Full derivation and numbers: `assets/brand/README.md`.
*Forbids:* Pairing `brandAccent` or `brandSecondary` directly against `brandPrimary` for anything that needs to be seen — text, icon strokes, a graphical object. Adding a new brand color to make a dark-ground lockup two-tone instead of going monochrome with `brandLight`.

---

**D-016 — The default border is a meaningful-border token, not a decorative one; `borderSubdued` carries the decorative role alone.**
*Why:* `border` (`#C4C4C4`) measured 1.74:1 on surface — fine as a hairline, not for anything a user relies on seeing: the input field's resting outline, `AppButton`'s secondary variant, Material's `ColorScheme.outline`. Dark mode had already solved this exact problem for its own `border` (`#5E6B7A`, 3.15:1, "meaningful borders only") without light mode ever following suit. `gray500` (`#7D7D7D`) is the lightest existing palette step that clears 3:1 against both `surfacePage` and `surface` — 3.74:1 and 4.12:1 — so `border` moves there rather than to a newly-minted hex. Nothing in production actually relied on `border` reading as a faint decorative hairline; `AppDivider`, the one genuinely decorative consumer, already defaulted to `borderSubdued`.
*Forbids:* Using `border` for a purely decorative separator now that it carries a contrast floor — that is what `borderSubdued` is for. Reverting toward `gray300` to make the border "lighter" without re-deriving a value that still clears 3:1.

---

**D-017 — Tooltip surface flips: near-black navy in light mode, the elevation ladder's own top step in dark mode.**
*Why:* Light mode's tooltip (`deepNavy900`, `#061625`) works by inverting against a light page — a small, unmistakably dark chip that reads as a floating overlay, deliberately darker than `surfaceBrand` so it isn't mistaken for a stray piece of header chrome. Dark mode's page is already nearly as dark (computed contrast between `deepNavy900` and `surfacePage`, `#0E141B`, is ≈1.01 — no separation at all), so carrying the same value over would make the tooltip disappear into the page. `surfaceOverlay` (`#232C38`), the dark elevation ladder's own topmost, lightest step (§10.4), is already the most-elevated surface this app defines — matching a tooltip's topmost z-order — and gives real, if modest, separation from the page (≈1.31). No new palette entry: both the light value and the dark reuse already exist for other purposes.
*Forbids:* Deriving a bespoke "even darker than brand" navy for dark mode by mechanically porting light mode's darker-than-header relationship — dark mode's ambient tone is already near-black, so that relationship doesn't transfer, and would under-contrast against the page.

---

**D-018 — `NavigationTokens.sideNavHoverColor` gets a real dark value, matching its own light-mode magnitude rather than a stricter floor.**
*Why:* Every other `NavigationTokens` color member resolves through `context.colors`; this one stayed a flat `static const` because no dark value had been derived (§6). Computing the light-mode precedent directly showed it was never a contrast-floor color to begin with — `mediumNavy` → `mediumNavy600` is 1.42:1, a subtle "one step brighter" wash, not a border- or focus-ring-grade signal. The dark value holds `surfaceBrandSecondary`'s own hue (212.6°) and saturation (0.46) exactly and lifts lightness by the same step, landing at 1.43:1 against it — the same relationship, not a new one.
*Forbids:* Deriving a stronger, contrast-floor-driven value for this token without first revisiting whether hover states are meant to carry that much weight — this app's only other hover mechanism (`AppInteraction.hoverOverlayOpacity`) is a 6% alpha wash with no contrast target either, and this token should stay consistent with that, not become the one hover state held to a stricter bar than the rest.

---

**D-019 — The Case List worklist has one column set and one 1440 ceiling from `threePaneMinWidth` up; ultrawide adds neither.**
*Why:* §9.5 first said ultrawide "adds columns" and "caps 1440". Checked against the code, neither held as written. The table already shows patient, modality, date, confidence, and severity, which is every user-facing field `CaseSummary` carries (the study `title` appears on the card list; `id` is internal), so tier-gated extra columns would be specified against data that does not exist. And the cap already applies at every wide width, binding from about 1504px (1440 plus the 64px `MenuRail`); restricting it to ultrawide would let the table reach about 1535px at 1599 and then narrow to 1440 at 1600, so the worklist would get smaller as the window got larger.
*Forbids:* Specifying or building worklist columns that have no field behind them, or gating them on the tier alone. A width ceiling that is not monotonic: one that makes the table narrower as the window grows. If the backend later exposes more worklist fields, extra columns are a new decision, and probably one for every wide width rather than only ultrawide.

---

**D-020 — The Heatmap Viewer shows the whole study, and its overlay is laid out against the image, not the canvas.**
*Why:* The canvas filled itself with the image using `BoxFit.cover`, which crops the study to whatever box the window gives it. Measured with the real 1024×1024 chest X-ray: only 51% of the image is visible on a phone's 411×802 canvas (49% at 390×788), and 51% of its height on the 960×600 tablet's 960×488 canvas, so the lateral lung fields and the image edges, where findings sit, are cut away. §3.7 says pixel data is evidence; a viewer that silently discards half of it fails that, and the dark ground around the image is already specified to carry whatever the image does not fill. The overlay is a second cause. `LungHeatmapOverlay` draws its lung regions as fractions of the image *frame*, but it was laid out against the canvas, so whenever the canvas's aspect differed from the image's it sat on the wrong anatomy, crop or no crop. So the image and the overlay share one rect, the image's own, letterboxed on `diagnosticCanvasGround`; its aspect ratio comes from the study (`HeatmapData.imageAspectRatio`, which a DICOM image always has).
*Forbids:* Cropping diagnostic pixels to fill the canvas (`BoxFit.cover` on a study image, here or anywhere a study is shown), and laying an overlay out against the canvas rather than the image. The cost is accepted: on a phone a square or landscape study is shown smaller, with ground above and below it. Zoom and pan are a separate decision, not a reason to crop.
