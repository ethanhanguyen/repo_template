# AGENTS.md — {PROJECT_NAME}

## Plan-first rule (non-negotiable)

No code changes without a plan. Run `/plan <description>` first for any feature or bug fix.
Then `/pr` to implement. Trivial changes (typos, formatting) skip `/plan` but still log in progress.md.

## Session protocol

### Start
1. Read `docs/index.md`
2. Read `docs/plans/progress.md`
3. Read `docs/navigation.md`
4. Read `docs/archive/learnings.md` (last 30 lines)

### Close
1. Update `docs/navigation.md` — Current focus + Scout corrections (grep shortcuts, anti-patterns, better search strategies)
2. Log learnings to `docs/archive/learnings.md`
3. Update `docs/plans/progress.md`

## Task routing

| Trigger | Action |
|---------|--------|
| `/plan <description>` or "plan for" | Plan only: create spec, phase plan, PR plans, ADRs. Commit docs to main. No code. See `docs/commands/plan.md`. |
| `/pr <N\|keywords>` or `/pr` or "create a PR" | Execute one planned PR. Requires prior `/plan`. `/pr` alone picks next in queue. See `docs/commands/pr.md` for the 4-phase protocol. Never skip a phase. |
| `/audit_pr <N\|all>` or "audit PR" | Audit PRs for security, performance, bugs, logic holes, dead code, unwired code. Propose fixes, apply with quality gates, squash merge to main. See `docs/commands/audit_pr.md`. |
| New feature or bug fix | Run `/plan` first, then `/pr` |
| Quick PR (no plan doc needed) | Trivial changes only: typos, formatting, one-liners. Still run quality gates. |

## Quality Gates (self-check every PR before claiming done)

### Correctness

| Rule | What it means |
|------|--------------|
| **No logic holes** | Every branch covered. Edge cases handled. Invariants preserved. No inverted guards. |
| **No (potential) bugs** | Null/undefined safety. Correct types. No race conditions. No off-by-one errors. |
| **No unwired code** | Every function/component/endpoint is called. Every route is connected. |
| **No dead/orphaned code** | No unreachable paths. No unused imports. No variables assigned but never read. |

### Quality

| Rule | What it means |
|------|--------------|
| **Surgical** | Diff touches only files for stated goal. No unrelated refactoring. |
| **Explicit** | Error messages actionable. Types explicit. Every external call has error handling. Timeouts on network calls. |
| **Minimal** | No speculative features. No commented-out blocks. |
| **Not duplicated** | Same logic in one place. Shared utility over copy-paste. |
| **Not under-optimized** | No missing memo/cache on pure functions. No redundant API calls. No unbatched writes. |

### Safety

| Rule | What it means |
|------|--------------|
| **Conventions** | Matches neighboring file patterns. Uses existing utilities before new code. |
| **Covered** | New code ≥{threshold}% coverage. Every branch tested. |
| **Secure** | No secrets, tokens, or credentials. Inputs validated at boundaries. Resources cleaned up. |
