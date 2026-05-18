# /audit_pr — Full PR code audit + fix

This file is injected in place of `/audit_pr`. The user's task description is the text appended after this file's content.

**Extract `<description>`**: look for the text that follows the delimiter `---USER-DESCRIPTION---` at the end of this file — that is the `<description>`. Strip `<description`> text if present. Trim whitespace. If nothing after the delimiter, `<description>` defaults to "all" (all open PRs).

Also trigger on "audit PR", "audit pr", "audit pull request" (verbatim match in user message).

## Precondition

None. Standalone command. `/audit_pr` audits both open and merged PRs by default. Specific PR numbers, "open only", or "merged only" can be requested in `<description>`.

## Rules

- **Audit mode**: no code changes until Gate A3 is approved. Phase I (audit) and Phase A (fix plan) are read-only.
- **Approval gates**: I3 (findings) and A3 (fix plan). After presenting either, STOP. Wait for user response. If `approved` → continue on same turn. If feedback → apply, re-present, stop.
- **Evidence before claims**: show fresh command output for every gate.
- **Fail fast**: if a quality gate fails during Phase B, fix before continuing. Max 3 auto-retries on `check.sh` failures.

## Session resume (DO THIS FIRST EVERY TURN)

1. Glob `/tmp/audit-pr-state-*.md`
2. If **1 matching file** → read it, confirm: "Resuming audit: {slug} (Step {current_step})"
   - If `current_step` is `complete` → tell user: "Audit already completed. Run again with new PR targets."
   - If `current_step` is `committed` → tell user: "Fixes already merged. Run again with new PR targets."
   - Else → jump to that step (skip earlier approved steps)
3. If **2+ matching files** → list slugs and current steps, ask: "Multiple audits in progress. Which to resume?"
4. If **0 matching files** → fresh start at Step 0

## Progress tracking

Create a todo list:

1. Phase 0 — Initialize & fetch PRs
2. Phase I — Audit (find issues, parallel per PR)
3. Phase A — Fix plan (propose, order, aggregate)
4. Phase B — Execute fixes (branch → gate → squash merge)

---

# Phase 0 — Initialize

## Step 0 — Parse target & fetch PRs

1. Derive `slug`: lowercase `<description>`, replace spaces with hyphens, strip special chars, max 40 chars. If `<description>` is "all" or empty, use `slug: all-prs`.

2. Read `docs/plans/plan-state-template.md` for state file structure reference.

3. Create `/tmp/audit-pr-state-{slug}.md` with:
   - `slug`, `original_description`, `target: unset`
   - `current_step: 0`
   - Empty `prs` list, empty `findings`, empty `fix_plan`
   - Empty `approvals` table

4. Check if `<description>` contains "approved" or "lgtm" (case-insensitive, as a separate word):
   - If YES → set ALL steps as pre-approved. Agent does mental drafting (audit → fix plan → execute) skipping approval gates I3 and A3 entirely.
   - If NO → continue to step 5.

5. **Parse PR target** from `<description>`:
    - Empty or "all" → fetch both open and merged PRs. Run TWO queries, combine results (deduplicate by PR number):
      - `gh pr list --state open --base main --json number,title,headRefName,state`
      - `gh pr list --state merged --base main --json number,title,headRefName,state`
    - "open" or "open only" → `gh pr list --state open --base main --json number,title,headRefName,state`
    - "merged" or "merged only" → `gh pr list --state merged --base main --json number,title,headRefName,state`
    - Number(s) like "42" or "1,3,5" → `gh pr view <N> --json number,title,headRefName,state` per number, regardless of state
    - If user asks for merged PRs explicitly (e.g. `/audit_pr 42 merged`) → include merged state filter

6. **Validate results**:
    - If zero PRs returned from `gh pr list` → fall back to `docs/plans/progress.md` (or `docs_template/plans/progress.md`). Scan the `✅ Merged` and `🚧 In Progress` tables in the PR Status section and extract PR numbers. If found, run `gh pr view <N> --json number,title,headRefName,state` per number.
    - If still zero PRs found → stop: "No matching PRs found."
    - Store PR list (number, title, branch, state) in state file `prs` field.

7. Present: "Found {N} PR(s): {PR_1} ({title_1}), {PR_2} ({title_2}), ..."

8. Mark step 0 approved, `current_step: I1`.

*→ Update /tmp/audit-pr-state-{slug}.md: 0 approved + current_step=I1 + prs populated*

---

# Phase I — Audit

## Step I1 — Dispatch audit agents (parallel)

For each PR in the `prs` list, dispatch one `InvestigatorAgent` (or `explore` agent for medium-depth scan) via Task tool. All agents run in parallel.

Each agent's prompt:

```
Audit PR #{N} ({title}) for code quality issues. Read-only — no code changes.

1. Get the diff: run `gh pr diff {N}` (for open PRs, diffs against base branch)
2. Get changed files: run `gh pr view {N} --json files`
3. For each changed file, READ THE FULL FILE (not just the diff lines)
4. Grep the codebase for:
   - Callers of every exported function/class/method in changed files
   - Importers of every exported symbol from changed modules
   - Usages of types/interfaces defined in changed files (check if unused after change)

Report findings in these 8 categories (include file:line, severity, and evidence for each):

1. LOGIC HOLES — missing conditions, edge cases not handled, broken invariants, inverted guards
2. BUGS — incorrect behavior, wrong types, null/undefined safety, race conditions, off-by-one
3. SECURITY RISKS — injection vectors (SQL/XSS/command), missing authz checks, exposed secrets/configs, unsafe deserialization, open redirects, missing CSRF, logging sensitive data
4. PERFORMANCE BOTTLENECKS — N+1 queries, missing DB indexes, synchronous blocking in hot paths, unbounded loops, large payloads without pagination, excessive re-renders
5. UNDER-OPTIMIZED — missing memo/cache on pure functions, unnecessary allocations in non-hot paths, redundant API calls, unbatched writes
6. DUPLICATED — same logic in multiple places that could be consolidated into a shared utility
7. DEAD/ORPHANED — unreachable code paths, functions/components never called, imports no longer used, variables assigned but never read
8. UNWIRED — components/functions/endpoints defined but never connected to any caller or route

Severity: critical / high / medium / low

For each finding, include a 1-line fix suggestion.

If NOTHING is found in a category, say "None" — do not omit categories.

Extra: also check that test files exist for changed production files, and that tests cover the changed paths. Report missing test coverage as medium severity in BUGS.
```

Wait for all agents to complete. Store each agent's full output in the state file.

## Step I2 — Aggregate findings

1. Collect outputs from all agents.
2. Build aggregated findings table across all PRs:

| PR | Category | Severity | File:Line | Summary |
|----|----------|----------|-----------|---------|

3. Sort by severity (critical → high → medium → low), then by PR.
4. Count totals per PR, per category.
5. For PRs with zero findings across all categories: mark as "✓ Clean".
6. Mark I2 approved, `current_step: I3`.

## Gate I3 — Findings approval

1. **Present** the aggregated findings summary:

   ```
   === Audit Results ===
   PRs audited: {N}
   Total findings: {M}

   By severity:
     critical: {c}
     high:     {h}
     medium:   {m}
     low:      {l}

   By category:
     bugs: {b}    security: {s}    performance: {p}    logic: {l}
     duped: {d}   dead: {dd}       unwired: {u}         optimize: {o}

   PRs clean (no findings): {clean_list}
   ```

2. If ALL PRs are clean → report "All PRs clean — no issues found." Mark state file `complete`, delete state file. Stop.

3. Present per-PR details with findings grouped by severity (critical first). Collapse low-severity findings behind a fold.

4. **Ask**: "Audit complete. Reply **approved** to proceed to fix planning, or tell me what to re-examine."

5. **Wait for user response**:
   - `approved` → mark I3 approved, `current_step: A1`, proceed immediately to Step A1.
   - `re-examine <PR or category>` → re-dispatch audit agent for that scope, re-aggregate, re-present I3, stop.
   - Feedback on specific findings → adjust findings table, re-present I3, stop.

*→ Update /tmp/audit-pr-state-{slug}.md: I3 approved + current_step=A1 + findings stored*

---

# Phase A — Fix Plan

## Step A1 — Propose fixes per finding

For each finding in the aggregated table:

1. **Strategy**: WIRE over REMOVE. Try to connect/reuse an existing component before deleting dead code. If a component is unwired, find the right caller to wire it to. Only remove as last resort.

2. **Order by priority**:
   - bug → security → logic hole → unwired → dead → performance → duplicated → under-optimized

3. For each finding, draft a fix:
   - **What** files to touch
   - **What change** (connect, refactor, add guard, remove, consolidate)
   - **Expected outcome** (bug fixed, component wired, dead code removed)
   - **Test strategy**: RED first for bugs/security/logic; skip RED for dedup/optimize (existing test coverage as safety net)

4. If a fix for finding A touches the same file as fix for finding B → group them under that file.

## Step A2 — Aggregate fix plan

1. Group all fixes by target file.
2. If the same file is touched by fixes from DIFFERENT PRs → emit a warning: "File `{path}` touched by fixes for PR {N1} and PR {N2}. Sequential execution required — may conflict."
3. Build ordered fix plan:

   ```
   File: src/foo.ts
     1. [bug/high] Fix null check at line 42 — add guard clause
     2. [dead/low] Remove unused function bar() at line 87

   File: src/baz.ts
     3. [security/critical] Add authz check to endpoint POST /widgets
     4. [unwired/medium] Wire WidgetValidator to POST /widgets handler
   ```

4. Estimate: total files touched, total fixes, expected test changes.
5. Mark A2 approved, `current_step: A3`.

## Gate A3 — Fix plan approval

1. **Present** the fix plan with per-file breakdown.

2. **Ask**: "Approve fix plan? Reply **approved** to execute, or tell me what to change."

3. **Wait for user response**:
   - `approved` → mark A3 approved, `current_step: B1`, proceed immediately to Phase B.
   - Change request → adjust affected fix(es) + downstream, re-present A3, stop.
   - `skip <finding #>` → remove that finding from plan, re-present, stop.

*→ Update /tmp/audit-pr-state-{slug}.md: A3 approved + current_step=B1 + fix_plan stored*

---

# Phase B — Execute Fixes

> Only execute after A3 is approved (or pre-approved in Step 0).

## Step B1 — Create branch

1. Determine branch name:
   - Single PR: `audit-pr{N}-{YYYYMMDDHHMM}-fixes` (timestamp from `date +%Y%m%d%H%M`)
   - Multiple PRs: `audit-multi-{YYYYMMDDHHMM}-fixes`

2. Check if branch already exists:
   ```bash
   git branch --list {branch_name}
   ```
   - If YES → warn: "Branch `{branch_name}` already exists (prior audit or crash). Resume from current state or start fresh?" Wait for user response.
   - If NO → create it.

3. `git checkout -b {branch_name}`
4. Store `branch: {branch_name}` in state file.
5. Mark B1 approved, `current_step: B2`.

## Step B2 — Apply fixes (sequential, per file group)

Process fixes in the order from Step A2, grouped by file:

1. For each fix in order:
   - **TDD**:
     - Bug / security / logic hole → RED first: write a failing test that proves the bug.
     - Dead / unwired / duplicated / optimize / performance → skip RED. Use existing test suite as safety net.
   - **GREEN**: minimal implementation to pass.
   - **REFACTOR**: clean up, keep tests green.
   - **Commit per file group**: `fix({scope}): audit — {summary}` (conventional commit).
   - After each file group: run full test suite. Fix any failures before proceeding to next file.

2. If a fix fails to apply cleanly (merge conflict, unexpected test break) → report the finding + file, pause, ask user: "Fix for {finding} failed. Skip this fix and continue, or abort?"

3. Track applied fixes in state file: `applied: [{fix_id, file, commit_hash, test_result}]`

4. Mark B2 approved, `current_step: B3`.

## Step B3 — Quality gates

1. Run `bash scripts/check.sh`:
   - PASS → mark B3 approved, proceed to B4.
   - FAIL → fix failures. Re-run. Up to 3 auto-retries.
   - If still failing after 3 retries → present failures, ask: "Quality gate still failing after 3 attempts. Proceed anyway or abort?"

2. Behavioral self-review against all Quality Gates in `AGENTS.md` (Correctness, Quality, Safety).

3. Fix any self-review failures.

4. Mark B3 approved, `current_step: B4`.

## Step B4 — Write audit report + tracking docs (on feature branch)

1. Create `docs/audits/` directory if it doesn't exist:
   ```bash
   mkdir -p docs/audits
   ```

2. Write `docs/audits/YYYY-MM-DD-pr{N}-audit.md` with:

   ```markdown
   # Audit Report — PR #{N} ({title}) — {DATE}

   ## Summary
   - **PR**: #{N} — {title} — branch `{branch}`
   - **Audit date**: {YYYY-MM-DD}
   - **Findings**: {total} ({c} critical, {h} high, {m} medium, {l} low)
   - **Fixes applied**: {applied_count}

   ## Findings

   | # | Category | Severity | File:Line | Summary |
   |---|----------|----------|-----------|---------|
   | 1 | bugs     | critical | src/x.ts:42 | Null deref when input is empty |

   ## Fixes Applied

   | # | File | Commit | Change |
   |---|------|--------|--------|
   | 1 | src/x.ts | `abc1234` | Added guard clause for empty input |

   ## Test Results
   - Tests run: {N}
   - Passed: {N}
   - Failed: 0
   - Quality gate: PASS

   ## PRs Skipped (clean)
   <!-- If any PRs had zero findings, list them -->

   ## Notes
   <!-- Any gotchas, tradeoffs, or follow-up items -->
   ```

3. If multiple PRs audited, create one report per PR.

4. Update tracking docs on the feature branch:
   - **`docs/plans/progress.md`** (if exists): add row to `✅ Merged` table in PR Status: "Audit PR#{N} — {N} fixes, merged"
   - **`docs/navigation.md`** (if exists):
     - Set **Current focus** to the next pending item (or `idle`), `Branch` → `main`
     - **Scout corrections** — add gotchas discovered during audit (e.g. "Audit found X pattern — grep for Y before adding Z")
   - **`docs/archive/learnings.md`** (if exists): log "{DATE} — /audit_pr {slug}: found {N} issues, applied {M} fixes. Key takeaway: {1-line}"
   - **`docs/index.md`** (if exists and has audits section): add link to audit report under `## Audits` section (create if missing)

5. `git add docs/` && `git commit -m "docs: audit {slug} — report + tracking"`

6. Mark B4 approved, `current_step: B5`.

## Step B5 — Squash merge to main (code + docs land together)

1. `git checkout main && git pull origin main`
2. `git merge --squash {branch_name}`
3. `git commit -m "fix: audit {slug} — {N} fixes applied"`
4. `git branch -d {branch_name}`
5. `git push origin main`

## Step B6 — Cleanup

1. Delete `/tmp/audit-pr-state-{slug}.md`
2. Mark `current_step: committed`.

## Step B7 — Report

```
=== Audit Complete ===
PRs audited:  {N}
Findings:     {M} ({c} critical, {h} high, {m} medium, {l} low)
Fixes applied: {F}
Branch merged: {branch_name} (squashed) → main ✓
Report:       docs/audits/YYYY-MM-DD-pr{N}-audit.md
```

*→ All todos complete*

---USER-DESCRIPTION---
