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
| `ChatBubble` | `AppText`, `AppAvatar` (optional) | A single message bubble — user or assistant. Responsible for alignment, shape, and text rendering. |
| `ChatInput` | `AppTextField`, `AppButton` (send), `AppIcon` (attach) | The message composition bar at the bottom of the chat. Exposes an `onSubmit` callback. |
| `SeverityChip` | `SeverityDot`, `AppText` | Displays a severity level as a compact labeled chip (e.g., "MODERATE" with a colored dot). |
| `FindingRow` | `AppText` (finding name), `SeverityChip`, `AppIcon` (expand) | A single finding line item in a findings list. |
| `NavItem` | `AppIcon`, `AppText` | A single navigation destination (icon + label) used inside bottom nav or drawer. |
| `MetadataField` | `AppText` (label), `AppText` (value) | A key-value pair for displaying DICOM metadata or study info (label left, value right). |
| `StatusBanner` | `AppIcon`, `AppText`, `AppButton` (optional action) | A horizontal banner communicating a status message (info, warning, error). |
| `TypingIndicator` | `AppLoadingIndicator` or animated dots | Shows that the assistant is generating a response. |
| `ImageThumbnail` | `AppImage`, `AppBadge` (optional) | An X-ray thumbnail with an optional badge overlay (e.g., "3 findings"). |

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
| `ChatMessageList` | `ChatBubble` (many), `TypingIndicator` | The scrollable list of all messages in a conversation. Handles scroll-to-bottom, date separators, and grouping. |
| `ChatPanel` | `ChatMessageList`, `ChatInput` | The full chat area: message list + input bar. This is the primary interaction surface. |
| `FindingsPanel` | `FindingRow` (many), `AppText` (section header) | A collapsible panel listing all AI-generated findings for the current study, grouped by region or severity. |
| `StudyInfoCard` | `MetadataField` (many), `ImageThumbnail`, `AppText` (title) | Displays study metadata: patient pseudonym, modality, date, study UID, and a representative thumbnail. |
| `ConversationDrawer` | `NavItem` (many), `AppAvatar`, `AppText` | Side drawer listing past conversations. Each item shows a summary and timestamp. |
| `AppNavBar` | `NavigationBar`/`NavigationDestination` (native) | Bottom navigation bar with destinations: Chat, Studies, Settings. |
| `StatusBar` | `StatusBanner` | Persistent bar at the top of the screen showing connectivity or system status. |
| `OnboardingCarousel` | `AppImage`, `AppText`, `AppButton` | A swipeable set of introductory slides shown on first launch. |

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
| `CaseListTemplate` | App bar zone, optional status/header zone, case content zone | Layout for case discovery/history views. Uses list on narrow screens and grid on wide screens. |
| `StudyReviewTemplate` | App bar zone, study info zone (top), findings zone (bottom/side) | Layout for reviewing a completed study outside the chat context. |
| `HeatmapViewerTemplate` | App bar zone, image canvas zone, bottom control zone | Layout for rendering base study image and optional heatmap overlay with externally owned opacity control. |
| `SettingsTemplate` | App bar zone, scrollable content zone | Single-column layout for settings sections. |
| `OnboardingTemplate` | Full-bleed content zone, bottom action zone | Edge-to-edge layout for the onboarding carousel with a bottom "Get Started" area. |
| `AuthTemplate` | Centered content zone | Vertically and horizontally centered card for login/registration flows. |

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
| `StudyReviewPage` | `StudyReviewTemplate` | Study data fetched by study ID. Read-only review of past findings. |
| `SettingsPage` | `SettingsTemplate` | User preferences, model configuration, account info. |
| `OnboardingPage` | `OnboardingTemplate` | Onboarding completion state, first-launch flag. |
| `LoginPage` | `AuthTemplate` | Authentication state, credential validation. |

### Rules for pages

- One file per page, located in `lib/ui/pages/`.
- Each page instantiates exactly one template and passes organisms (populated with real data) into the template's slots.
- This is the **only** level that reads from or writes to state management (Provider, Riverpod, Bloc, etc.), calls services, or triggers navigation (`Navigator`, `GoRouter`).
- Pages are registered in the app's router and correspond 1:1 to named routes.

---

## Directory structure

```
lib/ui/
├── atoms/
│   ├── app_text.dart
│   ├── app_button.dart
│   ├── app_icon.dart
│   ├── app_text_field.dart
│   ├── app_avatar.dart
│   ├── app_badge.dart
│   ├── app_divider.dart
│   ├── app_loading_indicator.dart
│   ├── app_chip.dart
│   ├── app_image.dart
│   ├── severity_dot.dart
│   └── app_logo.dart
├── molecules/
│   ├── chat_bubble.dart
│   ├── chat_input.dart
│   ├── severity_chip.dart
│   ├── finding_row.dart
│   ├── nav_item.dart
│   ├── metadata_field.dart
│   ├── status_banner.dart
│   ├── typing_indicator.dart
│   └── image_thumbnail.dart
├── organisms/
│   ├── chat_message_list.dart
│   ├── chat_panel.dart
│   ├── findings_panel.dart
│   ├── study_info_card.dart
│   ├── conversation_drawer.dart
│   ├── app_nav_bar.dart
│   ├── status_bar.dart
│   └── onboarding_carousel.dart
├── templates/
│   ├── chat_template.dart
│   ├── case_list_template.dart
│   ├── heatmap_viewer_template.dart
│   ├── study_review_template.dart
│   ├── settings_template.dart
│   ├── onboarding_template.dart
│   └── auth_template.dart
└── pages/
    ├── chat_page.dart
    ├── study_review_page.dart
    ├── settings_page.dart
    ├── onboarding_page.dart
    └── login_page.dart
```

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
