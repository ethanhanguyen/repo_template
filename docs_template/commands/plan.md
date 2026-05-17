# /plan — Planning & discussion

This file is injected in place of `/plan`. The user's task description is the text appended after this file's content.

**Extract `<description>`**: look for the text that follows the delimiter `---USER-DESCRIPTION---` at the end of this file — that is the `<description>`. Strip `<description`> text if present. Trim whitespace. If nothing after the delimiter (or only `<description`>), respond: "You invoked /plan but didn't provide a description. Usage: /plan <feature_description>"

Also trigger on "plan for <description>" or "create a plan for <description>" (verbatim match in user message).

## Rules

- **Docs only**: no code implementation. Create docs, commit to main, push, stop.
- **Approval gates**: I1 (investigation report) and A6 (final summary). Steps A1–A5 proceed without stopping — agent makes best judgments and moves on. No spec, phase plan, PR doc, or ADR file is written until A6 is approved.
- **Stop rule**: after presenting I1 or A6 and asking for approval, STOP. Wait for user response. If `approved` → continue on same turn. If feedback → apply, re-present, stop.
- **Evidence before claims**: show fresh command output for every gate.

## Session resume (DO THIS FIRST EVERY TURN)

1. Glob `/tmp/plan-state-*.md`
2. If **1 matching file** → read it, confirm: "Resuming plan: {slug} (Step {current_step})"
   - If `current_step` is `committed` → tell user: "Plan already committed. Use /pr to implement."
   - Else → jump to that step (skip earlier approved steps)
3. If **2+ matching files** → list slugs and current steps, ask: "Multiple plans in progress. Which to resume?"
4. If **0 matching files** but `docs/plans/progress.md` has `📋 Planned` rows → tell user: "No active plan session found, but planned PRs exist in progress.md. Ready for /pr."
5. If **0 matching files** and no planned PRs → fresh start at Step I0

## Progress tracking

Create a todo list:

1. Phase I — Investigate (agent-delegated)
2. Phase A — Discuss & draft (verbal only)
3. Phase B — Write & commit (after final approval)

---

# Phase I — Investigate

> **Dispatch a subagent to understand the problem before planning.** No code changes. Output is a report presented for user approval.

## Step I0 — Initialize + dispatch investigation

1. Derive `slug`: lowercase `<description>`, replace spaces with hyphens, strip special chars, max 40 chars.
2. Read `docs/plans/plan-state-template.md` for structure.
3. Create `/tmp/plan-state-{slug}.md` with:
   - `slug`, `original_description`, `complexity_tier: unset`
   - `current_step: I0`
   - Empty `approvals` table, empty `change_log`
4. Check if `<description>` contains "approved" or "lgtm" (case-insensitive, as a separate word):
   - If YES → set ALL steps as pre-approved in plan-state.md. Skip Phase I and Phase A entirely (agent still does mental drafting — investigate, assess, structure, plan — then jump to Phase B Step B1 and write complete docs).
   - If NO → continue to step 5.

5. **Detect intent** from `<description>`:
   - Contains `bug`, `fix`, `error`, `crash`, `broken`, `failing`, `exception` → bug investigation
   - Otherwise → feature/change investigation

6. **Dispatch investigation agent** via Task tool:

   | Intent | Agent | Prompt |
   |--------|-------|--------|
   | Bug | `InvestigatorAgent` | "Investigate: {description}. Find root cause. Read relevant files, trace call paths, isolate the fault. Return: (1) root cause with file:line, (2) affected code paths, (3) evidence (stack traces, logs), (4) recommended fix strategy." |
   | Feature | `explore` (very thorough) | "Explore codebase for: {description}. Understand existing patterns, module boundaries, adjacent code, extension points. Return: (1) relevant modules/files with key interfaces, (2) existing patterns to follow, (3) integration points, (4) risks/gotchas." |

7. Wait for agent result. Store the full agent response in a variable `investigation_report`.
8. Mark I0 `approved`, `current_step: I1`.

*→ Update plan-state.md: I0 approved + current_step=I1*

## Step I1 — Investigation approval gate

1. **Present** the investigation report with a compact summary:
   - Bug: root cause (1 line), affected files, recommended fix strategy
   - Feature: relevant modules, patterns to follow, integration points
   - Always include the raw agent output (collapsed) below the summary

2. **Ask**: "Investigation complete. Reply **approved** to proceed to planning, or tell me what to re-examine."

3. **Wait for user response**:
   - `approved` → mark I1 `approved`, `current_step: A1`, set `investigation_report` field in plan-state.md, proceed immediately to Step A1.
   - Feedback → re-dispatch investigation agent with new guidance, re-present report, stop.

*→ Update plan-state.md: I1 approved + current_step=A1 + investigation report stored*

---

# Phase A — Discuss & Draft
(verbal only, nothing written to docs/; tracking in /tmp/plan-state-{slug}.md)

Context: use `investigation_report` throughout.

## Step A1 — Assess complexity → route

| Tier | Criteria | Output | Next |
|------|----------|--------|------|
| **Simple** | 1 PR, localized, no new modules | 1 PR plan doc | → A4 |
| **Medium** | 2–5 PRs, spans modules, new API/schema | spec + phase plan + N PR docs | → A2 |
| **Large** | Multi-phase, new services | per-phase specs + per-phase plans + N PR docs | → A2 |

Present: "**{tier}** tier. {1-sentence}." → mark A1 approved, `current_step` = route above, continue.

## Step A2 — Draft spec (Medium/Large)

Skip if Simple. Draft verbally using `docs/specs/spec-template.md` structure. → mark A2 approved, `current_step: A3`.

## Step A3 — Draft phase plan (Medium/Large)

Skip if Simple. Read `docs/plans/progress.md` for next PR numbers, `docs/architecture.md` for boundaries. Draft verbally using `docs/plans/phase-plan-template.md`. → mark A3 approved, `current_step: A4`.

## Step A4 — Draft PR docs

For each PR (or the single PR for Simple): draft verbally using `docs/plans/PR-prompt-template.md`. → mark A4 approved, `current_step: A5` (or `A6` if no ADRs).

## Step A5 — Draft ADRs (if applicable)

If architectural decisions needed: draft verbally using `docs/decisions/YYYY-MM-DD-decision-template.md`. → mark A5 approved, `current_step: A6`. If none → skip A5.

## Step A6 — Final approval gate

1. Present compact summary:
   - Tier, spec status, phase plan, PR list (PR{N0}...), ADRs
2. **Ask**: "Approve plan? Reply **approved** to write docs or tell me what to change."
3. **Wait for user response**:
   - `approved` → mark A6 approved, `current_step: B1`, proceed to Phase B.
   - Feedback → re-draft affected step(s) + downstream, re-present A6, stop.

---

# Phase B — Write & Commit

> Only execute after A6 is approved (or pre-approved in I0). All files written are idempotent — if a file already exists with matching content, skip. If Phase B was interrupted (crash), re-run from B1 — it will detect existing files and fill gaps.

## Step B1 — Write all docs to files

Write each approved deliverable using the template structures:

1. **Spec** (Medium/Large only): `docs/specs/{slug}.md` — fill using approved A2 draft. Status: `Draft`.
2. **Phase plan** (Medium/Large only): `docs/plans/phase{N}-plan.md` — fill using approved A3 draft and `docs/plans/phase-plan-template.md`.
3. **PR docs**: `docs/plans/PR{N}-{pr-slug}.md` — one per PR. Fill using approved A4 drafts and `docs/plans/PR-prompt-template.md`. Set `parallel_group` annotations per phase plan dependency graph. Check `docs/navigation.md` **Scout corrections** for gotchas.
4. **ADRs** (if applicable): `docs/decisions/YYYY-MM-DD-{title}.md` — fill using approved A5 drafts.

## Step B2 — Update tracking docs

1. **`docs/plans/progress.md`**:
   - Add rows to `📋 Planned` table in **PR Status**
   - Update **Dependency graph** if multi-phase
2. **`docs/navigation.md`**:
   - Set **Current focus** → this plan's description, Key files → expected files
   - Set Phase → current phase number, Branch → `main`
3. **`docs/architecture.md`**:
   - Update **Module boundaries**, **Data flow**, or **Tech stack** if changed
   - Update **Key design decisions** if new ADRs
4. **`docs/index.md`**:
   - Add spec link to **Current specs** (Medium/Large)
   - Add phase plan link to **Plans**
   - Add ADR links to **Decisions**

## Step B3 — Commit to main + push

1. `git add docs/`
2. `git commit -m "docs: plan {slug} — spec, phase{N} plan, {N} PRs"`
3. `git push origin main`
4. Delete `/tmp/plan-state-{slug}.md` (plan committed, state file no longer needed)
5. Report: plan doc paths, PRs created (numbers + descriptions), branch `main`, next step: `/pr <N|keywords>`

---USER-DESCRIPTION---
