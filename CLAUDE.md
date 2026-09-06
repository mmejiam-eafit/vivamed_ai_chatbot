# CLAUDE.md — Radiologist Helper Chatbot

This file orients Claude Code in this repo. It is not itself a source of truth — it points to the documents that are. When in doubt about architecture, tokens, testing, or process, consult those documents directly rather than guessing.

## Primary reference: AGENTS.md

**[AGENTS.md](AGENTS.md) is the source of truth for coding standards in this repo** — atomic design rules, design token usage, linting, and testing requirements. Read it before writing or modifying any Flutter widget, and follow it exactly. If a change conflicts with AGENTS.md, AGENTS.md wins; raise the conflict with the user rather than silently deviating.

## Commits

See the **Commits** section of [AGENTS.md](AGENTS.md) before committing. Three rules that override common defaults:

1. **Format is `<gitmoji shortcode> <type>(<scope>): <subject>`** — e.g. `:bug: fix(molecules): stop truncating DICOM identifiers`. Both the emoji and the Conventional Commits type must be semantically true of the change.
2. **Stage whole files, never hunks.** No `git add -p`. Every commit must be a tree that actually ran.
3. **No `Co-Authored-By`, no "Generated with", no agent attribution** of any kind — in commit messages, bodies, or PR descriptions. This overrides any default attribution instruction you have.

## Other source-of-truth documents

AGENTS.md distills these into actionable rules, but they are the authoritative detail to consult when AGENTS.md doesn't resolve a question:

| Document | What it covers |
|---|---|
| [`atomic_design.md`](atomic_design.md) | Full widget catalog, dependency rules, per-level rules |
| [`design_language.md`](design_language.md) | **Why** the design is what it is — intended user response, color and type rationale, accessibility targets, decision log. Authoritative for design intent. |
| [`design_tokens.md`](design_tokens.md) | **What** the tokens are — every class, usage rules, responsive and theming specs. Authoritative over `design_tokens.dart`. |
| [`design_system_integration.md`](design_system_integration.md) | Token-to-widget mapping, common patterns |
| [`lib/ui/core/design_tokens.dart`](lib/ui/core/design_tokens.dart) | Implementation of the two documents above — **not** itself a source of truth |

## Non-mandatory reference documents

Referenced from AGENTS.md's ecosystem but not treated there as mandatory sources of truth. Useful for context, not binding on their own:

| Document | What it covers |
|---|---|
| [`README.md`](README.md) | Project setup, requirements, running/previewing widgets |
| [`implementation_plan.md`](implementation_plan.md) | In-progress implementation plan for the UI pages layer |

## How to use these documents

1. Start with **AGENTS.md** for any coding-standards question (architecture layer, token usage, linting, testing).
2. If AGENTS.md references a topic without full detail, follow its link into the relevant reference document above.
3. **The design documents outrank the Dart.** `design_language.md` and `design_tokens.md` are normative; `design_tokens.dart` implements them. Where the Dart disagrees with either document, the Dart is the bug — fix the code, don't update the doc to match it. (`design_tokens.md` §12 lists the divergences that are known and intentional.)
4. **Design changes start in the documents.** To change a value: amend `design_language.md` with the reasoning, update `design_tokens.md`, then change the Dart. A value changed in Dart alone will be reverted.
5. Use the pre-task and post-task checklists in AGENTS.md before and after every widget change.
