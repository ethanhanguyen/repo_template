# /pr — Atomic PR workflow

This file is injected in place of `/pr`. The user's task description is the text appended after this file's content. 

**Extract `<description>`**: look for the text that follows the delimiter `---USER-DESCRIPTION---` at the end of this file — that is the `<description>`. Strip `<description`> text if present. Trim whitespace. If nothing after the delimiter (or only `<description`>), respond: "You invoked /pr but didn't provide a description. Usage: /pr <task_description>"

Also trigger on "create a PR for <description>" (verbatim match in user message).

## Rules

- **Atomic**: run all 5 phases in order. Never skip.
- **Evidence before claims**: show fresh command output for every gate.
- **Fail fast**: if a gate fails, fix before continuing.

---

## Phase 1 — Plan (resolve PR number from description)

1. Read `docs/plans/PR-prompt-template.md` for structure
2. Read `docs/plans/progress.md` — especially the **PR Status** table
3. **Resolve the PR number** from `<description>` by reading `docs/plans/progress.md`:
   - **Match**: find a row in the **PR Status** table whose Description matches `<description>` keywords (case-insensitive, substring). Ignore rows prefixed `PR#` (those are ad-hoc audit/hotfix entries, not roadmap PRs).
     - Status is `⬜ Backlog` → use that row's PR number.
     - Status is `✅ Done`/`✅ Merged` → stop; tell user that PR already completed.
     - Ambiguous (multiple rows match) → show matches, ask user which one.
   - **No match**: find the highest roadmapped PR number in the table (max of `PR0`, `PR1`, ...), then use that number + 1. Example: if table has PR0–PR6, the next is PR7. If table is empty, start at PR0.
4. Derive slug: lowercase `<description>`, replace spaces with hyphens, strip special chars, max 40 chars
5. Create `docs/plans/PR{N}-{slug}.md` — fill all sections
6. Check `docs/navigation.md` **Current focus** section for active PR; clear it if it points to a different PR

## Phase 2 — Document

7. Update `docs/plans/progress.md` — add PR row to **PR Status** table (or update existing Backlog row status to `🚧 In Progress`)
8. Update `docs/navigation.md` — set **Current focus** to this PR
9. **ADR**: if this is a significant architectural change, write `docs/decisions/YYYY-MM-DD-{title}.md`
10. Update `docs/architecture.md` — if module boundaries, data flow, or tech stack changes
11. Update `README.md` — if setup or usage changes
12. **Commit & push** all doc updates before implementation

## Phase 3 — Implement

13. TDD per component: RED → GREEN → REFACTOR
14. Match existing conventions, handle errors at external boundaries
15. See plan doc (`docs/plans/PR{N}-{slug}.md`) for per-component constraints and error handling

## Phase 4 — Quality gates + behavioral self-review

16. Run `bash scripts/check.sh` — all gates must pass
17. Self-review against Quality Gates in `AGENTS.md` (Surgical, Explicit, Minimal, Conventions, Covered, Secure)
18. Fix any failures before proceeding

## Phase 5 — Commit & push (do NOT open PR)

19. Commit (conventional commit) and push all code changes
20. **Do NOT open PR** — auto merge is handled by the next step in the pipeline
21. Update `docs/plans/progress.md` — mark PR row status (✅ Done or ✅ Merged)
22. Update `docs/navigation.md` — clear **Current focus**
23. **Commit & push** all final doc updates
24. Report: branch name, files changed, tests added, gates passed, pushed ✓

---USER-DESCRIPTION---
