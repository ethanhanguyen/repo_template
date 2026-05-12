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
3. **Quality gates** — run locally. ALL must be clean before proceeding:
   - `{lint_cmd}` — zero warnings
   - `{typecheck_cmd}` — zero errors
   - `{test_cmd}` — all passing
   - `{build_cmd}` — succeeds (if applicable)
   - Grep `{env_read_pattern}` — no raw env reads outside config layer
   - Grep `{debug_print_pattern}` — none
   - Grep `{todo_pattern}` — addressed or tracked
   - No secrets, tokens, or credentials in code
4. **Code review**: pass all 4 phases of `docs/code-review.md` — zero rejection triggers fired
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

## Gate 3 — Quality gates (detailed checklist)

- [ ] `{lint_cmd}` — clean
- [ ] `{typecheck_cmd}` — clean
- [ ] `{test_cmd}` — all passing
- [ ] `{build_cmd}` — succeeds (if applicable)
- [ ] Grep for `{debug_print_pattern}` — none
- [ ] Grep for `{todo_pattern}` — addressed or tracked
- [ ] No secrets, tokens, or credentials in code

## Gate 4 — Code review

- [ ] 4-phase review passed (`docs/code-review.md`): automated gates → diff inspection → code patterns → behavioral gates
- [ ] No rejection triggers fired (see rejection triggers in `docs/code-review.md`)
- [ ] Phase 5.1: confirm Phase 4 automated gates still green
- [ ] Phase 5.2: diff scope clean, no dead code, no duplicated logic
- [ ] Phase 5.3: conventions matched, defensive error handling, resource management
- [ ] Phase 5.4: simplicity, surgical, explicit, goal-driven — all passed

## Git workflow (gates 5–6)

- [ ] Commit with conventional commit message
- [ ] Auto merge to main (`gh pr merge --auto --squash` or manual `gh pr merge --squash`)
- [ ] Delete feature branch after merge
- [ ] All gates above passed with fresh verification
- [ ] Docs updated if needed (architecture.md, README.md, progress.md)
