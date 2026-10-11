# Radiologist Helper

AI-powered chatbot that helps radiologists review DICOM studies and AI-generated findings.

---

## Requirements

- Flutter SDK `>=3.44.0` and Dart SDK `>=3.12.0`: the floor is set by `shared_preferences_android` 2.4.28, which is what makes the Android build free of the Kotlin Gradle plugin warning (`file_picker` 13 itself needs only Flutter 3.38 / Dart 3.10)

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

# Web
flutter build web --release
```

**`web/` is not in the repo either**: it is git-ignored, and a fresh clone has none. Generate it before the first browser run or web build with `make bootstrap-web` (or `flutter create --platforms=web .`, then discard what it changed in `.metadata`, `pubspec.lock` and `test/widget_test.dart`; the make target does that for you). A default `web/` is what the project always used, so nothing in it needs editing.

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

### Integration tests

Real device-run tests (a compiled app, real fonts and compositor), kept apart from the headless suite above. A tap that would not reach its target (covered, off screen, or aimed with positions from before a programmatic scroll) fails the test at the tap, via `flutter_test_config.dart`; after `scrollUntilVisible`, use `scrollIntoView` from `integration_test/support/` so layout catches up before tapping:

```bash
# PC: everything widescreen, in one app launch
flutter test integration_test -d linux

# One scenario file alone
flutter test integration_test/upload_page_scenarios.dart -d linux

# Regenerate the device-run goldens in integration_test/goldens/
flutter test integration_test -d linux --update-goldens
```

`integration_test/app_test.dart` is the **only** `*_test.dart` in that directory, on purpose: the Flutter tool fails every app launch after the first in a desktop run ([flutter/flutter#135673](https://github.com/flutter/flutter/issues/135673)), so the scenarios live in `*_scenarios.dart` files that `app_test.dart` imports and runs as groups. To add one, create `<name>_scenarios.dart` with its own `main()`, then import it in `app_test.dart` and add a `group` — `flutter test` (the headless suite) fails if you forget. Page scenarios override the repository providers with the fixtures in `integration_test/fixtures/`, so they don't depend on mock data.

**`linux/` is not in the repo either**, for the same reason: it is git-ignored, and a fresh clone has none. Generate it before the first desktop run with `flutter create --platforms=linux .`, then discard what `flutter create` changed in `.metadata`, `pubspec.lock` and `test/widget_test.dart`. A default `linux/` is what the project always used (the folder that was once tracked here was byte-identical to a freshly generated one), so nothing in it needs editing.

On desktop the window is whatever the host gives (1280×720 on the Linux runner), so tests that assert tier-specific chrome pin a size with `tester.view.physicalSize`. That is how the widescreen flows run: `app_flow_scenarios.dart` is wide, with one journey repeated at ultrawide. A resized desktop window is not what a phone does, though, so the **compact and medium flows run on Android devices instead**, on the device's own screen.

#### Phone and tablet (Android)

**`android/` is not in the repo, on purpose**: it is git-ignored (platform folders are artifacts of running the tests against a platform, not repo content). A fresh clone has none, so generate it locally with `flutter create --platforms=android .` before the first device run. `flutter create` also rewrites `.metadata` and `pubspec.lock` and adds a default counter `test/widget_test.dart`; discard all three. A freshly generated folder builds as it is: nothing in it needs editing.

`integration_test/app_flow_compact_medium_scenarios.dart` runs the same three journeys (bottom-nav settings flow, case → study review → heatmap → similar cases → system back, chat drawer) on the device, with real touch, the real back gesture, real insets and density. Nothing is pinned. The device's logical width picks the tier: under 600 is compact (a phone), under 1120 is medium (a small tablet in landscape). A wider screen fails with a message saying so rather than running something it can't test. `app_test.dart` registers only this group on a device, and leaves it out of the desktop run.

```bash
flutter devices                                    # find the emulator's id, e.g. emulator-5554
flutter test integration_test -d emulator-5554     # runs the 3 journeys for that device's tier
```

Run it once per device kind: a phone AVD (the stock "Medium Phone", 1080×2400 at 420 dpi, is ≈411×914 dp, compact) and a tablet AVD in **landscape**. For the tablet, 1920×1200 at 320 dpi is 960×600 dp, which is medium; a larger tablet, around 1280×800 dp in landscape, lands in the wide tier instead. No stock device profile is 960×600 dp in landscape (`medium_tablet`, `pixel_c` and `pixel_tablet` are about 1280 dp wide, the wide tier), so create one with a custom hardware profile in Android Studio's Device Manager (1920×1200, 320 dpi, landscape). Without Android Studio, copy another AVD's `config.ini` and `.ini` under `~/.android/avd/` and set `hw.lcd.width=1920`, `hw.lcd.height=1200`, `hw.lcd.density=320`, `hw.initialOrientation=landscape` and `skin.name`/`skin.path=1920x1200`, dropping the copied `hw.device.*` keys. (`avdmanager create avd` can't do this on a machine where cmdline-tools sits in a different SDK root from the system images, e.g. a distro package under `/usr/lib/android-sdk`: it answers "Valid system image paths are: null".) An AVD uses about 2–3.5 GB of disk. `emulator` isn't on PATH by default; start one with `~/Android/Sdk/emulator/emulator -avd Tablet_Landscape_API_35`, then run the tests against its id from `flutter devices`.

Needs, beyond Flutter's Linux setup:
- **A full JDK (17 or newer), not just a JRE**: Gradle needs `javac` and `jlink`. On Debian, `sudo apt install openjdk-21-jdk-headless` (verified: the build then works with no `JAVA_HOME` set); or point `JAVA_HOME` at a JDK for the run.
- **An Android SDK with an emulator and a system image** (Android Studio provides both). The first build downloads the NDK and a platform it needs into the SDK. `flutter doctor` may still say "cmdline-tools component is missing" if they live outside the SDK folder; that doesn't affect these builds.
- The generated `applicationId` is the `com.example.radiologist_helper` placeholder. It only matters if Android ever becomes a shipped target.

The page scenarios and goldens pin desktop sizes and run only on desktop.

### Static analysis

```bash
flutter analyze lib/
```

All tests must pass and `flutter analyze` must report zero errors and warnings before any change is considered done.
