# CLAUDE.md — {PROJECT_NAME}

## Plan-first rule (non-negotiable)

For **every feature or bug fix**, before writing any code:

1. **Create PR plan doc** in `docs/plans/PR{N}-{desc}.md` using `docs/plans/PR-prompt-template.md`
2. **Update `docs/plans/progress.md`** — add PR to table
3. **Update `docs/architecture.md`** if this changes module boundaries, data flow, or tech stack
4. **Update `README.md`** if this changes setup, usage, or public API
5. Write code, then follow the enforcement flow in `docs/PR-template.md` (quality gates → code review → commit → auto merge)

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
| `/pr <description>` or "create a PR" | Run full atomic PR workflow: plan → implement → quality gates → code review (4-phase) → open PR → auto merge to main. See `docs/commands/pr.md` for the 6-phase protocol. Never skip a phase. |
| New feature or bug fix | Create PR plan doc first, then code |
| Quick PR (no plan doc needed) | Trivial changes only: typos, formatting, one-liners. Still run quality gates. |
| Debug / investigate | Run tests to reproduce, grep for root cause |
| Architecture decision | Write ADR in `docs/decisions/YYYY-MM-DD-{title}.md` |
| Code review | Follow `docs/code-review.md` 4-phase checklist |
| Writing tests | Follow `docs/testing.md` authoring guide |
| Implementation done | Follow `docs/PR-template.md` enforcement gates in order (quality gates → code review → commit → auto merge — never skip) |
| Phase complete | Run `docs/code-review.md` gates, update progress |

## Quality gates (run before claiming "done")

- [ ] `{lint_cmd}` — clean
- [ ] `{typecheck_cmd}` — clean
- [ ] `{test_cmd}` — all passing
- [ ] No secrets, debug prints, or TODOs in code
- [ ] Coverage meets thresholds in `docs/testing.md`
- [ ] PR plan doc updated with actual results
- [ ] `docs/plans/progress.md` updated
