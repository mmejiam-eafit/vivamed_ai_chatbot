## Plan: Implement All UI Pages

> **Partially superseded.** The seven pages described here are built. The responsive assertions in Phases 3 and 4 target `AppLayout.templateSplitWidth` boundaries (767/768/769), which `design_tokens.md` §9 retires in favour of tier boundaries plus pane-composition minimums. Treat those specific steps as obsolete; the rest of the plan still stands.

Implement seven page classes that each instantiate exactly one existing template, starting with placeholder wiring (no provider integration yet), then add route registration and page-level tests so templates can be exercised end-to-end without violating atomic design boundaries.

**Steps**
1. Phase 1 - Page Contracts and File Scaffolding (foundation, blocks later steps)
1. Define a strict page-template mapping matrix and keep it as the implementation source of truth: LoginPage->AuthTemplate, OnboardingPage->OnboardingTemplate, SettingsPage->SettingsTemplate, ChatPage->ChatTemplate, StudyReviewPage->StudyReviewTemplate, CaseListPage->CaseListTemplate, HeatmapViewerPage->HeatmapViewerTemplate.
2. Create seven page files under lib/ui/pages with StatelessWidget implementations and minimal placeholder slot wiring only.
3. Ensure each page instantiates exactly one template and passes only organism/molecule/atom placeholders required by that template constructor.
4. Enforce page-layer rules in each file: no direct design tokens, no template-internal layout logic, no service calls, no state management wiring in this phase.
2. Phase 2 - App Entry and Navigation Wiring (depends on Phase 1)
1. Create or update app entrypoint and route table so each new page is reachable by name/path from a single MaterialApp or router configuration.
2. Add temporary navigation affordances for manual verification (for example, lightweight route links or initialRoute switching) while keeping business logic out.
3. Validate that routes remain 1:1 with page classes and do not instantiate templates directly from router code.
3. Phase 3 - Page Test Suite Expansion (parallel with late Phase 2)
1. Keep the existing readiness harness and add dedicated page test files for all seven pages.
2. For each page test, assert template presence and required slot content visibility (smoke contract).
3. Add responsive assertions for ChatPage, StudyReviewPage, and CaseListPage around AppLayout.templateSplitWidth boundaries (767, 768, 769).
4. Add optional-slot tests for pages/templates that allow optional UI zones (drawer/status/findings/overlay/header/empty state).
4. Phase 4 - Stability and Documentation Sync (depends on Phases 1-3)
1. Run analysis and test suites for pages and templates and resolve any warnings/errors before completion.
2. Update architecture docs to list all implemented pages and route intent, including explicit mention that provider integration is a later phase.
3. Replace or reduce page-readiness harness placeholders only after dedicated page tests fully cover current guarantees.

**Relevant files**
- /mnt/storage/repos/radiologists_chatbot_frontend/lib/ui/pages/ (new files)
- /mnt/storage/repos/radiologists_chatbot_frontend/lib/ui/templates/auth_template.dart - LoginPage contract
- /mnt/storage/repos/radiologists_chatbot_frontend/lib/ui/templates/onboarding_template.dart - OnboardingPage contract
- /mnt/storage/repos/radiologists_chatbot_frontend/lib/ui/templates/settings_template.dart - SettingsPage contract
- /mnt/storage/repos/radiologists_chatbot_frontend/lib/ui/templates/chat_template.dart - ChatPage contract and responsive behavior
- /mnt/storage/repos/radiologists_chatbot_frontend/lib/ui/templates/study_review_template.dart - StudyReviewPage contract and responsive behavior
- /mnt/storage/repos/radiologists_chatbot_frontend/lib/ui/templates/case_list_template.dart - CaseListPage contract and responsive behavior
- /mnt/storage/repos/radiologists_chatbot_frontend/lib/ui/templates/heatmap_viewer_template.dart - HeatmapViewerPage contract and overlay slot behavior
- /mnt/storage/repos/radiologists_chatbot_frontend/lib/ui/core/design_tokens.dart - AppLayout.templateSplitWidth and layout constants used by responsive templates
- /mnt/storage/repos/radiologists_chatbot_frontend/test/ui/pages/page_readiness_harness_test.dart - baseline harness to keep until dedicated page tests are complete
- /mnt/storage/repos/radiologists_chatbot_frontend/test/ui/pages/ (new page test files)
- /mnt/storage/repos/radiologists_chatbot_frontend/README.md - implementation status updates
- /mnt/storage/repos/radiologists_chatbot_frontend/atomic_design.md - page catalog alignment

**Verification**
1. flutter analyze lib/ui/pages lib/ui/templates test/ui/pages test/ui/templates
2. flutter test test/ui/pages
3. flutter test test/ui/templates
4. Manual route smoke check: each route opens expected page and page renders exactly one template.
5. Responsive smoke check: resize/page-size simulation confirms expected switches at 767/768/769 for Chat, StudyReview, and CaseList.

**Decisions**
- Scope included: all seven pages (core five plus CaseList and HeatmapViewer).
- Implementation strategy: placeholders first; provider/service integration is explicitly deferred.
- Architectural guardrail: one page maps to one template; no page-level direct token usage.

**Further Considerations**
1. Router choice confirmation: if GoRouter is preferred over Navigator routes, apply it consistently in Phase 2 and mirror route names in tests.
2. Placeholder to real data migration plan: after this page pass, a second phase should introduce provider wiring page-by-page in risk order (Settings, Login, Onboarding, CaseList, Chat, StudyReview, HeatmapViewer).
3. HeatmapPage acceptance criteria: define exact overlay source, opacity interaction ownership, and image/overlay alignment contract before state integration phase.