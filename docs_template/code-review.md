# Code Review Checklist

## Automated gates

Run `bash scripts/check.sh` — all gates must pass.

## Behavioral self-review

Self-check against Quality Gates in `AGENTS.md`:
- **Surgical** — diff touches only files for stated goal
- **Explicit** — error messages actionable, types explicit, external calls have error handling + timeouts
- **Minimal** — no speculative features, no dead code, no commented-out blocks
- **Conventions** — matches neighboring file patterns, uses existing utilities before new code
- **Covered** — new code ≥{threshold}% coverage, every branch tested
- **Secure** — no secrets/tokens/credentials, inputs validated at boundaries, resources cleaned up

## Project-specific

```yaml
# project-specific rejections
{project_rejections}

# project-specific lint/test commands
lint: "{lint_cmd}"
typecheck: "{typecheck_cmd}"
test: "{test_cmd}"
coverage_threshold: {threshold}
```
