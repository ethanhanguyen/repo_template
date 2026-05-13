# PR Template

> **Branch**: `pr<N>-<description>`
> **Base**: `main`

## Summary

<!-- 1-3 bullet points describing what this PR does and why -->

## Related

- Phase: `{phase_plan_link}`
- ADRs: `{adr_links}`
- Dependencies: PR#{N1}, PR#{N2}

## Enforcement (non-negotiable — follow in order, never skip a gate)

1. **Create branch**: `pr<N>-<description>` from `main`
2. **TDD**: write failing tests → implement → refactor
3. **Quality gates**: `bash scripts/check.sh` — all passing
4. **Behavioral self-review**: self-check against Quality Gates in `AGENTS.md` (Surgical, Explicit, Minimal, Conventions, Covered, Secure)
5. **Commit**: conventional commit message (`feat:`, `fix:`, `docs:`, etc.)
6. **Auto merge to main**: `gh pr merge --auto --squash` (or manual `gh pr merge --squash`), then delete feature branch

Never claim a gate is passed without fresh verification evidence (run the command, read the output, then claim).

## Implementation

<!-- Per component/section: describe types, signatures, constraints, error handling -->

### {Component A}

- [ ] {task description}
- [ ] Tests cover: {edge cases}

### {Component B}

- [ ] {task description}
- [ ] Tests cover: {edge cases}

## Implementation progress

| Part | Status | Coverage | Lint |
|------|--------|----------|------|
| {Component A} | ⬜ | —% | — |
| {Component B} | ⬜ | —% | — |

## Test requirements

### Unit tests

- [ ] `{test_name_1}` — {what it verifies}
- [ ] `{test_name_2}` — {what it verifies}

### Integration tests

- [ ] `{test_name_3}` — {what it verifies}

### E2E tests (if applicable)

- [ ] `{test_name_4}` — {what it verifies}

## Approach checklist

- [ ] State assumptions explicitly
- [ ] Minimum code — no speculative features
- [ ] Follow existing code style and conventions
- [ ] No "improvements" to unrelated code
- [ ] Error handling for every external call boundary
- [ ] All new code has >=90% coverage
- [ ] All new branches covered in tests

## Gate 3 — Quality gates

- [ ] `bash scripts/check.sh` — all passing

## Gate 4 — Behavioral self-review

- [ ] Self-check against Quality Gates in `AGENTS.md` (Surgical, Explicit, Minimal, Conventions, Covered, Secure)

## Git workflow (gates 5–6)

- [ ] Commit with conventional commit message
- [ ] Auto merge to main (`gh pr merge --auto --squash` or manual `gh pr merge --squash`)
- [ ] Delete feature branch after merge
- [ ] All gates above passed with fresh verification
- [ ] Docs updated if needed (architecture.md, README.md, progress.md)
