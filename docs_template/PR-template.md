# PR Template

> **Branch**: `pr<N>-<description>`
> **Base**: `main`

## Summary

<!-- 1-3 bullet points describing what this PR does and why -->

## Related

- Phase: `{phase_plan_link}`
- ADRs: `{adr_links}`
- Dependencies: PR#{N1}, PR#{N2}

## Enforcement

1. Create branch: `pr<N>-<description>`
2. TDD: write failing tests → implement → refactor
3. Code review: pass `docs/code-review.md` checklist locally
4. Commit: conventional commit message, merge when ready

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

## Pre-review checklist (run locally before opening PR)

- [ ] `{lint_cmd}` — clean
- [ ] `{typecheck_cmd}` — clean
- [ ] `{test_cmd}` — all passing
- [ ] `{build_cmd}` — succeeds (if applicable)
- [ ] Grep for `{debug_print_pattern}` — none
- [ ] Grep for `{todo_pattern}` — addressed or tracked
- [ ] No secrets, tokens, or credentials in code

## Code review gate

- [ ] 4-phase review passed (`docs/code-review.md`)
- [ ] No rejection triggers fired

## Final

- [ ] All checkboxes above ticked
- [ ] Docs updated if needed
- [ ] Ready to merge
