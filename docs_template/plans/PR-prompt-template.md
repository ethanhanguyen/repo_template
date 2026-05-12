# PR{N} Prompt — {Brief description}

> **Phase**: {phase plan link}
> **Base branch**: `main`
> **Dependencies**: PR#{X}, PR#{Y}

## Summary

<!-- What needs to be built and why -->

{summary}

## Related

- Spec: `docs/specs/{spec_file}.md`
- ADR: `docs/decisions/{adr_file}.md`
- Dependencies: PR#{N1}, PR#{N2}

## Enforcement

1. Create branch: `pr{N}-{description}`
2. TDD: write failing tests → implement → refactor
3. Code review: pass `docs/code-review.md` checklist locally
4. Commit and merge

## Implementation

### Part 1: {component name}

**File**: `{file_path}`

**Type signatures / interface**:
```
{code_block}
```

**Constraints**:
- {constraint_1}
- {constraint_2}

**Error handling**:
- {error_case} → {behavior}

### Part 2: {component name}

**File**: `{file_path}`

**Type signatures / interface**:
```
{code_block}
```

**Constraints**:
- {constraint_1}

**Error handling**:
- {error_case} → {behavior}

## Test requirements

### Unit tests

- [ ] `{test_name_1}` — {what it verifies}
- [ ] `{test_name_2}` — {what it verifies}
- [ ] `{test_name_3}` — {edge case}

### Integration tests

- [ ] `{test_name_4}` — {what it verifies}

### E2E tests (if applicable)

- [ ] `{test_name_5}` — {end-to-end scenario}

## Approach checklist

- [ ] State assumptions explicitly
- [ ] Minimum code — no speculative features
- [ ] Follow existing code style and conventions
- [ ] No "improvements" to unrelated code
- [ ] Error handling for every external call boundary
- [ ] All new code has >=90% coverage

## Checklist

### Pre-review (run locally)

- [ ] `{lint_cmd}` — clean
- [ ] `{typecheck_cmd}` — clean
- [ ] `{test_cmd}` — all passing
- [ ] Grep for debug prints — none
- [ ] No secrets in code

### Code review gate

- [ ] 4-phase review passed (`docs/code-review.md`)
- [ ] No rejection triggers

### Final

- [ ] All checkboxes ticked
- [ ] Ready to merge
