# CLAUDE.md — {PROJECT_NAME}

## Plan-first rule (non-negotiable)

For **every feature or bug fix**, before writing any code:

1. **Create PR plan doc** in `docs/plans/PR{N}-{desc}.md` using `docs/plans/PR-prompt-template.md`
2. **Update `docs/plans/progress.md`** — add PR to table
3. **Update `docs/architecture.md`** if this changes module boundaries, data flow, or tech stack
4. **Update `README.md`** if this changes setup, usage, or public API
5. Write code, then follow the enforcement flow in `docs/PR-template.md` (check.sh → behavioral self-review → commit → auto merge)

For trivial tasks (typo fix, formatting, one-line change), skip the PR plan but still log in progress.md.

## Session protocol

### Start
1. Read `docs/index.md` → find current work
2. Read `docs/plans/progress.md` → check blockers, active PRs
3. Read `docs/archive/learnings.md` (last 30 lines) → avoid repeating past mistakes
4. Update `Current focus` in `docs/navigation.md`

### During
- Search before reading: grep/glob first, read only what you need
- Match existing conventions: read neighboring files before writing new code
- No speculative features: only code needed for the stated goal
- No unrelated refactoring: surgical changes only

### Close
1. Update `Current focus` in `docs/navigation.md`
2. Log learnings to `docs/archive/learnings.md` (decisions, risks, anti-patterns, bugs, gotchas)
3. Update `docs/plans/progress.md` (PR status, session log)

## Task routing

| Trigger | Action |
|---------|--------|
| `/pr <description>` or "create a PR" | Run full atomic PR workflow: plan → implement → quality gates → behavioral self-review → open PR → auto merge to main. See `docs/commands/pr.md` for the 5-phase protocol. Never skip a phase. |
| New feature or bug fix | Create PR plan doc first, then code |
| Quick PR (no plan doc needed) | Trivial changes only: typos, formatting, one-liners. Still run quality gates. |
| Debug / investigate | Run tests to reproduce, grep for root cause |
| Architecture decision | Write ADR in `docs/decisions/YYYY-MM-DD-{title}.md` |
| Code review | Run `bash scripts/check.sh` + behavioral self-review (see Quality Gates below) |
| Writing tests | Follow `docs/testing.md` authoring guide |
| Implementation done | Follow `docs/PR-template.md` enforcement gates in order (quality gates → code review → commit → auto merge — never skip) |
| Phase complete | Run `bash scripts/check.sh`, update progress |

## Quality Gates (self-check every PR before claiming done)

| Rule | What it means |
|------|--------------|
| **Surgical** | Diff touches only files for stated goal. No unrelated refactoring. |
| **Explicit** | Error messages actionable. Types explicit. Every external call has error handling. Timeouts on network calls. |
| **Minimal** | No speculative features. No dead code. No commented-out blocks. |
| **Conventions** | Matches neighboring file patterns. Uses existing utilities before new code. |
| **Covered** | New code ≥{threshold}% coverage. Every branch tested. |
| **Secure** | No secrets, tokens, or credentials. Inputs validated at boundaries. Resources cleaned up. |
