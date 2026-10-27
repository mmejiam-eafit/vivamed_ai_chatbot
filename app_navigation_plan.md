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

Chat/Study Review ──drawer: gear icon──> Settings (ConversationDrawer's own entry point, distinct from the Hub's gear icon and AppNavBar's Settings destination above)

Study Review ──select a finding──> Heatmap Viewer
Study Review ──view similar studies──> Similar Cases ──tap a case──> Study Review (that case, recurses)

Chat/Case List/Review/Settings ──AppNavBar: Review──> Review queue ──tap an image──> Image Review
Study Review ──status bar: Review (an image awaiting review)──> Image Review
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

## Desktop/web navigation revisit — hamburger-triggered drawer

The navigation graph above was written mobile-first and never revisited for wide viewports. Its own reasoning for `AppNavBar` — "Study Review, Heatmap, Upload, and Similar Cases stay nav-bar-free — standard drill-down UX, matching every app that hides its tab bar once you're inside a detail screen" — holds up fine on a phone, but nothing in this document ever asked what the tab bar should do once the screen is wide enough that hiding it isn't saving any room. Read against the real code, three things compound at `expanded`/`ultrawide` widths that no version of this plan addressed:

- `chat_template.dart`'s `_buildWide`, `case_list_template.dart`, and `settings_template.dart` all render `AppBar` **and** `bottomNavigationBar: navBar` **and** a persistent `ConversationDrawer` column simultaneously, unconditionally — the same three pieces of chrome that make sense stacked on a phone, now all present at once on a monitor with room to spare.
- Study Review never got a primary-nav affordance at all — its `AppBar` shows Flutter's default back button (`automaticallyImplyLeading`, since `study_review_page.dart` sets no `leading`) whenever `Navigator.canPop()`, and nothing else.
- Settings is reachable three separate ways today — Home Hub's AppBar gear icon, `AppNavBar`'s Settings destination (Chat/Case List/Settings), and `ConversationDrawer`'s own `onSettings` NavItem (Chat/Study Review, wired in Chunks 7-8 below) — a redundancy that costs nothing on a phone (only one of the three is ever on screen at a time) but is visible all at once on a wide screen, where the bottom bar and the drawer both render in the same viewport.

This section resolves all three for `expanded`/`ultrawide` only. `compact`/`medium` are unaffected — see "Out of scope" below.

**Chosen pattern: hamburger-triggered drawer, `expanded`/`ultrawide` only.**
- `AppNavBar` (the `navBar` slot, `bottomNavigationBar:` on the `Scaffold`) is no longer rendered at `expanded`/`ultrawide` on `chat_template.dart`, `case_list_template.dart`, and `settings_template.dart`. Each already runs its body through a `LayoutBuilder` tier check for other reasons (§9.5 pane composition); this adds a branch to that same check rather than a new mechanism — no `MediaQuery`, per `design_tokens.md` §9.6.
- **Superseded below**: this bullet originally had the hamburger living in the app bar, using `AppBar`'s automatic `DrawerButton` (`Scaffold.hasDrawer` wins over `Navigator.canPop()`, checked directly against this environment's Flutter SDK). That's no longer where the trigger lives — see "Follow-up: the app bar is gone too," which replaced it with a bottom-anchored trigger instead. The underlying `Scaffold.drawer: primaryNavDrawer` wiring is unchanged; only what opens it moved.

**New organism: `PrimaryNavDrawer`** — `lib/ui/organisms/primary_nav_drawer.dart`.
- Same four destinations Chunk 4 below already gave `AppNavBar` (Home/Chat/Studies/Settings), same tap semantics: Home → `Navigator.popUntil((route) => route.isFirst)`, the other two → `pushReplacement`. Each page now factors that switch into a shared `_onPrimaryDestinationSelected(context, i)`, called by both `AppNavBar` (`compact`/`medium`) and `PrimaryNavDrawer` (`expanded`/`ultrawide`) instead of duplicating it per widget.
- A new organism, not an extension of `ConversationDrawer`: `AGENTS.md`'s dependency rule forbids one organism importing another, so the two can't compose at that level regardless, and `ConversationDrawer` has a distinct, narrower purpose (conversation history) that Case List and Settings have no use for.
- No `Scaffold.drawer` slot conflict: `chat_template.dart`'s `_buildWide` (the `expanded`/`ultrawide` branch) renders `ConversationDrawer` as an inline persistent `Row` column, never through `Scaffold.drawer` — that slot is free at this tier for `PrimaryNavDrawer`. (It's occupied by `ConversationDrawer`, and separately by findings via `endDrawer`, only in the narrower `_buildRail` branch, which this section doesn't touch.)
- Reuses `NavItem` (`layout: NavItemLayout.horizontal`, the molecule's own documented desktop-sidebar mode) with `unselectedColor: context.colors.iconOnBrand` — the same on-brand fix already applied to `ConversationDrawer`'s own Settings entry, needed here for the same reason (this drawer's background is `surfaceBrandSecondary`, not `AppNavBar`'s).

### Follow-up: the app bar is gone too, and the bottom Settings row is now the menu trigger

Feedback after seeing the hamburger-in-app-bar version running: drop the top bar entirely at `expanded`/`ultrawide` (all four pages, not just Study Review), and instead of the app bar hosting the trigger, repurpose `ConversationDrawer`'s existing bottom "Settings" row into it. This is the version actually shipped — the bullets above describing an app-bar hamburger are superseded by this section, kept only for the reasoning trail.

- **No app bar at all at `expanded`/`ultrawide`, all four pages.** Every template still takes `appBar` as a required constructor parameter (`compact`/`medium` still need it, unchanged there) — the wide-tier `Scaffold` branch just stops passing it (`appBar: isWide ? null : appBar`, or omitted entirely where the wide branch is its own method).
- **`ConversationDrawer` (Chat, Study Review) gets a new `onMenuTap` callback.** When provided, the bottom row shows "Menu" (`Icons.menu`) instead of "Settings", opening `PrimaryNavDrawer` instead of going straight to Settings. `onSettings` is untouched and still drives the row at `compact`/`medium` — `ConversationDrawer` itself stays tier-blind (it doesn't know or care which caller passed which callback); the *page* builds two instances, one per tier, exactly like the `AppNavBar`/`PrimaryNavDrawer` split above. New template slot `drawerWide: Widget?` (alongside the existing `drawer`) carries the wide-tier instance; `drawer` keeps serving `compact`/`medium` exactly as before.
- **New organism `MenuRail`** (`lib/ui/organisms/menu_rail.dart`) for Case List and Settings, which have no `ConversationDrawer` to repurpose — nothing there today at all at `expanded`/`ultrawide`. A narrow (`NavigationTokens.sideNavCollapsedWidth`, same width `CollapsedNavRail` already establishes) persistent column carrying just the "Menu" trigger. A distinct organism from `CollapsedNavRail`, not a reuse of it: `CollapsedNavRail` opens `ConversationDrawer`/findings overlays specifically for Chat's medium tier; `MenuRail` always opens `PrimaryNavDrawer`. New template slot `menuRail: Widget?` on `case_list_template.dart`/`settings_template.dart`.
- **`Scaffold.of(context).openDrawer()` is wired at the page, not the template**, since `ConversationDrawer`/`MenuRail` are page-built (unlike `CollapsedNavRail`, which the template itself constructs and can wrap in a `Builder` inline). Each page's `_conversationDrawerWide`/`_menuRail` helper wraps its `onMenuTap` construction in a `Builder`, deferring context capture to actual build time — the widget is placed inside the target `Scaffold`'s body once the template renders it, regardless of where in the page's source the `Builder(...)` expression was written, so `Scaffold.of(context)` inside it correctly resolves to that `Scaffold`, not an ancestor one.
- **The "hamburger replaces the back button" mechanism no longer applies.** There's no app bar at this tier for any of the four pages, so there's neither a `DrawerButton` nor a `BackButton` to choose between — the dedicated precedence regression test from the previous version of this section was removed, not kept; what replaced it is a plain assertion that `Scaffold.appBar` is `null` at this tier, per template.
- **This actually resolves the three-Settings-entry-points redundancy** the "New organism" section below used to say was dropped as architecturally awkward. It wasn't dropped, it fell out for free: `ConversationDrawer`'s bottom row no longer offers a direct Settings shortcut at `expanded`/`ultrawide` — it opens `PrimaryNavDrawer` like everything else does now, and Settings is reached through that one shared path. Home Hub's gear icon is unaffected (Home Hub still gets no hamburger/menu of its own) and remains a second, separate path *from Home Hub specifically* — not a redundancy with the other three pages, since Home Hub was never one of the pages carrying `ConversationDrawer`/`AppNavBar`'s Settings destination in the first place.

**Out of scope**, stated plainly so it isn't mistaken for an oversight later:
- Heatmap Viewer, Upload, and Similar Cases weren't among the pages the desktop/web observations named, and are unchanged by this section.
- Home Hub gains no hamburger/menu trigger — it already *is* the root/home destination; it doesn't need a way to navigate to itself. Its own gear icon (Settings) is unaffected.
- `compact`/`medium` — top bar, back button, bottom `AppNavBar`, `ConversationDrawer`'s Settings entry: all unchanged, on all four pages (the brief for this section: "Mobile and tablet views should NOT change significantly").

**Docs updated alongside this section:**
- **`atomic_design.md`** — `PrimaryNavDrawer` added to the organism catalog. (`MenuRail` not yet added — flagged here so it isn't missed next time this file is touched.)
- **`CLAUDE.md`** — its document table still doesn't list this file (`app_navigation_plan.md`) at all, despite it being exactly the kind of reference document that table describes. Still worth fixing whenever someone's next in there; still not a blocker.

**Verification:**
- Automated: every template (`chat_template.dart`, `case_list_template.dart`, `settings_template.dart`, `study_review_template.dart`) has tests confirming `navBar` and `appBar` are both absent at `expanded`/`ultrawide` while `primaryNavDrawer` reaches `Scaffold.drawer` and `drawerWide`/`menuRail` render inline, and that `compact`/`medium` render exactly as before, app bar included; every page has tests confirming the "Menu" trigger (inside `ConversationDrawer` on Chat/Study Review, inside `MenuRail` on Case List/Settings) opens the drawer and its Home/lateral destinations navigate correctly. `flutter analyze lib/ test/` and the full `flutter test` suite (757 tests, after Follow-up 2 below) both pass.
- Manual, still worth doing before calling this done: confirm no top bar renders at all at `expanded`/`ultrawide` on all four pages, the bottom-left "Menu" trigger opens `PrimaryNavDrawer` and Settings is reachable from it, and `compact`/`medium` looks and behaves byte-identical to before (top bar, back button, and "Settings" — not "Menu" — on `ConversationDrawer` all present) on a real run of the app. This environment has no `chromium-cli`/Playwright/Xvfb available, so this step needs `flutter run -d chrome`/`-d linux` run by hand rather than an automated screenshot.

### Follow-up 2: root-causing "still see it in some pages" (2026-09-23)

The known issue logged 2026-09-19 turned out to be four independent, unrelated mechanisms, not one bug — each sufficient on its own to explain the report:

- **Breakpoint mismatch.** `chat_template.dart`/`study_review_template.dart` hide their app bar at `AppLayout.threePaneMinWidth` (1120px — the width their three-pane `Row` genuinely needs, DT §9.1), while `case_list_template.dart`/`settings_template.dart` hid theirs at `AppLayoutTier.expanded` (`expandedMinWidth`, 1024px) — a boundary that happened to be convenient for their own tier-`switch`, never deliberately chosen to match the other two. Between 1024–1119px, "expanded" tier by the app's own enum, two of the four pages still showed the real app bar. **Fixed** by moving `case_list_template.dart`/`settings_template.dart` onto the same `threePaneMinWidth` boundary — one shared threshold across all five nav-shell templates now (`home_hub_template.dart` included, see below), rather than two independently-arrived-at ones that happened to coincide only sometimes. `case_list_template.dart`'s worklist-table-vs-Wrap content switch moved with it, so nothing shows the wide-tier table while still showing chrome, or vice versa.
- **Loading-state flash.** `study_review_page.dart`, `chat_page.dart` (two gates), and `case_list_page.dart` each had a pre-template early-return `Scaffold(appBar: appBar, ...)` for the loading/error state, bypassing the template — and its tier logic — entirely. Every mocked repository call has a real 300ms delay, so the app bar genuinely flashed at expanded/ultrawide on every fresh navigation. **Fixed**: all three (plus `similar_cases_page.dart`, see below) now always construct the real template. `case_list_page.dart`/`similar_cases_page.dart` reuse the existing `emptyState` slot for the loading spinner and error text — no template change needed, since `emptyState` already renders centered through the same chrome-aware `Scaffold` regardless of tier. `study_review_page.dart`/`chat_page.dart` swap only the content-bearing slot that has no sensible empty fallback (`imageViewer`, `chatPanel`'s message list) for a loading indicator; every other slot was already null-safe (`.value ?? const []`) and needed no change at all.
- **Home Hub always showed its app bar**, at every width, unconditionally — deliberately out of scope in Follow-up 1, but it's the app's root and one tap ("Home") away from all four other pages. **Fixed**: `home_hub_template.dart` gained the same `LayoutBuilder`/`primaryNavDrawer`/`menuRail` treatment as Case List/Settings (it has no `ConversationDrawer` of its own either), scoped to expanded/ultrawide only — compact/medium are untouched, still just the app bar and its gear icon, no bottom nav bar added there (none existed before; adding one now would be exactly the mobile/tablet change the brief rules out). `home_hub_page.dart`'s own `_onPrimaryDestinationSelected` omits case 0, the same "own destination is a no-op" pattern every other primary-destination page already uses.
- **Similar Cases** delegates its loaded state to `CaseListTemplate` (inheriting the breakpoint fix for free) but wired neither `primaryNavDrawer` nor `menuRail` — so once its app bar correctly hides at the wide tier, it would have had no navigation affordance there at all, not even a way back. **Fixed** the same way `study_review_page.dart` handles being a drill-down page that isn't itself one of the four destinations: `primaryNavDrawer(selectedIndex: null)` + `menuRail`, all four cases handled in its destination switch (none omitted, since it isn't any of the four itself).

**Deliberately left unchanged: Heatmap Viewer, Upload.** Both still show their app bar at every width. Heatmap Viewer forces a dark theme regardless of the user's actual setting (`diagnosticCanvasGround` is mode-exempt by design, DL §3.7/D-004) — nav chrome placed inside would render in that forced palette, a visibly different treatment from every other page's; it also has zero existing destination concept, and a `MenuRail` alongside its existing 280px opacity rail would cost real canvas width for the one thing this page exists to show clearly. Upload has never had any tier-branching and has a deliberate `PopScope` guard against abandoning an in-flight upload — adding a "jump anywhere" trigger works against that intent. Both are small, separable follow-ups if wanted later, not silently dropped.

**Docs updated alongside this section:** `design_tokens.md` §9.5 notes that `threePaneMinWidth` is now the shared no-chrome boundary for all five nav-shell templates, not just Chat/Study Review's own pane-fit requirement. `atomic_design.md`'s `MenuRail`/`PrimaryNavDrawer` organism-catalog rows list Home Hub and Similar Cases among their consumers now.

## Status

Implemented, in sequenced chunks:

1. `HubActionCard`/`UploadZone` molecules.
2. The Upload flow (`UploadRepository`/`UploadService`, `UploadTemplate`, `UploadPage`).
3. The Home Hub page/template.
4. `AppNavBar`'s 4th "Home" destination, mounted on Chat/Case List/Settings.
5. Platform enablement (Linux/web), the first-run flag, and `Routes` shrinking to `login`/`onboarding`/`home`.
6. The remaining unwired links: Case List → Study Review (not originally named in this doc, found by auditing the code directly), Finding → Heatmap Viewer, Study Review → Similar Cases, and Chat's case-reference chips.
7. `ChatPage`'s last hardcoded pieces — conversation switching as real local state, dropping the stray case-bound `FindingsPanel` standalone Chat no longer needs, and (not originally named in this doc either) wiring `ConversationDrawer`'s own `onSettings` for the first time — previously present on the drawer but never passed by the page, so the button rendered but did nothing.
8. The same `ConversationDrawer.onSettings` gap, found unwired on `StudyReviewPage` too (reported directly as a bug, not caught by this doc — the graph above never named this edge in the first place): fixed the same way as Chunk 7.

9. The desktop/web navigation revisit — hamburger-triggered drawer, `PrimaryNavDrawer`, all scoped to `expanded`/`ultrawide`. One correction made during implementation: the hamburger turned out to need no manual wiring, Flutter's own `Scaffold`/`AppBar` handled it (`Scaffold.hasDrawer` wins over `Navigator.canPop()`). At the time this chunk shipped, the "consolidate to one Settings entry point" sub-goal was dropped as architecturally awkward under `AGENTS.md`'s tier-in-templates-only rule, and Settings stayed reachable three ways — Chunk 10 below revisits and actually resolves that.
10. Follow-up, after seeing Chunk 9 running: the app bar is removed entirely at `expanded`/`ultrawide` (all four pages, not just Study Review), and `ConversationDrawer`'s/the new `MenuRail`'s bottom row becomes the menu trigger instead of an app-bar hamburger — see "Follow-up: the app bar is gone too" above for the full mechanism (`onMenuTap`, `drawerWide`, `MenuRail`, page-level `Builder` wiring). As a side effect, this is what actually resolves Chunk 9's dropped consolidation goal: `ConversationDrawer`'s bottom row no longer offers Settings directly at these tiers, so Settings is now reached through the one shared `PrimaryNavDrawer` path, not three separate ones.
11. Follow-up 2, after a manual pass on Chunk 10 found the app bar still visible on some pages: four independent gaps found and closed — see "Follow-up 2: root-causing 'still see it in some pages'" above. `case_list_template.dart`/`settings_template.dart` now share `chat_template.dart`/`study_review_template.dart`'s `threePaneMinWidth` boundary instead of their own, independently-arrived-at `expandedMinWidth` one; `study_review_page.dart`/`chat_page.dart`/`case_list_page.dart`/`similar_cases_page.dart` no longer bypass their template with an early-return `Scaffold` while loading; `home_hub_template.dart`/`home_hub_page.dart` gained the same expanded/ultrawide treatment as Case List/Settings; `similar_cases_page.dart` gained the `primaryNavDrawer`/`menuRail` wiring it never had. Heatmap Viewer and Upload deliberately excluded, with reasoning, not silently skipped.

12. A fifth destination, Review, between Studies and Settings (Settings moves from index 3 to 4), carrying the count of images needing a radiologist on both `AppNavBar` and `PrimaryNavDrawer`. The six per-page copies of the index-to-page switch became one shared `openPrimaryDestination` in `lib/ui/pages/primary_destinations.dart` first, so adding the destination changed one mapping. The review queue (`ReviewQueuePage`) is itself a destination page; `ImageReviewPage` is a drill-down reached from it and from Study Review's status bar. Home Hub still has no bar at compact/medium, so the count is not visible there.

Every navigation path described in Chunks 1-11 is wired and tested (`flutter test`, plus `integration_test/app_flow_test.dart` driving the real compiled app end-to-end for Chunks 1-8; Chunks 9-11's own tests, listed in the Verification section above, pass — `integration_test/app_flow_test.dart` not yet extended to cover any of them).
