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
3. Quality gates: `bash scripts/check.sh` — all passing
4. Behavioral self-review: self-check against Quality Gates in `AGENTS.md`
5. Commit and auto merge to main

## Implementation

<!--
  parallel_group: Parts with the same number run in parallel (different files, no shared
  interfaces both modify). Omit or leave as {N} to run sequentially.
-->

### Part 1: {component name}

**parallel_group**: {N}

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

**parallel_group**: {N}

**File**: `{file_path}`

**Type signatures / interface**:
```
{code_block}
```

**Constraints**:
- {constraint_1}

**Error handling**:
- {error_case} → {behavior}

## Visual design

<!-- Required when PR touches UI code (components, pages, dialogs, styling,
     layout). Pick the format that fits: wireframe, layout diagram, state
     diagram (load→empty→error), or data display (tables/lists).

     Every visual spec must cover:
     - Layout + sizing (px/rem) with clear hierarchy
     - Typography (size, weight, clamp, --color-token)
     - All states: default, hover, active, focus, disabled, loading, empty, error
     - Colors via design tokens only (--color-*, --space-*, --radius-*). No hex.

     After the wireframe, add a "Design rationale" table justifying each choice
     from the user's perspective — why this layout, why this size, why this color.

     Example: Dashboard stat widget — replace with your component: -->

```
┌─────────────────────────────────────┐
│ Revenue                        ⓘ   │  label (13px, --color-muted)
│                                     │       ⓘ shows tooltip on hover
│ $12,450       ▲ 12.5%               │  value (24px, bold, --color-text)
│                                     │  delta (13px, color-coded)
│ ▁▂▃▄▃▅▆▇▆█▇▆                      │  sparkline (32px, --color-accent)
│                                     │
│ vs. $11,067 last month              │  context (11px, --color-muted)
└─────────────────────────────────────┘
  padding: 16px
  bg: --color-surface
  border: 1px --color-border
  radius: --radius-lg
  min-width: 240px

  hover:   border → --color-accent, shadow 0 2px 8px (--color-shadow)
  active:  border --color-accent, bg --color-accent at 3%
  focus:   outline 2px --color-accent, offset 2px

  loading:  skeleton pulse — label bar (80px) → value bar (120px) → sparkline bar
            (full width), 200ms stagger between each
  empty:    "—" centered for value, sparkline area hidden, context line hidden
  error:    value → "Failed" (--color-error), sparkline hidden,
            [Retry] link below context line

  positive: ▲ 12.5% (--color-success)
  negative: ▼ 8.3%  (--color-error, no green ever for drops)
```

### Design rationale

| Decision | Why (user perspective) |
|----------|------------------------|
| Value at 24px bold | Primary metric — largest element. Users scan for the number first (F-pattern). Bold gives it weight against surrounding labels |
| Sparkline below value | Trend context after the number registers. No axis labels — glanceable signal, not analytical deep-dive |
| Delta right-aligned, color-coded | Change direction is secondary to absolute value. Red/green is pre-attentive — users see direction before reading the number |
| Info icon + tooltip | Metric definition hidden until needed — reduces visual noise. Hover-triggered so discoverable without hunting |
| 16px padding, 1px border | Breathing room signals "readable." Subtle border grounds the card without competing for attention |
| Hover shadow lift | Affordance: card is clickable. Subtle blur (8px) — signals interactivity without gimmick |
| Staggered skeleton pulse | Value loads after label — matches importance order. 200ms stagger feels responsive, not laggy |
| Negative delta always red | Never green for drops — green = good is the only safe universal convention. No inverted colors |

**Tokens**: `--color-surface`, `--color-border`, `--color-text`, `--color-muted`, `--color-accent`, `--color-success`, `--color-error`, `--color-shadow`, `--radius-lg`

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

- [ ] `bash scripts/check.sh` — all passing
- [ ] Behavioral self-review per `AGENTS.md` Quality Gates (Surgical, Explicit, Minimal, Conventions, Covered, Secure)

### Final

- [ ] All checkboxes ticked
- [ ] Ready to merge
