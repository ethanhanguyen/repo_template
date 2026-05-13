# /plan — Planning & doc creation

This file is injected in place of `/plan`. The user's task description is the text appended after this file's content.

**Extract `<description>`**: look for the text that follows the delimiter `---USER-DESCRIPTION---` at the end of this file — that is the `<description>`. Strip `<description`> text if present. Trim whitespace. If nothing after the delimiter (or only `<description`>), respond: "You invoked /plan but didn't provide a description. Usage: /plan <feature_description>"

Also trigger on "plan for <description>" or "create a plan for <description>" (verbatim match in user message).

## Rules

- **Docs only**: no code implementation. Create docs, commit to main, push, stop.
- **Auto-detect complexity**: read the description and decide how big this is.
- **Evidence before claims**: show fresh command output for every gate.

## Progress tracking

Before any work, create a todo list with these items (mark the top one `in_progress`):

1. Assess complexity
2. Create spec (if non-trivial)
3. Create phase plan (if multi-PR)
4. Create PR plan docs
5. Create ADRs (if architectural change)
6. Update tracking docs
7. Commit to main + push

Update status as each step completes.

---

## Step 1 — Assess complexity

Read `<description>` and classify into one of three tiers:

| Tier | Criteria | Output |
|------|----------|--------|
| **Simple** | 1 PR, localized change, no new modules | 1 PR plan doc only |
| **Medium** | 2–5 PRs, spans modules, new API/schema | spec + phase plan + N PR plan docs |
| **Large** | Multi-phase, major feature, new services | per-phase specs + per-phase plans + N PR plan docs |

State the tier and reasoning before proceeding.

*→ Mark Step 1 complete, mark Step 2 in_progress*

---

## Step 2 — Create spec

Skip if tier is **Simple**.

1. Derive slug: lowercase `<description>`, replace spaces with hyphens, strip special chars, max 40 chars
2. Read `docs/specs/spec-template.md` for structure
3. Create `docs/specs/{slug}.md` — fill all sections:
   - Overview, Status (Draft), Functional + Non-functional requirements
   - API endpoints (if applicable), Data model (if applicable)
   - Components (if applicable), Error handling
   - Dependencies, Open questions

*→ Mark Step 2 complete, mark Step 3 in_progress*

---

## Step 3 — Create phase plan

Skip if tier is **Simple**.

1. Read `docs/plans/progress.md` — check **PR Status** table for highest PR number in use
2. Let `base` = that number + 1 (or 0 if table empty)
3. Read `docs/plans/phase-plan-template.md` for structure
4. Read `docs/architecture.md` for current module boundaries
5. Determine phase number N from existing phase plans in `docs/plans/`
6. Create `docs/plans/phase{N}-plan.md` — fill all sections:
   - Goal, Prerequisites, PRs table (PR numbers starting from `base`), Dependency graph
   - New/modified files, Exit criteria, Validation checklist, Go/No-Go
7. Note: each row in the PRs table is a distinct PR that `/pr` will later execute

*→ Mark Step 3 complete, mark Step 4 in_progress*

---

## Step 4 — Create PR plan docs

1. Read `docs/plans/PR-prompt-template.md` for structure
2. For each PR in the phase plan (or the single PR if Simple tier):
   - Create `docs/plans/PR{N}-{pr-slug}.md`
   - Fill: Summary, Related (link spec + phase plan + ADRs), Implementation parts, Test requirements, Approach checklist
    - Each Implementation part gets: file path, type signatures, constraints, error handling
    - **Parallel groups**: if Parts touch disjoint files and no shared interfaces both modify, set `parallel_group: 1` on all Parts and note in a comment that they can run in parallel. If Parts depend on each other (same file, shared interface), leave `parallel_group: {N}` as-is (sequential).
    - Check `docs/navigation.md` **Scout corrections** for any gotchas relevant to these files

*→ Mark Step 4 complete, mark Step 5 in_progress*

---

## Step 5 — Create ADRs

If the plan reveals architectural decisions (new module boundaries, tech stack changes, data flow changes, scaling model changes):

1. Read `docs/decisions/YYYY-MM-DD-decision-template.md`
2. Create `docs/decisions/YYYY-MM-DD-{title}.md` for each decision
3. Link ADR from:
   - The PR plan docs (Related section)
   - `docs/architecture.md` (Key design decisions table)
   - `docs/index.md` (Decisions section)

*→ Mark Step 5 complete, mark Step 6 in_progress*

---

## Step 6 — Update tracking docs

1. **`docs/plans/progress.md`**:
   - If Simple tier: add one row to **PR Status** table — status `📋 Planned`
   - If Medium/Large tier: add one row per PR — status `📋 Planned`
   - Update **Dependency graph** if multiple phases
2. **`docs/navigation.md`**:
   - Set **Current focus** → PR/Task to this plan's description, Key files to expected changed files
   - Set Phase to the current phase number
   - Set Branch to `main`
3. **`docs/architecture.md`**:
   - Update **Module boundaries**, **Data flow**, or **Tech stack** tables if changed
   - Update **Key design decisions** if new decisions were made

*→ Mark Step 6 complete, mark Step 7 in_progress*

---

## Step 7 — Commit to main + push

1. `git add docs/`
2. `git commit -m "docs: plan {feature} — spec, phase{N} plan, {N} PRs"` (conventional commit)
3. `git push origin main`
4. Report: plan doc paths, PRs created (numbers + descriptions), branch `main`, next step: `/pr <N|keywords>` to implement

*→ Mark Step 7 complete*

---USER-DESCRIPTION---
