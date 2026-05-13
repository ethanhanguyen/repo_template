# /plan — Planning & discussion

This file is injected in place of `/plan`. The user's task description is the text appended after this file's content.

**Extract `<description>`**: look for the text that follows the delimiter `---USER-DESCRIPTION---` at the end of this file — that is the `<description>`. Strip `<description`> text if present. Trim whitespace. If nothing after the delimiter (or only `<description`>), respond: "You invoked /plan but didn't provide a description. Usage: /plan <feature_description>"

Also trigger on "plan for <description>" or "create a plan for <description>" (verbatim match in user message).

## Rules

- **Docs only**: no code implementation. Create docs, commit to main, push, stop.
- **Approval before files**: no spec, phase plan, PR doc, or ADR file is written until user approves the draft verbally.
- **Stop rule**: after presenting a draft and asking for approval, STOP. Wait for user response. If `approved` → continue to next step on same turn. If feedback → apply, re-present, stop.
- **Evidence before claims**: show fresh command output for every gate.

## Session resume (DO THIS FIRST EVERY TURN)

1. Glob `docs/plans/plan-state-*.md`
2. If **1 matching file** → read it, confirm: "Resuming plan: {slug} (Step {current_step})"
   - If `current_step` is `committed` → tell user: "Plan already committed. Use /pr to implement."
   - Else → jump to that step (skip earlier approved steps)
3. If **2+ matching files** → list slugs and current steps, ask: "Multiple plans in progress. Which to resume?"
4. If **0 matching files** but `docs/plans/progress.md` has `📋 Planned` rows → tell user: "No active plan session found, but planned PRs exist in progress.md. Ready for /pr."
5. If **0 matching files** and no planned PRs → fresh start at Step A0

## Progress tracking

Create a todo list:

1. Phase A — Discuss & draft (verbal only)
2. Phase B — Write & commit (after final approval)

---

# Phase A — Discuss & Draft

> **NO plan docs written to `docs/specs/`, `docs/plans/PR*.md`, or `docs/decisions/` during this phase.** Only discuss verbally. The `plan-state-{slug}.md` tracking file is the exception — write it immediately in A0.

## Step A0 — Initialize plan state

1. Derive `slug`: lowercase `<description>`, replace spaces with hyphens, strip special chars, max 40 chars.
2. Read `docs_template/plans/plan-state-template.md` for structure.
3. Create `docs/plans/plan-state-{slug}.md` with:
   - `slug`, `original_description`, `complexity_tier: unset`
   - `current_step: A1`
   - Empty `approvals` table, empty `change_log`
4. Check if `<description>` contains "approved" or "lgtm" (case-insensitive, as a separate word):
   - If YES → set ALL steps as pre-approved in plan-state.md. Skip Phase A entirely (agent still does mental drafting — assess, structure, plan — then jump to Phase B Step B1 and write complete docs).
   - If NO → set A1 `current_step`, proceed to Step A1.

## Step A1 — Assess complexity

1. Classify into one of three tiers:

| Tier | Criteria | Output |
|------|----------|--------|
| **Simple** | 1 PR, localized change, no new modules | 1 PR plan doc, no spec, no phase plan |
| **Medium** | 2–5 PRs, spans modules, new API/schema | spec + phase plan + N PR plan docs |
| **Large** | Multi-phase, major feature, new services | per-phase specs + per-phase plans + N PR plan docs |

2. **Present verbally**: "I classify this as **{tier}**. {1-sentence reasoning}. Does that look right?"

3. **Wait for user response**:
   - `approve`: "approved", "yes", "lgtm" → record tier in plan-state.md, mark A1 `approved`, set `current_step`:
     - Simple → `A6`
     - Medium/Large → `A2`
     - Proceed immediately (same turn).
   - `approved but <feedback>`: apply feedback, mark `approved`, note change in change_log, proceed.
   - Any other text → treat as feedback, re-classify/discuss, re-present, stop.

*→ Update plan-state.md: tier set + A1 approved + next current_step*

## Step A2 — Draft spec (Medium/Large only)

Skip if Simple tier.

1. Read `docs/specs/spec-template.md` for structure.
2. **Draft verbally** — present in conversation (do NOT write to file):

   ```
   ## Spec: {slug}

   ### Overview
   {2-3 sentences}

   ### Functional requirements
   - {FR1}
   - {FR2}

   ### Non-functional requirements
   - {NFR1}

   ### API endpoints / Data model (if applicable)
   {summary}

   ### Error handling
   {key cases}

   ### Open questions
   - {Q1}
   ```

3. **Ask**: "Does this spec look correct? Reply **approved** or tell me what to change."

4. **Wait for user response**:
   - `approved` → mark A2 `approved`, `current_step: A3`, proceed immediately.
   - `approved but <feedback>` → apply feedback, mark `approved`, note in change_log, proceed.
   - `skip` → mark A2 `approved` (skipped), `current_step: A3`, proceed.
   - Feedback → apply changes, re-present draft, stop.

5. **Rewind rule**: if feedback invalidates an already-approved earlier step (e.g. user wants Medium not Large → contradicts A1), mark that step AND all later steps back to `pending` in plan-state.md, restart from that step.

*→ Update plan-state.md: A2 approved + current_step=A3*

## Step A3 — Draft phase plan (Medium/Large only)

Skip if Simple tier.

1. Read `docs/plans/progress.md` — check **PR Status** table for highest PR number in use.
2. Let `base` = that number + 1 (or 0 if table empty).
3. Read `docs/plans/phase-plan-template.md` for structure.
4. Read `docs/architecture.md` for current module boundaries.
5. Determine phase number N from existing phase plans in `docs/plans/`.
6. **Draft verbally** — present (do NOT write to file):

   ```
   ## Phase {N} Plan: {name}

   ### Goal
   {one paragraph}

   ### PRs
   | PR | Name | Dependencies | Files | Approach |
   |----|------|--------------|-------|----------|
   | PR{N}0 | ... | — | ... | ... |
   | PR{N}1 | ... | PR{N}0 | ... | ... |

   ### Dependency graph
   PR{N}0 → PR{N}1 → ...

   ### Exit criteria
   - ...
   ```

7. **Ask**: "Does this phase breakdown look correct? Reply **approved** or tell me what to change."

8. **Wait for user response**:
   - `approved` → mark A3 `approved`, `current_step: A4`, proceed immediately.
   - `approved but <feedback>` → apply, mark `approved`, note change, proceed.
   - Feedback → apply, re-present, stop.
   - Rewind rule applies.

*→ Update plan-state.md: A3 approved + current_step=A4*

## Step A4 — Draft PR docs

For each PR in the phase plan (or the single PR for Simple tier), in order:

1. Read `docs/plans/PR-prompt-template.md` for structure.
2. **Draft verbally** — present:

   ```
   ## PR{N} — {name}

   ### Summary
   {what and why}

   ### Files
   - `{path}` (new/modified)

   ### Implementation parts
   | Part | File | Key interface |
   |------|------|---------------|
   | 1 | ... | ... |
   | 2 | ... | ... |

   ### Test requirements
   - {test_1}
   - {test_2}

   ### Dependencies
   PR#{X}
   ```

3. **Ask** (after each PR or as a batch for 3+ PRs): "Do these PR plans look correct? Reply **approved** or tell me what to change."
4. **Wait for user response** (same rules as above).
5. Rewind rule applies.

*→ Update plan-state.md: A4 approved + current_step=A5 (or A6 if no ADRs needed)*

## Step A5 — Draft ADRs (if applicable)

If the plan reveals architectural decisions (new module boundaries, tech stack changes, data flow changes, scaling model changes):

1. Read `docs/decisions/YYYY-MM-DD-decision-template.md`.
2. **Draft verbally** — for each decision:

   ```
   ## ADR: {title}

   ### Context
   {why this decision is needed}

   ### Decision
   {what we decided}

   ### Alternatives considered
   - {Alt 1} — {why rejected}
   - {Alt 2} — {why rejected}

   ### Consequences
   {positive and negative}
   ```

3. **Ask**: "Does this ADR look correct? Reply **approved** or tell me what to change."
4. **Wait for user response** (same rules).

If no architectural decisions → skip A5, mark as `skipped`.

*→ Update plan-state.md: A5 approved + current_step=A6*

## Step A6 — Final approval gate

1. **Present summary** of everything approved:

   ```
   ## Plan summary — {slug}

   - **Tier**: {tier}
   - **Spec**: {slug}.md — {N} FRs （"none" if Simple）
   - **Phase plan**: phase{N}-plan.md — {N} PRs （"none" if Simple）
   - **PR docs**: PR{N0}, PR{N1}, ...
   - **ADRs**: {N} decisions （"none"）
   ```

2. **Ask**: "All plan elements reviewed. Reply **approved** to write docs to files and commit to main, or tell me what to change."
3. **Wait for user response**:
   - `approved` → mark A6 `approved`, `current_step: B1`, proceed immediately to Phase B.
   - Feedback → go back to relevant step, re-draft that step + all downstream steps, re-present final summary, stop.

*→ Update plan-state.md: A6 approved + current_step=B1*

---

# Phase B — Write & Commit

> Only execute after A6 is approved (or pre-approved in A0). All files written are idempotent — if a file already exists with matching content, skip. If Phase B was interrupted (crash), re-run from B1 — it will detect existing files and fill gaps.

## Step B1 — Write all docs to files

Write each approved deliverable using the template structures:

1. **Spec** (Medium/Large only): `docs/specs/{slug}.md` — fill using approved A2 draft. Status: `Draft`.
2. **Phase plan** (Medium/Large only): `docs/plans/phase{N}-plan.md` — fill using approved A3 draft and `docs/plans/phase-plan-template.md`.
3. **PR docs**: `docs/plans/PR{N}-{pr-slug}.md` — one per PR. Fill using approved A4 drafts and `docs/plans/PR-prompt-template.md`. Set `parallel_group` annotations per phase plan dependency graph. Check `docs/navigation.md` **Scout corrections** for gotchas.
4. **ADRs** (if applicable): `docs/decisions/YYYY-MM-DD-{title}.md` — fill using approved A5 drafts.

## Step B2 — Update tracking docs

1. **`docs/plans/progress.md`**:
   - Add rows to **PR Status** table — status `📋 Planned`
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
4. Delete `docs/plans/plan-state-{slug}.md` (plan committed, state file no longer needed)
5. Report: plan doc paths, PRs created (numbers + descriptions), branch `main`, next step: `/pr <N|keywords>`

---USER-DESCRIPTION---
