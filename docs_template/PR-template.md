# PR Template

> **Branch**: `pr<N>-<description>`
> **Base**: `main`

## Summary

<!-- 1-3 bullet points describing what this PR does and why -->

## Related

- Phase: `{phase_plan_link}`
- ADRs: `{adr_links}`
- Dependencies: PR#{N1}, PR#{N2}

> **Enforcement**: Follow the 5-phase atomic workflow in `docs/commands/pr.md`. After each phase, show fresh verification evidence before claiming pass.

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

