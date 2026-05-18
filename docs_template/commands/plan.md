# /plan — Planning & discussion

This file is injected in place of `/plan`. The user's task description is the text appended after this file's content.

**Extract `<description>`**: look for the text that follows the delimiter `---USER-DESCRIPTION---` at the end of this file — that is the `<description>`. Strip `<description`> text if present. Trim whitespace. If nothing after the delimiter (or only `<description`>), respond: "You invoked /plan but didn't provide a description. Usage: /plan <feature_description>"

Also trigger on "plan for <description>" or "create a plan for <description>" (verbatim match in user message).

## Rules

- **Docs only**: no code implementation. Create docs, commit to main, push, stop.
- **Approval gates**: I3 (solution proposal) and A6 (final summary). I1 (investigation summary) and I2 (solution options) are FYI only — no approval asked. Steps A1–A5 proceed without stopping — agent makes best judgments and moves on. No spec, phase plan, PR doc, or ADR file is written until A6 is approved.
- **Stop rule**: after presenting I3 or A6 and asking for approval, STOP. Wait for user response. If `approved` → continue on same turn. If feedback → re-propose (I2) / re-draft, re-present, stop.
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

Create a todo list using TodoWrite with these items:

| # | Task | Status flow |
|---|------|-------------|
| 1 | I0 — Initialize + dispatch investigation | pending → in_progress → completed |
| 2 | I1 — Present investigation summary (FYI only) | pending → in_progress → completed |
| 3 | I2 — Propose solutions (pros/cons/recommendation) | pending → in_progress → completed |
| 4 | I3 — Solution approval gate | pending → in_progress → action_required (while waiting) |
| 5 | A1 — Assess complexity | pending → in_progress → completed |
| 6 | A2 — Draft spec (Simple → cancelled) | pending → in_progress → completed/cancelled |
| 7 | A3 — Draft phase plan (Simple → cancelled) | pending → in_progress → completed/cancelled |
| 8 | A4 — Draft PR docs | pending → in_progress → completed |
| 9 | A5 — Draft ADRs (none needed → cancelled) | pending → in_progress → completed/cancelled |
| 10 | A6 — Final approval gate | pending → in_progress → action_required (while waiting) |
| 11 | B1 — Write docs to files | pending → in_progress → completed |
| 12 | B2 — Update tracking docs | pending → in_progress → completed |
| 13 | B3 — Commit to main + push | pending → in_progress → completed |

Rules:
- Update status in real-time. Only one `in_progress` at a time.
- Gate steps (I3, A6): set to `action_required` when presenting and waiting for user.
- Cancelled steps still get marked (not deleted).
- This TODO list replaces any previous.

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
8. Mark I0 `approved`, `current_step: I1`. Mark I0 todo `completed`, I1 todo `in_progress`.
9. Add row to `docs/plans/progress.md` → `## Active plan sessions` table:

   ```
   | {slug} | I1 | {today} | {today} |
   ```

*→ Update plan-state.md: I0 approved + current_step=I1*

## Step I1 — Present investigation summary (FYI only, no approval)

1. **Present** the investigation report with a compact summary:
   - Bug: root cause (1 line), affected files
   - Feature: relevant modules, patterns to follow, integration points
   - Always include the raw agent output (collapsed) below the summary

2. Do NOT ask for approval. State: "Investigation summary above. Next: proposing solutions."

3. Mark I1 `approved`, `current_step: I2`. Store `investigation_report` field in plan-state.md. Mark I1 todo `completed`, I2 todo `in_progress`. Continue immediately.

*→ Update plan-state.md: I1 approved + current_step=I2 + investigation report stored*

## Step I2 — Solution proposal

1. **Goal**: propose 2–3 distinct solution approaches based on the investigation. Do NOT draft specs or PR docs yet.

2. **Format** for each option:

   ### Option {A|B|C}: {short label}
   - **Approach**: 1–2 sentences describing the solution
   - **Pros**: bullet list of advantages
   - **Cons**: bullet list of disadvantages / risks
   - **Effort**: Simple/Medium/Large (1 sentence)

3. **Recommendation**: pick one option and explain WHY — tie to project conventions, existing patterns, risk minimization, or explicit tradeoff choice.

4. Do NOT ask for approval yet. State: "---" separator after recommendation, then continue to I3.

5. Mark I2 `approved`, `current_step: I3`. Mark I2 todo `completed`, I3 todo `in_progress` with status `action_required`. Continue immediately to I3.

*→ Update plan-state.md: I2 approved + current_step=I3*

## Step I3 — Solution approval gate

1. **Present** the solution options + recommendation (already drafted in I2).

2. **Ask**: "Select approach or approve the recommendation. Reply **approved** (accepts recommendation), or specify **Option {A|B|C}**, or tell me what to reconsider."

3. **Wait for user response**:
   - `approved` → use the recommended option, mark I3 `approved`, `current_step: A1`. Update `docs/plans/progress.md` → Active plan sessions: `Step` to `A1`, update `Last activity`. Mark I3 todo `action_required` → `completed`, A1 todo `in_progress`. Proceed immediately to Step A1.
   - `Option A` / `Option B` / `Option C` → use that option, mark I3 `approved`, `current_step: A1`. Update `docs/plans/progress.md` → Active plan sessions: `Step` to `A1`, update `Last activity`. Mark I3 todo `action_required` → `completed`, A1 todo `in_progress`. Proceed immediately to Step A1.
   - Feedback → re-draft I2 with new guidance (add/remove options, re-evaluate), re-present I2+I3, stop.

*→ Update plan-state.md: I3 approved + current_step=A1 + chosen solution stored*

---

# Phase A — Discuss & Draft
(verbal only, nothing written to docs/; tracking in /tmp/plan-state-{slug}.md)

Context: use `investigation_report` and `chosen_solution` (from I3) throughout.

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

**Frontend PRs**: if the PR touches UI code, the PR doc **must** include
`## Visual design` (format in `docs/plans/PR-prompt-template.md`). Must
include design rationale — justify each choice from the user's perspective
(scanning pattern, glanceability, affordance, information hierarchy). No
hardcoded hex. Rejected without it.

## Step A5 — Draft ADRs (if applicable)

If architectural decisions needed: draft verbally using `docs/decisions/YYYY-MM-DD-decision-template.md`. → mark A5 approved, `current_step: A6`. If none → skip A5.

## Step A6 — Final approval gate

1. Present compact summary:
   - Tier, spec status, phase plan, PR list (PR{N0}...), ADRs
2. **Ask**: "Approve plan? Reply **approved** to write docs or tell me what to change."
3. **Wait for user response**:
   - `approved` → mark A6 approved, `current_step: B1`. Update `docs/plans/progress.md` → Active plan sessions: `Step` to `B1`, update `Last activity`. Mark A6 todo `action_required` → `completed`, B1 todo `in_progress`. Proceed to Phase B.
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
   - Update `## Active plan sessions` row: set `Step` to `B2`, update `Last activity`

2. **TODO list**: Mark B2 `in_progress`, B1 `completed`.

3. **`docs/navigation.md`**:
   - Set **Current focus** → this plan's description, Key files → expected files
   - Set Phase → current phase number, Branch → `main`

4. **`docs/architecture.md`**:
   - Update **Module boundaries**, **Data flow**, or **Tech stack** if changed
   - Update **Key design decisions** if new ADRs

5. **`docs/index.md`**:
   - Add spec link to **Current specs** (Medium/Large)
   - Add phase plan link to **Plans**
   - Add ADR links to **Decisions**

6. Mark B2 `approved`, `current_step: B3`. Mark B2 todo `completed`, B3 todo `in_progress`.

## Step B3 — Commit to main + push

1. `git add docs/`
2. `git commit -m "docs: plan {slug} — spec, phase{N} plan, {N} PRs"`
3. `git push origin main`
4. Delete `/tmp/plan-state-{slug}.md` (plan committed, state file no longer needed)
5. **`docs/plans/progress.md`**: remove plan row from `## Active plan sessions`.
6. Mark B3 todo `completed`. Report: plan doc paths, PRs created (numbers + descriptions), branch `main`, next step: `/pr <N|keywords>`

---USER-DESCRIPTION---
