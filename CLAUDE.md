# CLAUDE.md — repo_template

## Plan-first rule

For every feature or bug fix, before writing any code:

1. Create PR plan doc in `docs_template/plans/PR{N}-{desc}.md` using `PR-prompt-template.md`
2. Update `docs_template/plans/progress.md`
3. Update `docs_template/architecture.md` if applicable
4. Update `README.md` if applicable
5. Then code

Trivial tasks (typos, formatting) skip step 1 but still log in progress.md.

## Session protocol

### Start
1. Read `docs_template/index.md`
2. Check `docs_template/archive/learnings.md` for gotchas

### Close
1. Update `docs_template/navigation.md` current focus
2. Log to `docs_template/archive/learnings.md`
3. Update `docs_template/plans/progress.md`

## Quality gates
- Verify template consistency: grep for `{PLACEHOLDER}` across all templates, ensure catalog in INSTALL.md is accurate
- Test generation: run INSTALL.md protocol against a dummy project to verify output
