# Radiologist Helper

AI-powered chatbot that helps radiologists review DICOM studies and AI-generated findings.

---

## Requirements

- Flutter SDK `>=3.27.0` (widget previews require 3.27+)
- Dart SDK `>=3.3.0`

Install dependencies:

```bash
flutter pub get
```

---

## Previewing widgets

Every atom, molecule, and organism file ships with `@Preview` annotations that let you inspect widgets in isolation without running the full app. No simulator or device is needed.

### How previews are defined

Each file declares one or more top-level preview functions annotated with `@Preview`:

```dart
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

@Preview(name: 'with thumbnail', size: Size(360, 220), wrapper: previewWrapper)
Widget previewStudyInfoCardWithThumb() => const StudyInfoCard(
      title: 'Chest CT — Posterior-Anterior',
      fields: _previewFields,
      thumbnailUrl: 'https://picsum.photos/80/80',
      thumbnailBadge: '3',
    );
```

Two shared wrappers live in [lib/ui/core/preview_utils.dart](lib/ui/core/preview_utils.dart):

| Wrapper | Use when |
|---|---|
| `previewWrapper` | Widget is self-sized (atoms, molecules, most organisms) |
| `previewWrapperFull` | Widget must fill all available space (full-bleed panels) |

Both apply the real app theme so design tokens render correctly.

### Opening the preview panel

**VS Code** — open any widget file, then run the command `Flutter: Open Widget Preview`. A panel opens alongside the editor and hot-reloads as you edit.

**IntelliJ / Android Studio** — use the Flutter plugin's `Widget Preview` tool window (View → Tool Windows → Flutter Widget Preview).

### Running all previews from the CLI

```bash
flutter run --preview
```

---

## Atomic design

The UI is organised in five levels. Each level may only depend on levels strictly below it.

```
Pages → Templates → Organisms → Molecules → Atoms
```

| Level | Directory | Role | State management |
|---|---|---|---|
| **Atom** | `lib/ui/atoms/` | Single Material widget wrapper, no composition | None |
| **Molecule** | `lib/ui/molecules/` | 2–4 atoms forming one conceptual unit | None |
| **Organism** | `lib/ui/organisms/` | Self-contained screen section | Local UI state only |
| **Template** | `lib/ui/templates/` | Layout skeleton with named slots, no real data | None |
| **Page** | `lib/ui/pages/` | Template wired to real data, state, and navigation | Only level that may |

### Current status

All five atomic levels are implemented. Atoms, molecules, organisms, templates, and pages have widget tests under `test/ui/`.

| Level | Status |
|---|---|
| Atoms | ✅ Complete |
| Molecules | ✅ Complete |
| Organisms | ✅ Complete |
| Templates | ✅ Complete |
| **Pages** | ✅ Placeholder wiring complete (provider/service integration deferred) |

**Implemented pages and routes** (defined in `lib/app.dart`):

| Page | Route | Template |
|---|---|---|
| `LoginPage` | `/` | `AuthTemplate` |
| `OnboardingPage` | `/onboarding` | `OnboardingTemplate` |
| `ChatPage` | `/chat` | `ChatTemplate` |
| `StudyReviewPage` | `/study-review` | `StudyReviewTemplate` |
| `CaseListPage` | `/cases` | `CaseListTemplate` |
| `HeatmapViewerPage` | `/heatmap` | `HeatmapViewerTemplate` |
| `SettingsPage` | `/settings` | `SettingsTemplate` |

Each page instantiates exactly one template and passes organism/atom placeholders for all required slots. Provider integration, service calls, and real data wiring are a subsequent phase.

### Key rules

- One file per widget, `snake_case` filename matching the class name.
- No level imports from the same level or above. An organism never imports another organism.
- Atoms and molecules are always stateless and receive all configuration through constructor parameters.
- Organisms receive data through constructor parameters and expose interactions through callbacks — they never fetch data.
- Only pages read from providers, call services, or trigger navigation.
- All visual values (color, spacing, radius, typography, shadows) must come from [lib/ui/core/design_tokens.dart](lib/ui/core/design_tokens.dart). No inline `Color(0xFF...)`, `Colors.*`, bare numeric spacing, or inline `TextStyle`.

For the full widget catalog, dependency rules, and token-mapping guidelines see [atomic_design.md](atomic_design.md), [design_tokens.md](design_tokens.md), and [AGENTS.md](AGENTS.md).

### Adding a new widget

Walk through these questions in order:

1. Maps to a single Material widget with no composition? → **Atom**
2. Groups 2–4 atoms into one conceptual unit with no domain state? → **Molecule**
3. Represents a distinct, self-contained section of a screen? → **Organism**
4. Defines where sections go on screen without knowing the data? → **Template**
5. Connects a template to real data and navigation? → **Page**

---

## Running the app

### Prerequisites

1. **Font assets** — add the font files to `assets/fonts/` and uncomment the `fonts:` block in [pubspec.yaml](pubspec.yaml).
2. **State management** — initialise whatever provider (Riverpod, Bloc, Provider) is chosen at the root of the widget tree in `lib/app.dart` when the data layer is ready.

### Start the app

```bash
# On a connected device or simulator
flutter run

# Target a specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

### Build for release

```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release
```

---

## Tests

```bash
# Run all tests
flutter test

# Run tests for one level
flutter test test/ui/atoms/
flutter test test/ui/molecules/
flutter test test/ui/organisms/
flutter test test/ui/templates/
flutter test test/ui/pages/

# Run a single file
flutter test test/ui/organisms/study_info_card_test.dart

# Run with coverage
flutter test --coverage
```

### Static analysis

```bash
flutter analyze lib/
```

All tests must pass and `flutter analyze` must report zero errors and warnings before any change is considered done.
