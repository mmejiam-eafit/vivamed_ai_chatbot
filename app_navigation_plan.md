# App Navigation Plan — a hub, not a tab bar

Design for the app's real navigation flow: where a radiologist lands after signing in, how they reach a study, and how every screen connects. Written before any of it is implemented — implementation is deliberately sequenced as a separate, later effort, broken into smaller pieces.

## Context

The repository/service/DI data layer (see `implementation_plan.md`) gave every page real mocked data, but no page could actually navigate anywhere — there was no real answer yet to "where does a radiologist land after signing in, and how do they get to a study." The design canvas's own `Flow.dc.html` proposal (`design/canvas/`) assumed Chat was that landing screen, behind a persistent Chat/Studies/Settings tab bar. That proposal is explicitly non-authoritative ("a proposal, not a record") and doesn't match the actual intended flow: a **hub** with two primary paths — upload a new study, or browse existing studies — both of which converge on the study review screen (findings + chat + similar studies).

Two things worth noting, confirmed by reading the existing code/docs rather than assumed:
- `CaseListTemplate` was **already built anticipating exactly this** — its own preview functions are named `'wide — similar cases'`/`'narrow — patient history'`, with an `AppBar` titled "Similar Cases" and a `header` reading "3 similar cases found." The template is generic; only the page configuring it differs. Surfacing "similar studies" from Study Review reuses this template, not a new one.
- `design_tokens.md` already documents `statusSuccess`/`statusError` for **"Upload complete, study processed"** / **"Failed upload, invalid input, server error"** — upload was anticipated at the design-token level, just never built as a page.

Standalone Chat (not tied to a study) stays as a real hub option, not retired — a radiologist can ask it about different cases, and tapping one it references opens Study Review while the same conversation continues. Upload gets a real, interactive flow — a real file picker, not a fully-faked tap-to-proceed — with the actual analysis/backend still mocked, same as everywhere else in this app.

## The navigation graph

```
Login ──(first run)──> Onboarding ──Get started──> Home Hub
Login ──(returning)───────────────────────────────> Home Hub

Home Hub ──Upload a study──> Upload ──(mock analysis done)──> Study Review (new case)
Home Hub ──View studies────> Case List ──tap a case────────> Study Review (that case)
Home Hub ──Chat─────────────> Chat (standalone, general)
Home Hub ──(gear icon)──────> Settings

Chat/Case List/Settings ──AppNavBar: Home─────> pop straight back to Home Hub (the root)
Chat/Case List/Settings ──AppNavBar: the other two──> pushReplacement to each other (flat, no stacking)

Chat ──tap a case referenced in a reply──> Study Review (that case, SAME conversation continues)

Study Review ──select a finding──> Heatmap Viewer
Study Review ──view similar studies──> Similar Cases ──tap a case──> Study Review (that case, recurses)
```

Home Hub is the navigation **root** after login — reached once, then everything else is `Navigator.push`ed on top of it, so the AppBar back arrow eventually returns to it. `AppNavBar` gets reused, not stranded, but in a different role than the design canvas's proposal gave it: not a bar mounted on the Hub itself (the Hub *is* the equivalent of "home"), but a **4th "Home" destination added to it**, mounted only on the three screens it already represents — Chat, Case List, Settings — so a radiologist can jump laterally between those three, or straight back to the Hub, without walking back through the stack. Study Review, Heatmap, Upload, and Similar Cases stay nav-bar-free — standard drill-down UX, matching every app that hides its tab bar once you're inside a detail screen.

Mechanically: tapping "Home" is `Navigator.popUntil((route) => route.isFirst)` (jumps straight to the existing Hub instance, since it's the root — no new instance created). Tapping either of the *other two* destinations from Chat/Case List/Settings is `Navigator.pushReplacement` (keeps the stack flat — switching tabs isn't "drilling in," so it shouldn't grow a back-trail across tabs, the same reason no mainstream app with a bottom nav lets you "back" through five different tabs you bounced between). Drill-down pushes (Case List → Study Review, Chat → Study Review, etc.) are unaffected — those still grow the stack normally, so back from a study correctly returns to whichever of Chat/Case List you drilled in from.

This also resolves the design canvas proposal's third flagged decision ("Chat is a screen and a panel — worth confirming") concretely: they're the same conversation, viewed through two different templates depending on context, not two independent things.

## New page: Home Hub

- **`lib/ui/molecules/hub_action_card.dart`** (new) — `HubActionCard`: icon + title + description, tappable, one `onTap` callback. A hand-built decorated `Container` (`AppElevation.card`, matching this app's established reason for not using Flutter's `Card` — no `boxShadow` passthrough) wrapping `InkWell` — same shape as every other card-like surface in this app.
- **`lib/ui/templates/home_hub_template.dart`** (new) — `HomeHubTemplate`: three `HubActionCard` slots (`onUpload`, `onViewStudies`, `onChat`), responsive via `LayoutBuilder` per this app's template convention (stacked column at compact, a row/grid at medium and up — same tier tokens every other template already uses).
- **`lib/ui/pages/home_hub_page.dart`** (new) — `HomeHubPage`: `AppBar` with a settings gear `IconButton` (→ `Navigator.push` to `SettingsPage`), composes `HomeHubTemplate` with the three real `Navigator.push` callbacks.

## `AppNavBar` gets reused: a 4th "Home" destination

- **`lib/ui/organisms/app_nav_bar.dart`** — add a 4th `NavigationDestination` ("Home", placed first), so `selectedIndex`/`onDestinationSelected` now range over 4 items instead of 3. Existing previews/tests get a 4th case; otherwise unchanged (still the same `NavigationBar`-based widget, same token sourcing).
- **`lib/ui/templates/chat_template.dart`**, **`case_list_template.dart`**, **`settings_template.dart`** — each gains a new optional slot (e.g. `navBar`) passed straight to their own internal `Scaffold(bottomNavigationBar: navBar)`, the same way `statusBar`/`drawer` are already optional template-level slots today. Templates still do no navigation themselves — the page builds the real `AppNavBar` with real callbacks and passes it in as a plain widget, same as every other slot.
- **`lib/ui/pages/chat_page.dart`**, **`case_list_page.dart`**, **`settings_page.dart`** — each passes `AppNavBar(selectedIndex: <its own index>, onDestinationSelected: (i) { if (i == 0) { Navigator.of(context).popUntil((route) => route.isFirst); } else { Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => <the other two, indexed>)); } })`.

## New flow: Upload

- **`lib/data/upload.dart`** (new) — `UploadStatus` (`idle`/`uploading`/`analyzing`/`done`/`error`), whatever small state shape the page needs to render each step.
- **`lib/repositories/upload_repository.dart`** (new) — `UploadRepository.uploadStudy(String fileName) → Future<CaseDetail>`. `MockUploadRepository` simulates a delay, builds a new `CaseSummary` (fresh id, e.g. `'case-upload-<timestamp>'`) from the picked filename, **appends it to the shared mock case list** (so it also shows up back in the Studies worklist afterward — real consistency, not a dead-end fake), and returns its detail.
- **`lib/services/upload_service.dart`** (new) — thin pass-through, `uploadStudy(fileName)`.
- Provider entries added to the existing centralized `lib/repositories/providers.dart` / `lib/services/providers.dart` — no new provider file.
- **`lib/ui/templates/upload_template.dart`** (new) — `UploadTemplate`: an idle "choose a file" zone, then a progress state (`AppLoadingIndicator` + status text), then a `StatusBar` (already built, already has success/error variants) on completion/failure — reusing existing atoms/organisms throughout, no new ones beyond the template.
- **`lib/ui/pages/upload_page.dart`** (new) — `UploadPage`: uses the **`file_picker`** package (one new dependency, flagging it plainly like `flutter_riverpod` was) to open a real OS file picker; the picked file's name feeds the mocked upload/analysis call and the eventual case title. On success, `Navigator.pushReplacement`s to `StudyReviewPage(caseId: newCase.id)` — replace, not push, so the back button from the newly-created study returns to the Hub, not back into the upload flow.

## Standalone Chat gains: case references

The mechanism that makes "tap a case the AI mentions, see the study, chat keeps going" work — resolved to reuse Study Review's existing layout rather than build a new split view:

- **`lib/data/conversation.dart`** — `ChatMessageItem` gains an optional `referencedCaseIds: List<String>?`, for a reply that names specific cases (e.g. "I found 2 similar cases: ..."). Mock data (`conversation_mocks.dart`) gets at least one message using it, so the feature is actually exercised, not just plumbed.
- **`lib/ui/molecules/chat_bubble.dart`** — when a message carries `referencedCaseIds`, renders a small tappable reference per id (title only is enough — a compact chip, not a full `StudyInfoCard`) below the message text. New optional callback, e.g. `ValueChanged<String>? onCaseReferenceTap`, threaded up through `ChatMessageList` the same way `onTap`-style callbacks already thread through this app's organisms.
- **`lib/ui/pages/chat_page.dart`** — wires that callback to `Navigator.push(context, MaterialPageRoute(builder: (_) => StudyReviewPage(caseId: id, conversationId: currentConversationId)))` — passing its **own current conversation id**, not a new one.
- **`lib/ui/pages/study_review_page.dart`** — `conversationId` becomes an optional constructor parameter (was the hardcoded `_conversationId = 'conv-1'` constant for every case). When provided (arrived from Chat), that conversation continues. When absent (arrived from Case List, Similar Cases, or a fresh Upload), it defaults to `caseId` itself — treating "this study's own thread" and "the case id" as the same key in mock-land, so every case starts with its own empty conversation rather than all sharing one hardcoded thread. Real backends would have an explicit case→conversation mapping; this is the equivalent that needs nothing new to stand up.

At wide viewports this already satisfies "see both at once" — Study Review's existing three-zone layout puts image+findings beside the (continuing) chat. At narrow viewports it's tabs, same tradeoff Study Review already makes for everyone else.

## Study Review gains: similar studies

- **`lib/repositories/case_repository.dart`** — add `getSimilarCases(String caseId) → Future<List<CaseSummary>>` to the existing `CaseRepository` interface/mock (a plausible real endpoint — `GET /cases/{id}/similar` — not a transformation of already-fetched data, so it belongs at the repository level, not the service level). Mock returns a small deterministic subset of `mockCases` excluding the given one.
- **`lib/ui/pages/similar_cases_page.dart`** (new) — `SimilarCasesPage(caseId)`: composes the existing `CaseListTemplate` exactly the way its own `'wide — similar cases'` preview already does (`AppBar` titled "Similar Cases", `header` reading "N similar cases found"), fed by the new repository method. Tapping a result pushes another `StudyReviewPage` for it — the stack simply grows, which is correct (back unwinds through each study you drilled into).
- **`lib/ui/templates/study_review_template.dart`** / **`study_review_page.dart`** — add a "View similar studies" affordance (a button, e.g. in the findings panel area) wired to `Navigator.push(context, MaterialPageRoute(builder: (_) => SimilarCasesPage(caseId: caseId)))`.

## Mechanical wiring (the smaller, now well-scoped remainder)

- **`FindingItem` gains an `id` field** (`lib/data/finding.dart`) — the same forward-flagged gap noted when `CaseSummary` got its `id` in the data-layer pass; needed now because "select a finding → Heatmap" is a real navigation, not a placeholder. `FindingsRepository`'s mock data gains ids per finding; `HeatmapRepository.getHeatmap` is keyed by that real id instead of the placeholder `mockDefaultFindingId`.
- **First-run flag**, mirroring `ThemeController`'s existing `shared_preferences` pattern exactly (new small controller, loaded in `main.dart` alongside `ThemeController.load()` before `runApp`) — decides Login's post-sign-in destination (Onboarding vs. Hub) and is set once Onboarding's "Get Started" is tapped.
- **`lib/app.dart`**: `Routes` shrinks to `login`, `onboarding`, `home` — the only argument-free, static entry points. Every other screen (`StudyReviewPage`, `HeatmapViewerPage`, `SimilarCasesPage`, the post-upload destination) takes real constructor arguments and is reached by a direct `Navigator.push(MaterialPageRoute(builder: ...))`, not the named-route table — one consistent mechanism everywhere, and simplest given nothing here needs deep-linking/URL restoration.
- `ChatPage`/`StudyReviewPage`'s hardcoded `_conversationId`/`_caseId` constants go away: `StudyReviewPage` takes a required `caseId` and the optional `conversationId` described above. The standalone `ChatPage` (reached from the Hub) keeps a sensible default conversation to start in; picking a different one from its `ConversationDrawer` becomes real local state (`setState`), not a route.

## Docs to update alongside the code

- **`atomic_design.md`** — add the new pages/template/molecule to the catalogs (currently missing an upload/hub concept entirely).
- **`AGENTS.md`** — no new rule needed; the data-layer rule already covers `UploadRepository`/`UploadService`.

## Verification

- `flutter analyze` — clean.
- `flutter test` — full suite green; new tests for `HomeHubPage`/`HubActionCard`/`UploadPage`/`SimilarCasesPage` following this app's existing per-widget test conventions; existing tests touching the removed `Routes` entries or the old hardcoded chat/case constants get updated.
- Manually walk the real flow once wired: Login → Hub → View Studies → a case → Study Review → similar studies → another case → Study Review; separately, Login → Hub → Upload → pick a real file → mocked analysis → lands on a new Study Review, and that new case now also appears back in the Studies worklist; separately, Login → Hub → Chat → tap a case referenced in a reply → Study Review opens for it with the same conversation continuing in its chat panel.
- Also confirm the nav bar's new role: from Chat, tap Studies then Settings then Home in the nav bar — each lateral move should replace, not stack (back from Settings should return straight to the Hub, not through Studies then Chat), and Home should always land on the Hub in one step regardless of which of the three you started from.

## Status

Designed, not yet implemented. Implementation is intentionally deferred until this is broken down into smaller, separately-sequenced pieces (see `implementation_plan.md`'s next-steps note).
