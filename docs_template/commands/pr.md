# /pr — Execute one planned PR

This file is injected in place of `/pr`. The user's task description is the text appended after this file's content.

**Extract `<description>`**: look for the text that follows the delimiter `---USER-DESCRIPTION---` at the end of this file — that is the `<description>`. Strip `<description`> text if present. Trim whitespace. If nothing after the delimiter, `<description>` is empty (auto-pick).

Also trigger on "create a PR for <description>" (verbatim match in user message).

## Precondition

`/plan` must have been run first. PR plan docs must exist in `docs/plans/` with status `📋 Planned` in `docs/plans/progress.md`. If no planned PRs exist, respond: "No planned PRs found. Run `/plan <feature_description>` first to create a plan."

## Rules

- **Atomic**: run all 4 phases in order. Never skip.
- **Evidence before claims**: show fresh command output for every gate.
- **Fail fast**: if a gate fails, fix before continuing.
- **Surgical**: implement only what the PR plan doc specifies.

## Progress tracking

Before any work, create a todo list with these items (mark the top one `in_progress`):

1. Phase 1 — Match PR & status update
2. Phase 2 — Implement (TDD per component)
3. Phase 3 — Quality gates + behavioral self-review
4. Phase 4 — Open PR, merge to main

Update status as each phase completes.

When entering Phase 2, replace the single Phase 2 todo with sub-items:

2a. Analyze independence
2b. Execute parts
2c. Integration check

Mark each sub-item complete as it finishes. When all 2a/2b/2c are complete, mark Phase 3 in_progress.

---

## Phase 1 — Match PR & status update

1. Read `docs/plans/progress.md` — the **PR Status** section (multiple tables by status)
2. **Match the PR** by `<description>`:
   - `<description>` looks like `PR{N}` → match by exact PR number in any table
   - `<description>` is text → match by description substring (case-insensitive) against the `📋 Planned` table
   - `<description>` is empty → auto-pick the first row in the `📋 Planned` table
   - If matched row is in `✅ Merged` section → stop; tell user that PR already completed.
   - If matched row is in `🚧 In Progress` section → warn that PR is already in progress, ask user whether to resume or start over.
   - If no match → stop; tell user "No planned PR matches. Run `/plan` first or check progress.md."
3. Read the PR plan doc: `docs/plans/PR{N}-{slug}.md`
   - Confirm it exists and is filled out
   - Note: spec file, phase plan, and ADR links in its Related section
4. Update `docs/plans/progress.md`: move the matched row from `📋 Planned` table to `🚧 In Progress` table
5. Update `docs/navigation.md` **Current focus** — set to this PR, key files from plan doc

*→ Mark Phase 1 todo complete, mark Phase 2 in_progress*

---

## Phase 2 — Implement

**TDD per component. Parallelize when the plan declares independence.**

### 2a. Analyze independence

1. Read the PR plan doc's Implementation parts
2. Check for `parallel_group` annotations on each Part:
   - **No annotations** → all parts sequential (single group). Backward compatible.
   - **Annotated** → parts with the same `parallel_group` value form a group. Groups execute in order (group 1, then group 2, etc.)
3. Determine strategy:
   - **Single group** → run all parts sequentially in parent session (2b-sequential)
   - **Multiple groups** → dispatch parallel Tasks for each multi-part group, sequential for single-part groups (2b-parallel)

*→ Mark 2a todo complete, mark 2b in_progress*

### 2b. Execute

For each group in order:

**Single part in group** (sequential):
- Run TDD in parent session: RED → GREEN → REFACTOR
- Match existing conventions, handle errors at external boundaries

**Multiple parts in group** (parallel):
- Dispatch one Task per Part simultaneously. Each Task prompt:

  ```
  Implement Part {N} of PR {PR_N}.

  Read the plan at docs/plans/PR{N}-{slug}.md — Part {N} section only.

  Component: {name}
  File(s): {file_path}
  Branch: {branch}

  Type signatures / interface:
  {code_block}

  Constraints:
  {constraint_list}

  Error handling:
  {error_cases}

  Follow TDD:
  1. RED — write failing test(s) for this part only
  2. GREEN — minimal implementation to pass
  3. REFACTOR — clean up, keep tests green

  Rules:
  - Only touch file(s) listed above. Do NOT modify any other file.
  - Match existing conventions in neighboring files.
  - Commit to branch {branch} with message: "feat({scope}): {part_description}"
  - Run tests for your file(s) before returning.

  Return: commit hash, test pass/fail count, any concerns.
  ```

- Wait for all Tasks in the group to complete.
- If any Task failed → auto-retry that Part sequentially in parent session.
- Pull latest branch state before the next group.

*→ Mark 2b todo complete, mark 2c in_progress*

### 2c. Integration check

1. Run the full test suite (see your test command in `docs/quickstart.md`)
2. If failures → fix sequentially in parent session
3. Green → proceed to Phase 3

*→ Mark 2c todo complete, mark Phase 3 in_progress*

---

## Phase 3 — Quality gates + behavioral self-review

1. Run `bash scripts/check.sh` — all gates must pass
2. Self-review against all Quality Gates in `AGENTS.md`
3. Fix any failures before proceeding

*→ Mark Phase 3 todo complete, mark Phase 4 in_progress*

---

## Phase 4 — Open PR, merge to main

1. Commit (conventional commit) and push all code changes to the feature branch
2. Open a PR:
   ```bash
   gh pr create --base main --head {branch} --title "{PR title from plan doc}" --body "$(cat <<'EOF'
   ## Summary
   {summary from plan doc}
   EOF
   )"
   ```
3. Merge the PR:
   ```bash
   gh pr merge --merge --delete-branch
   ```
   (If `gh pr merge` fails, fall back to `git checkout main && git pull origin main && git merge {branch} && git push origin main && git branch -d {branch}`)
4. Checkout `main` and pull latest:
   ```bash
   git checkout main && git pull origin main
   ```
5. Update progress docs and commit them:
   - Update `docs/plans/progress.md` — move PR row from `🚧 In Progress` to `✅ Merged` section, update `{count}`
   - Update `docs/navigation.md`:
     - Set **Current focus** to next pending PR (or `idle` if none), `Phase` → `—`, `Branch` → `main`
     - **Scout corrections** — add any gotchas discovered during this PR (e.g. "When adding X, grep for Y first", "Classes in module Z use pattern W").
     - **Task map** — update if this PR added or changed any workflows
   - `git add docs/` && `git commit -m "docs: mark PR{N} merged"` && `git push`
6. Report: branch name, PR link, files changed, tests added, gates passed, merged ✓

*→ Mark Phase 4 todo complete*

---USER-DESCRIPTION---
