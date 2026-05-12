# Phase {N} Plan — {Phase name}

## Goal

<!-- One paragraph: what does this phase accomplish? -->

{phase_goal}

## Prerequisites

- [ ] Phase {N-1} complete
- [ ] {other_prerequisite}

## PRs

| PR | Name | Dependencies | Files | Approach |
|----|------|--------------|-------|----------|
| PR{N}0 | {name} | — | {file_list} | {approach} |
| PR{N}1 | {name} | PR{N}0 | {file_list} | {approach} |

## Dependency graph

```
PR{N}0 → PR{N}1 → PR{N}2
```

## New / modified files

| File | PR | Status |
|------|-----|--------|
| `{file_path}` | PR{N}X | New |
| `{file_path}` | PR{N}Y | Modified |

## Exit criteria

- [ ] All PRs merged
- [ ] `{test_cmd}` — all passing
- [ ] Coverage >= {threshold}%
- [ ] `{lint_cmd}` — clean
- [ ] `{e2e_cmd}` — all passing (if applicable)
- [ ] Manual validation checklist complete
- [ ] No unresolved blockers

## Validation checklist

<!-- Specific manual checks for this phase -->

- [ ] {validation_item_1}
- [ ] {validation_item_2}
- [ ] {validation_item_3}

## Go / No-Go

| Criterion | Threshold | Actual | Pass? |
|-----------|-----------|--------|-------|
| {criterion_1} | {threshold} | — | ⬜ |
| {criterion_2} | {threshold} | — | ⬜ |

**Decision**: {Go / No-Go}
