# Atomic Design — Radiologist Helper Chatbot

This document defines how every UI element in the app is classified within the atomic design hierarchy. Use it to decide where a new widget belongs, how to name it, and what it is allowed to depend on. This document describes **structure and composition** only — it does not specify colors, spacing, or typography values.

---

## Hierarchy overview

| Level | What it is | Flutter analogy | Can depend on |
|---|---|---|---|
| **Atom** | Smallest indivisible UI element | A single Material widget or thin wrapper | Nothing (standalone) |
| **Molecule** | A small group of atoms functioning as a unit | A `Row`/`Column` composing 2–4 atoms | Atoms only |
| **Organism** | A distinct section of the UI with its own responsibility | A self-contained panel or list | Atoms and molecules |
| **Template** | A page skeleton defining layout zones without real data | A `Scaffold` with placeholder slots | Organisms, molecules, atoms |
| **Page** | A template filled with real data, state, and navigation | A routed screen with a controller/provider | Templates (one each) |

Each level can only depend on levels below it. A molecule never wraps an organism. An atom never contains a molecule.

---

## Atoms

Atoms are the smallest visual building blocks. Each atom maps to exactly one Material widget or a minimal stateless wrapper around one. An atom has **no business logic** and **no knowledge of its siblings**.

### Catalog of atoms in this app

| Atom | Base widget | Purpose in this app |
|---|---|---|
| `AppText` | `Text` | Renders a string with a named style. Accepts a style variant and optional color override. |
| `AppIcon` | `Icon` | Wraps `Icon` with constrained size and semantic label. |
| `AppButton` | `ElevatedButton` / `TextButton` / `IconButton` | Single-action trigger. Variants: primary, secondary, ghost, icon-only. |
| `AppTextField` | `TextField` | Text input with decoration. Does not manage its own controller. |
| `AppAvatar` | `CircleAvatar` | Circular image or initials for user/assistant identity. |
| `AppBadge` | `Container` + `Text` | Small label showing a count or short status word. |
| `AppDivider` | `Divider` | Horizontal or vertical separator line. |
| `AppLoadingIndicator` | `CircularProgressIndicator` | Indeterminate spinner. |
| `AppChip` | `Chip` / `FilterChip` | Compact label with optional dismiss or selection. Used for tags and filters. |
| `AppImage` | `Image` / `CachedNetworkImage` | Displays raster images (X-ray thumbnails, avatars). Handles loading and error states. |
| `AppTabBar` | `DefaultTabController` + `TabBar` + `TabBarView` | Labeled tab strip with its paired content views. Used by `StudyReviewTemplate`'s narrower tiers to switch between Findings and Chat. |
| `SeverityDot` | `Container` (circle) | A small colored dot indicating finding severity level. |
| `AppLogo` | `SvgPicture` (`flutter_svg`) | The RadAsk brand mark (bubble icon, optionally with wordmark). Loads a static SVG with brand colors baked in — mode-invariant, never `context.colors`. |
| `LungHeatmapOverlay` | `CustomPaint` | Paints the Heatmap Viewer's "AI attention" overlay as two lung-shaped regions with a per-finding focal point, instead of a flat colored rectangle. |

### Rules for atoms

- One file per atom, located in `lib/ui/atoms/`.
- File name matches widget name in snake_case (`app_button.dart`).
- No imports from `molecules/`, `organisms/`, `templates/`, or `pages/`.
- Accept all visual configuration through constructor parameters — never read from global state.
- Stateless unless managing a trivial internal concern (e.g., hover highlight).

---

## Molecules

A molecule is a purposeful grouping of 2–4 atoms that forms a single conceptual unit. It handles the layout between its atoms but still has **no business logic**.

### Catalog of molecules in this app

| Molecule | Composed of | Purpose |
|---|---|---|
| `ChatBubble` | `AppText`, `AppAvatar` (optional), `AppIcon` (case-reference chips) | A single message bubble — user or assistant. Responsible for alignment, shape, and text rendering. Case references render as small tappable chips below the message, composed internally from atoms rather than as a separate molecule — it had exactly one caller. A `ChatMessageStatus.failed` reply gets a short "Reply failed" caption below it in `statusError`; `streaming` and `complete` look identical, since the text growing is the signal. |
| `ChatInput` | `AppTextField`, `AppButton` (send), `AppIcon` (attach) | The message composition bar at the bottom of the chat. Exposes an `onSubmit` callback. |
| `SeverityChip` | `SeverityDot`, `AppText` | Displays a severity level as a compact labeled chip (e.g., "MODERATE" with a colored dot). |
| `FindingRow` | `AppText` (finding name), `SeverityChip`, `AppIcon` (expand) | A single finding line item in a findings list. |
| `NavItem` | `AppIcon`, `AppText`, `AppBadge` (optional) | A single navigation destination (icon + label) used inside bottom nav or drawer. An optional `badgeLabel` follows the label on the warning pair — the Review destination's count of images needing review (DL D-021). |
| `MetadataField` | `AppText` (label), `AppText` (value) | A key-value pair for displaying DICOM metadata or study info (label left, value right). |
| `StatusBanner` | `AppIcon`, `AppText`, `AppButton` (optional action) | A horizontal banner communicating a status message (info, warning, error). |
| `TypingIndicator` | `AppLoadingIndicator` or animated dots | Shows that the assistant is generating a response. |
| `ImageThumbnail` | `AppImage`, `AppBadge` (optional) | An X-ray thumbnail with an optional badge overlay (e.g., "3 findings"). The study is letterboxed whole on `diagnosticCanvasGround`, never cropped (DL D-020). |
| `HubActionCard` | `AppIcon`, `AppText` (title), `AppText` (description) | One of the Home Hub's big primary choices (upload a study, view studies, chat) — icon, title, description, the whole card tappable. |
| `UploadZone` | `AppIcon`/`AppLoadingIndicator`, `AppText` | The Upload screen's one interactive area — a tappable zone carrying its idle/uploading/analyzing states. |
| `SectionCard` | `AppText` (title) | A titled card: a heading above arbitrary content, in the app's standard raised-surface chrome. Frames each section of a list (e.g. `SettingsTemplate`'s single-column and content-pane layouts). |
| `SectionIndexTile` | `AppText` | One row of a title index — a list of section names beside their content, as in `SettingsTemplate`'s expanded-tier layout. Highlights when selected and reports taps; the caller owns which index is selected. |
| `ThemeModeSelector` | `AppIcon` (check mark), `AppText` | The Settings Appearance section's theme picker. Always exactly three rows, Dark/Light/System in that order (DL D-013). |
| `SimilarCasesCountHeader` | `AppText` (heading), `AppText` (basis, optional) | The "N similar cases found" header above Similar Cases' results. Owns pluralization and token choice — the page passes only the counts. When the search used only part of the study, a second line says so: "Based on 2 of 3 images; 1 held back for review". |
| `ReviewStatusChip` | `AppIcon`, `AppText` | Where an image's review stands — Needs review, Processing, Applied — each on its status pair with a label and an icon of its own shape, never hue alone. App status, never inside a component that shows severity (DL D-021). |
| `CaptionedImage` | `AppImage`, `AppText` | A study image letterboxed whole with its caption below the pixels, never over them (DL §3.7, D-020). Sits on the Image Review canvas, under that template's forced dark theme. |

### Rules for molecules

- One file per molecule, located in `lib/ui/molecules/`.
- May import from `atoms/` only.
- Accept data through constructor parameters. Use callbacks (`VoidCallback`, `ValueChanged<T>`) for user interactions — never call a service or repository directly.
- A molecule should be understandable in isolation: if you removed it from its parent organism, its purpose should still be clear.

---

## Organisms

An organism is a self-contained section of the interface that fulfills a distinct responsibility. It composes molecules and atoms into a functional region. An organism **may** hold local UI state (scroll position, expanded/collapsed) but must **not** own business state.

### Catalog of organisms in this app

| Organism | Composed of | Purpose |
|---|---|---|
| `ChatMessageList` | `ChatBubble` (many), `TypingIndicator` | The scrollable list of all messages in a conversation. Handles scroll-to-bottom, date separators, and grouping. A `streaming` reply with no text yet renders as the `TypingIndicator`; text growing in place follows the bottom only while the reader is already within a few lines of it, and never yanks someone who has scrolled up. |
| `ChatPanel` | `ChatMessageList`, `ChatInput` | The full chat area: message list + input bar. This is the primary interaction surface. |
| `FindingsPanel` | `FindingRow` (many), `AppText` (section header) | A collapsible panel listing all AI-generated findings for the current study, grouped by region or severity. |
| `StudyInfoCard` | `MetadataField` (many), `ImageThumbnail`, `AppText` (title) | Displays study metadata: patient pseudonym, modality, date, study UID, and a representative thumbnail. |
| `ConversationDrawer` | `NavItem` (many), `AppAvatar`, `AppText` | Side drawer listing past conversations. Each item shows a summary and timestamp. Its bottom row is "Settings" (`onSettings`, Chat/Study Review's `drawer` slot at `compact`/`medium`) or "Menu" (`onMenuTap`, opens `PrimaryNavDrawer` — the same instance's `drawerWide` slot at `expanded`/`ultrawide`, where there's no app bar left to host a hamburger). |
| `AppNavBar` | `NavigationBar`/`NavigationDestination` (native), `AppBadge` | Bottom navigation bar with destinations: Home, Chat, Studies, Review, Settings. Review carries the required `pendingReviewCount` as an `AppBadge` over its icon, none at 0 (DL D-021). Mounted on Chat, Case List, Review and Settings via each template's optional `navBar` slot at `compact`/`medium` — Home pops to the root; the others use `pushReplacement` to keep the stack flat, all through `openPrimaryDestination`. |
| `PrimaryNavDrawer` | `NavItem` (many, horizontal layout) | The same Home/Chat/Studies/Review/Settings destinations as `AppNavBar`, as a drawer instead of a bottom bar, with the same required `pendingReviewCount` badged on Review. Mounted via each template's `primaryNavDrawer` slot at `expanded`/`ultrawide` only (all five nav-shell templates now: Chat, Case List, Settings, Study Review, Home Hub), where it replaces both `navBar` and the app bar (removed entirely at this tier) — opened via the "Menu" row in `ConversationDrawer`/`MenuRail` instead. Also mounted on `SimilarCasesPage` (a drill-down page like Study Review, `selectedIndex: null`, so it isn't itself highlighted) so the page keeps a way back once its app bar hides. Distinct from `ConversationDrawer` (conversation history, Chat/Study Review only). |
| `MenuRail` | `NavItem` (vertical layout) | A narrow (`sideNavCollapsedWidth`) persistent column carrying just the "Menu" trigger that opens `PrimaryNavDrawer`, for pages with no `ConversationDrawer` to repurpose the way Chat/Study Review do: Case List, Review, Settings, and Home Hub at `expanded`/`ultrawide`, plus `SimilarCasesPage` (reached from Study Review, delegates to `CaseListTemplate`). Distinct from `CollapsedNavRail` (opens `ConversationDrawer`/findings overlays, Chat's `medium` tier only). |
| `StatusBar` | `StatusBanner` | Persistent bar at the top of the screen showing connectivity or system status. |
| `OnboardingCarousel` | `AppImage`, `AppText`, `AppButton` | A swipeable set of introductory slides shown on first launch. |
| `CaseWorklistTable` | `AppText` (cells), `SeverityChip` | The dense, sortable worklist table DT §9.5 specifies for Case List at expanded and up. Built on Flutter's own `DataTable`, sortable by any column, no default sort. Its Review column says what each study holds back for review ("1 awaiting review") from the required `heldBack` map, as plain text since the row carries severity (DL D-022). |
| `ImageReviewPanel` | `ReviewStatusChip`, `SectionCard`, `MetadataField`, `StatusBanner`, `AppButton`, `AppTextField`, `AppText` | Why an image was flagged and both recorded labels, then either the decision form or what was decided, by whom and when, with Change decision. The form offers the six views, Unusable, and "Recorded view is correct" only when the labels agree; the choices matching each label are tagged. Read-only for anyone but a radiologist. Local state only: the choice, the note, whether the form is open. |
| `ImageReviewTable` | `ReviewStatusChip`, `AppText` (cells) | The review queue at expanded and up — status, patient, date, reason, recorded labels, decision — on the same `DataTable` as `CaseWorklistTable`. Not sortable: rows keep the queue's order, needs review first. |
| `CollapsedNavRail` | `AppIcon` (via an internal `_RailIcon`) | The 64px collapsed nav rail `ChatTemplate`'s `medium` tier uses in place of the full 240px sidebar (DT §9.5) — a trigger strip that opens the existing `ConversationDrawer`/findings panel as overlays, rather than re-rendering either as icon-only content. |
| `DraggableFindingsSheet` | Wraps an externally supplied `child` (typically `FindingsPanel`) | The `compact`-tier findings bottom sheet DT §9.5 specifies as draggable — a `DraggableScrollableSheet` with its own drag handle, independent of `child`'s internal scrolling. |

### Rules for organisms

- One file per organism, located in `lib/ui/organisms/`.
- May import from `atoms/` and `molecules/`.
- Receives data and callbacks from its parent template or page — never fetches data itself.
- May manage local UI state (e.g., which `FindingRow` is expanded) via `StatefulWidget` or a local controller.
- Should be reusable in principle: a `FindingsPanel` could appear both in the main chat view and in a standalone study review page.

---

## Templates

A template is a layout skeleton. It defines **where organisms go on screen** — their spatial arrangement, scroll behavior, and responsive breakpoints — but is filled with placeholder or injected data, not real state.

### Catalog of templates in this app

| Template | Layout zones | Description |
|---|---|---|
| `ChatTemplate` | App bar zone, main body (chat panel), optional side panel (findings) | The primary layout. On narrow screens, the chat panel fills the body and findings appear as a bottom sheet. On wide screens, findings sit in a side panel. |
| `CaseListTemplate` | App bar zone, optional status/header zone, case content zone | Layout for case discovery/history views. Uses list on narrow screens and grid on wide screens. Also composes Similar Cases and the review queue. |
| `ImageReviewTemplate` | App bar zone, diagnostic canvas (flagged image beside the study's other images), details zone (review panel, report) | Layout for deciding about one flagged image. The canvas is `diagnosticCanvasGround` under a forced dark theme, the flagged image in two thirds beside the others at every width. From `twoPaneMinWidth` the details sit in a `panelMaxWidth` column beside it; below, they scroll under a canvas kept at 45% of the height. App bar at every tier. |
| `StudyReviewTemplate` | App bar zone, study info zone (top), findings zone (bottom/side) | Layout for reviewing a completed study outside the chat context. |
| `HeatmapViewerTemplate` | App bar zone, image canvas zone, bottom control zone | Layout for rendering base study image and optional heatmap overlay with externally owned opacity control. Given the image's aspect ratio, it shows the whole image letterboxed on the canvas ground, with the overlay in the same frame (DL D-020). |
| `SettingsTemplate` | App bar zone, scrollable content zone | Single-column list of sections at compact/medium; at expanded/ultrawide, a 200px index rail beside one continuous scroll of every section, where tapping the rail jumps to (not hides) the others. |
| `OnboardingTemplate` | Full-bleed content zone, bottom action zone | Edge-to-edge layout for the onboarding carousel with a bottom "Get Started" area. |
| `AuthTemplate` | Centered content zone | Vertically and horizontally centered card for login/registration flows. |
| `UploadTemplate` | App bar zone, optional status bar, centered content zone | Centered single-task layout — an `UploadZone`, an action button, and an optional success/error `StatusBar` — same shape as `AuthTemplate` and for the same reason (one focused task, no tier branching needed). |
| `HomeHubTemplate` | App bar zone, three-card content zone, `MenuRail` | Layout for the Home Hub's three primary choices (`HubActionCard`s for Upload, View Studies, and Chat). Stacked column below `mediumMinWidth`, a single row at and above it — exactly 3 fixed cards never need a third posture. At `expanded`/`ultrawide` (gated at `threePaneMinWidth`, same as every other nav-shell template), the app bar disappears in favor of `primaryNavDrawer`/`menuRail`, same shape as `CaseListTemplate`/`SettingsTemplate`. |

### Rules for templates

- One file per template, located in `lib/ui/templates/`.
- May import from `atoms/`, `molecules/`, and `organisms/`.
- Define layout structure using `Scaffold`, `Row`, `Column`, `Expanded`, `LayoutBuilder`, and similar layout widgets.
- Accept organisms and configuration through constructor parameters or named slots (widget parameters like `body`, `sidePanel`, `appBar`).
- Contain **no business logic and no data fetching**. A template never holds a provider, bloc, controller, or repository reference.
- Handle responsive breakpoints here: decide when a side panel becomes a bottom sheet, when padding changes between mobile and tablet.

---

## Pages

A page is a **routed destination** that pairs exactly one template with real data, state management, and navigation logic. This is the only level that interacts with providers, blocs, repositories, or services.

### Catalog of pages in this app

| Page | Template used | State / data source |
|---|---|---|
| `ChatPage` | `ChatTemplate` | Conversation state (message list, current study, AI responses). Connects to the chat service and findings provider. |
| `StudyReviewPage` | `StudyReviewTemplate` | Study data fetched by study ID. Read-only review of past findings. Its status bar says when the study has images held back for review and opens the review. |
| `SettingsPage` | `SettingsTemplate` | User preferences, model configuration, account info. |
| `OnboardingPage` | `OnboardingTemplate` | Onboarding completion state, first-launch flag. |
| `LoginPage` | `AuthTemplate` | Authentication state, credential validation. |
| `UploadPage` | `UploadTemplate` | File-picker selection, upload/analysis status, and the resulting `CaseDetail` — connects to `UploadService`. |
| `HomeHubPage` | `HomeHubTemplate` | No data of its own beyond the drawer's review count — navigation chrome. Pushes `UploadPage`, `CaseListPage`, `ChatPage`, or `SettingsPage`. Wires `primaryNavDrawer`/`menuRail` (`selectedIndex: 0`, own case omitted) for the `expanded`/`ultrawide` gap this was the last nav-shell page to close. |
| `SimilarCasesPage` | `CaseListTemplate` | Cases similar to a given one — connects to `CaseService.getSimilarCases`. Reached from Study Review's "View Similar Studies" action. Wires `primaryNavDrawer`/`menuRail` (`selectedIndex: null`, a drill-down page like Study Review, not one of the five destinations itself) so it keeps a way back once its app bar hides at `expanded`/`ultrawide`. |
| `CaseListPage` | `CaseListTemplate` | Case list fetched via `casesProvider` (loading/data/error states). Wires `navBar`/`primaryNavDrawer`/`menuRail` (`selectedIndex: 2`) and the `caseSlots`/`worklistTable` slots; pushes `StudyReviewPage` on a case tap. Cards and worklist mark studies with images held back for review. |
| `ReviewQueuePage` | `CaseListTemplate` | The Review destination (`selectedIndex: 3`): every flagged image via `reviewQueueProvider`, needs review first, as `StudyInfoCard`s at compact/medium and `ImageReviewTable` from `threePaneMinWidth`. Pushes `ImageReviewPage` on a tap. |
| `ImageReviewPage` | `ImageReviewTemplate` | One flagged image by review ID, from `imageReviewsProvider`: the captioned images, `ImageReviewPanel` and the report. Saves through `ImageReviewService`, then waits for the refreshed reviews; only a radiologist may decide. Reached from the queue and from Study Review. |
| `HeatmapViewerPage` | `HeatmapViewerTemplate` | Heatmap overlay data fetched by finding ID via `heatmapProvider`. Owns the opacity slider's local state; pairs with `StudyReviewPage`'s "View Heatmap" action. |

### Rules for pages

- One file per page, located in `lib/ui/pages/`.
- Each page instantiates exactly one template and passes organisms (populated with real data) into the template's slots.
- `primary_destinations.dart` is the one non-widget file here: `openPrimaryDestination`, the index-to-page mapping every page mounting `AppNavBar`/`PrimaryNavDrawer` shares. It lives with the pages because only pages may navigate.
- This is the **only** level that reads from or writes to state management (Provider, Riverpod, Bloc, etc.), calls services, or triggers navigation (`Navigator`, `GoRouter`).
- Pages are registered in the app's router and correspond 1:1 to named routes.

---

## Dependency rule — strict and absolute

```
Pages → Templates → Organisms → Molecules → Atoms
```

Arrows mean "may depend on." No level may import from a level above it or at the same level. An organism never imports another organism. A molecule never imports another molecule. If two organisms need to share state, that coordination happens in the page that owns both of them, passed down through template slots.

---

## Deciding where a new widget belongs

When creating a new widget, walk through these questions in order:

1. **Does it map to a single Material widget with no composition?** → Atom.
2. **Does it group 2–4 atoms into one conceptual unit with no domain state?** → Molecule.
3. **Does it represent a distinct, self-contained section of a screen?** → Organism.
4. **Does it define where sections go on screen without knowing the data?** → Template.
5. **Does it connect a template to real data and navigation?** → Page.

If a widget doesn't clearly fit, it is probably too complex for its proposed level. Split it until each piece answers exactly one of the questions above.

---

## Checklist for code review

Before submitting any new or modified widget:

1. The widget lives in the correct directory for its atomic level.
2. Its imports only reference levels strictly below it.
3. Atoms and molecules contain no business logic, no service calls, no state management.
4. Organisms contain no data fetching — they receive data through constructor parameters.
5. Templates contain no business logic and no providers/blocs.
6. Pages are the only level that reads from providers, calls services, or triggers navigation.
7. No organism imports another organism; no molecule imports another molecule.
8. The widget can be understood in isolation — its name and parameters make its purpose clear without reading its parent.
