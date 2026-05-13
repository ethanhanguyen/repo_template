# Navigation — read on session start

## Current focus

<!-- UPDATE per session -->
- PR / Task: {what are you working on?}
- Key files: {files most relevant to current task}

## Task map

| Task | Action |
|---|---|
| Implementing a PR | Read the PR plan doc → grep `src/` for module names mentioned |
| Debugging | Grep for module name in `docs/archive/learnings.md` |
| Writing tests | Read `docs/testing.md` first |
| Architecture | Read `docs/architecture.md` (stable — read once, not every session) |
| Code review | Run `bash scripts/check.sh` + behavioral self-review (see Quality Gates) |
| New feature / bug fix | Create PR plan doc first, then code |

## Context protocol

- Never `ls` or `read` whole directories — grep for symbol/function names first
- Only read full spec/docs files when the task explicitly links to them
- `docs/architecture.md` is stable reference — read once, not every session
- Read neighboring files before writing new code — match conventions

## Always verify

<!-- Project-specific checklist. Add to this during development. -->
- No secrets, tokens, or credentials in diff
- No `print()` / `console.log()` / `dbg!()` left in code
- Run `bash scripts/check.sh` — all gates pass
- Grep for `{PLACEHOLDER}` across templates before shipping

## Scout corrections

<!-- Ranked by tokens_saved descending. Max 7. Purge bottom when full. -->

| Symptom | Correct action | Saved |
|---|---|---|
| {symptom-you-hit} | {grep-command-that-would-have-solved-it} | {est%} |

## Session close (MANDATORY)

Before ending any session, update these sections:

### 1. Current focus
Replace lines 4-6 with the PR/Task and key files for the next session.

### 2. Scout corrections
If this session wasted tokens on a bad search, add one row:
`| <symptom> | <grep that solves it> | <est%> |`
Rank by `Saved` descending. Max 7 rows. Purge bottom when full.

### 3. Archive learnings
Log decisions, risks, anti-patterns, bugs to `docs/archive/learnings.md`.
