# Code Review Checklist

## Phase 1 — Automated gates

Run locally before human review:

- [ ] Lint: `{lint_cmd}` — zero warnings
- [ ] Typecheck: `{typecheck_cmd}` — zero errors
- [ ] Tests: `{test_cmd}` — all passing
- [ ] Build: `{build_cmd}` — succeeds (if applicable)
- [ ] E2E: `{e2e_cmd}` — all passing (if applicable)
- [ ] Benchmark: `{benchmark_cmd}` — no regressions (if applicable)
- [ ] Grep `{env_read_pattern}` — no raw env reads outside config layer
- [ ] Grep `{debug_print_pattern}` — no debug prints
- [ ] Grep `{todo_pattern}` — TODOs addressed or tracked in issue tracker

## Phase 2 — Diff inspection

- [ ] Scope: PR only touches files related to the stated goal
- [ ] No unrelated refactoring or "improvements"
- [ ] No dead code or commented-out blocks
- [ ] Imports: added imports are used; removed imports had all usages removed
- [ ] No duplicated logic — grep for similar patterns before adding new code
- [ ] File sizes: no file grew more than 100 lines without justification
- [ ] No schema field removals or renames without migration notes

## Phase 3 — Code patterns

### Framework/language conventions

- [ ] Matches existing project conventions (file layout, naming, imports)
- [ ] Uses idiomatic patterns for the tech stack
- [ ] Follows project-specific patterns (check neighboring files)

### Defensive code

- [ ] Every external call has error handling (API, DB, file I/O, network)
- [ ] Timeouts on all network calls
- [ ] Retry logic where appropriate (with backoff)
- [ ] Input validation at system boundaries
- [ ] Null/None/undefined guards where values come from external sources

### Resource management

- [ ] Resources closed/cleaned up (connections, file handles, subscriptions)
- [ ] No memory leaks (event listeners, timers, growing caches)
- [ ] Pagination or limits on unbounded queries

## Phase 4 — Behavioral gates

- [ ] **Simplicity**: could a junior dev understand this? no unnecessary abstractions
- [ ] **Surgical**: only code needed for the stated goal. no speculative features
- [ ] **Explicit**: error messages are actionable; types are explicit; control flow is obvious
- [ ] **Goal-driven**: every changed line traces back to the PR's stated objective

## Rejection triggers (auto-fail)

If any of these are true, reject the PR immediately — do not proceed to review:

- [ ] CI pipeline is red
- [ ] Secrets, tokens, or credentials in code
- [ ] Bare `catch`/`except` without re-raise or logging (unless justified)
- [ ] Raw env var reads outside config/bootstrap layer
- [ ] Debug prints (`console.log`, `print`, `dd`, `var_dump`, etc.)
- [ ] SQL injection vulnerability (unsanitized user input in queries)
- [ ] Unbounded loop/recursion without exit condition
- [ ] Coverage below project threshold on new code
- [ ] Config/credentials committed to repo
- [ ] Force push to protected branch
- [ ] Skipping CI hooks (`--no-verify`, `--no-gpg-sign`, etc.)

## Customization

Add project-specific rejection triggers below:

```yaml
# project-specific rejections
{project_rejections}

# project-specific lint/test commands
lint: "{lint_cmd}"
typecheck: "{typecheck_cmd}"
test: "{test_cmd}"
coverage_threshold: {threshold}
```
