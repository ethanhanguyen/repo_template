# /pr — Atomic PR workflow

This file is injected in place of `/pr`. The user's task description is the text appended after this file's content. 

**Extract `<description>`**: look for the text that follows the delimiter `---USER-DESCRIPTION---` at the end of this file — that is the `<description>`. Strip `<description`> text if present. Trim whitespace. If nothing after the delimiter (or only `<description`>), respond: "You invoked /pr but didn't provide a description. Usage: /pr <task_description>"

Also trigger on "create a PR for <description>" (verbatim match in user message).

## Rules

- **Atomic**: run all 5 phases in order. Never skip.
- **Evidence before claims**: show fresh command output for every gate.
- **Fail fast**: if a gate fails, fix before continuing.

## Progress tracking

Before any work, create a todo list with these items (mark the top one `in_progress`):

1. Phase 1 — Plan (PR number, plan doc)
2. Phase 2 — Document (progress, nav, ADR, arch, README)
3. Phase 3 — Implement (TDD per component)
4. Phase 4 — Quality gates + behavioral self-review
5. Phase 5 — Commit, push & merge to main

Update status as each phase completes. If any phase reveals follow-up tasks, add them.

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

*→ Mark Phase 1 todo complete, mark Phase 2 in_progress*

---

## Phase 2 — Document

1. Update `docs/plans/progress.md` — add PR row to **PR Status** table (or update existing Backlog row status to `🚧 In Progress`)
2. Update `docs/navigation.md` — set **Current focus** to this PR
3. **ADR**: if this is a significant architectural change, write `docs/decisions/YYYY-MM-DD-{title}.md`
4. Update `docs/architecture.md` — if module boundaries, data flow, or tech stack changes
5. Update `README.md` — if setup or usage changes
6. **Commit & push** all doc updates before implementation

*→ Mark Phase 2 todo complete, mark Phase 3 in_progress*

---

## Phase 3 — Implement

1. TDD per component: RED → GREEN → REFACTOR
2. Match existing conventions, handle errors at external boundaries
3. See plan doc (`docs/plans/PR{N}-{slug}.md`) for per-component constraints and error handling

*→ Mark Phase 3 todo complete, mark Phase 4 in_progress*

---

## Phase 4 — Quality gates + behavioral self-review

1. Run `bash scripts/check.sh` — all gates must pass
2. Self-review against Quality Gates in `AGENTS.md` (Surgical, Explicit, Minimal, Conventions, Covered, Secure)
3. Fix any failures before proceeding

*→ Mark Phase 4 todo complete, mark Phase 5 in_progress*

---

## Phase 5 — Commit, push & merge to main

1. Commit (conventional commit) and push all code changes
2. Merge the branch into `main` (fast-forward if possible, otherwise merge commit)
3. Push `main` to remote
4. Update `docs/plans/progress.md` — mark PR row status `✅ Merged`
5. Update `docs/navigation.md` — clear **Current focus**
6. **Commit & push** all final doc updates (on `main` or the branch, whichever is active)
7. Report: branch name, files changed, tests added, gates passed, merged ✓

*→ Mark Phase 5 todo complete*

---USER-DESCRIPTION---
