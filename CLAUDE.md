# CLAUDE.md — repo_template

## Plan-first rule

For every feature or bug fix, before writing any code:

1. Create PR plan doc in `docs_template/plans/PR{N}-{desc}.md` using `PR-prompt-template.md`
2. Update `docs_template/plans/progress.md`
3. Update `docs_template/architecture.md` if applicable
4. Update `README.md` if applicable
5. Write code, then follow the enforcement flow in `docs_template/PR-template.md` (quality gates → code review → commit → auto merge)

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
| `/pr <description>` or "create a PR" | Run full atomic PR workflow: plan → implement → quality gates → code review (4-phase) → open PR → auto merge to main. See `docs_template/commands/pr.md` for the 6-phase protocol. Never skip a phase. |
| New feature or bug fix | Create PR plan doc first, then code |
| Quick PR (no plan doc needed) | Trivial changes only: typos, formatting, one-liners. Still run quality gates. |

## Quality gates
- Verify template consistency: grep for `{PLACEHOLDER}` across all templates, ensure catalog in INSTALL.md is accurate
- Test generation: run INSTALL.md protocol against a dummy project to verify output
- Post-coding: follow enforcement flow in `docs_template/PR-template.md` gates 3–6 in order (quality gates → code review → commit → auto merge)
