# CLAUDE.md — repo_template

## Plan-first rule

For every feature or bug fix, before writing any code:

1. Create PR plan doc in `docs_template/plans/PR{N}-{desc}.md` using `PR-prompt-template.md`
2. Update `docs_template/plans/progress.md`
3. Update `docs_template/architecture.md` if applicable
4. Update `README.md` if applicable
5. Write code, then follow the enforcement flow in `docs_template/commands/pr.md` (check.sh → behavioral self-review → commit → auto merge)

Trivial tasks (typos, formatting) skip step 1 but still log in progress.md.

## Session protocol

### Start
1. Read `docs_template/index.md`
2. Check `docs_template/archive/learnings.md` for gotchas

### Close
1. Update `docs_template/navigation.md` current focus
2. Log to `docs_template/archive/learnings.md`
3. Update `docs_template/plans/progress.md`

## Task routing

| Trigger | Action |
|---------|--------|
| `/plan <description>` or "plan for" | Plan only: create spec, phase plan, PR plans, ADRs. Commit docs to main. No code. See `docs_template/commands/plan.md`. |
| `/pr <N\|keywords>` or `/pr` or "create a PR" | Execute one planned PR. Requires prior `/plan`. `/pr` alone picks next in queue. See `docs_template/commands/pr.md` for the 4-phase protocol. Never skip a phase. |
| New feature or bug fix | Run `/plan` first, then `/pr` |
| Quick PR (no plan doc needed) | Trivial changes only: typos, formatting, one-liners. Still run quality gates. |

## Quality gates
- **Automated**: `bash scripts/check.sh` — single command, all computer-checkable gates
- **Behavioral** (self-check every PR before claiming done):

| Rule | What it means |
|------|--------------|
| **Surgical** | Diff touches only files for stated goal. No unrelated refactoring. |
| **Explicit** | Error messages actionable. Types explicit. Every external call has error handling. Timeouts on network calls. |
| **Minimal** | No speculative features. No dead code. No commented-out blocks. |
| **Conventions** | Matches neighboring file patterns. Uses existing utilities before new code. |
| **Covered** | New code ≥90% coverage. Every branch tested. |
| **Secure** | No secrets, tokens, or credentials. Inputs validated at boundaries. Resources cleaned up. |

- Verify template consistency: grep for `{PLACEHOLDER}` across all templates, ensure catalog in INSTALL.md is accurate
- Test generation: run INSTALL.md protocol against a dummy project to verify output
- Post-coding: follow enforcement flow in `docs_template/commands/pr.md` gates 3–6 in order (check.sh → behavioral self-review → commit → auto merge)
