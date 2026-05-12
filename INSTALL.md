# INSTALL.md — AI-Driven Workflow Setup

This document describes the protocol for an AI to instantiate `docs_template/` → `docs/` for any software project. The AI asks targeted questions, fills all placeholders, and verifies the result.

---

## Protocol overview

1. **Inventory**: Read all files in `docs_template/` to understand each template
2. **Discover**: Ask Phase 1 questions (language, framework, project identity)
3. **Derive**: Compute sensible defaults for all remaining placeholders
4. **Confirm**: Present Phase 2–4 questions — user accepts defaults or overrides
5. **Generate**: Create `docs/`, copy templates, substitute every placeholder
6. **Verify**: Run commands to confirm they work, report results

---

## Placeholder catalog

### Setup-time (these must be filled during initial instantiation)

| Placeholder | Appears in | Category |
|-------------|-----------|----------|
| `{PROJECT_NAME}` | index, quickstart, contributing, architecture, testing, progress | Identity |
| `{repo_url}` | quickstart, contributing | Identity |
| `{project_dir}` | quickstart, contributing | Identity |
| `{language}` / `{version}` | quickstart | Platform |
| `{package_manager}` / `{install_command}` | quickstart, contributing | Platform |
| `{verify_command}` | quickstart, contributing | Platform |
| `{start_command}` | quickstart | Platform |
| `{lint_cmd}` / `{lint_command}` | code-review, PR-template, PR-prompt, phase-plan, quickstart, commands/pr | Tooling |
| `{typecheck_cmd}` / `{typecheck_command}` | code-review, PR-template, PR-prompt, quickstart, commands/pr | Tooling |
| `{test_cmd}` / `{test_command}` | code-review, PR-template, PR-prompt, contributing, phase-plan, commands/pr | Tooling |
| `{test_cmd_single}` | contributing | Tooling |
| `{build_cmd}` / `{build_command}` | code-review, PR-template, quickstart, commands/pr | Tooling |
| `{e2e_cmd}` | code-review, phase-plan | Tooling |
| `{benchmark_cmd}` | code-review | Tooling |
| `{format_cmd}` | (not in templates but useful) | Tooling |
| `{deploy_command}` / `{cloud_deploy_command}` | quickstart | Tooling |
| `{config_file}` | contributing | Structure |
| `{module_1}` / `{module_2}` | contributing, architecture | Structure |
| `{ENV_VAR_1}` / `{ENV_VAR_2}` | quickstart | Config |
| `{ENV_1}` / `{ENV_2}` (with required/default/description) | contributing | Config |
| `{database}` (prereq + tech stack) | quickstart, architecture | Stack |
| `{additional_tools}` | quickstart | Stack |
| `{backend_framework}` / `{frontend_framework}` | architecture | Stack |
| `{cache}` / `{storage}` / `{queue}` | architecture | Stack |
| `{monitoring}` / `{cicd}` / `{hosting}` | architecture | Stack |
| `{env_read_pattern}` | code-review | Grep guard |
| `{debug_print_pattern}` | code-review, PR-template, commands/pr | Grep guard |
| `{todo_pattern}` | code-review, PR-template, commands/pr | Grep guard |
| `{sleep_pattern}` | testing | Grep guard |
| `{mock_not_called}` / `{bare_assert_true}` | testing | Grep guard |
| `{missing_assert_in_test}` / `{test_specific_impl}` | testing | Grep guard |
| `{env_read_in_test}` | testing | Grep guard |
| `{threshold}` (coverage) | code-review, phase-plan | Quality |
| `{project_rejections}` (custom rejection triggers) | code-review | Quality |

### Runtime (filled by developers during daily use — NOT by this script)

Files that are entirely runtime: `decisions/*.md`, `specs/*.md`, `plans/phase-plan-template.md`, `plans/PR-prompt-template.md`, `plans/progress.md`, `archive/learnings.md`. These are copied as-is. The PR-template's implementation sections, architecture's design-decision tables, navigation's current-focus section, and `commands/pr.md`'s workflow instructions are also runtime — left with placeholder hints intact.

---

## Default derivation rules

The AI must derive defaults from the Phase 1 answers using these lookup tables. If the project already has a codebase, inspect existing config files (`package.json`, `pyproject.toml`, `Cargo.toml`, `Makefile`, etc.) to refine defaults.

### Language → tooling commands

| Language | lint_cmd | typecheck_cmd | test_cmd | test_cmd_single | build_cmd | format_cmd |
|----------|----------|---------------|----------|-----------------|-----------|------------|
| Python | `ruff check .` | `mypy src/` | `pytest --cov` | `pytest` | (none) | `ruff format .` |
| TypeScript | `eslint .` | `tsc --noEmit` | `vitest run --coverage` | `vitest run` | `tsc` | `prettier --write .` |
| TypeScript/Next.js | `next lint` | `tsc --noEmit` | `vitest run --coverage` | `vitest run` | `next build` | `prettier --write .` |
| JavaScript | `eslint .` | (none) | `vitest run --coverage` | `vitest run` | (none) | `prettier --write .` |
| Go | `golangci-lint run` | `go vet ./...` | `go test -cover ./...` | `go test` | `go build ./...` | `gofmt -w .` |
| Rust | `cargo clippy -- -D warnings` | `cargo check` | `cargo test` | `cargo test` | `cargo build` | `cargo fmt` |
| Kotlin/JVM | `detekt` | `gradle compileKotlin` | `gradle test` | `gradle test --tests` | `gradle build` | `ktlint --format` |
| Java | `spotlessCheck` | `gradle compileJava` | `gradle test` | `gradle test --tests` | `gradle build` | `spotlessApply` |
| C++ | `clang-tidy src/**/*.cpp` | (none) | `ctest --output-on-failure` | `ctest -R` | `cmake --build build` | `clang-format -i` |
| Ruby | `rubocop` | `sorbet tc` | `rspec --format documentation` | `rspec` | (none) | `rubocop -A` |
| Swift | `swiftlint` | `swift build` | `swift test` | `swift test --filter` | `swift build` | `swiftformat .` |
| Elixir | `mix credo` | `mix dialyzer` | `mix test --cover` | `mix test` | `mix compile` | `mix format` |
| Zig | (none) | `zig build` | `zig build test` | `zig build test` | `zig build` | `zig fmt .` |

### Language → grep patterns

| Language | debug_print_pattern | env_read_pattern | todo_pattern | sleep_pattern | bare_assert_true |
|----------|---------------------|------------------|--------------|---------------|------------------|
| Python | `print(` | `os\.environ\[` | `TODO\|FIXME\|HACK` | `sleep\(` | `assert True` |
| TypeScript/JS | `console\.log` | `process\.env\.` | `TODO\|FIXME\|HACK` | `setTimeout` in test | `expect\(true\)` |
| Go | `fmt\.Println` | `os\.Getenv` | `TODO\|FIXME\|HACK` | `time\.Sleep` in test | — |
| Rust | `println!` | `std::env::var` | `TODO\|FIXME\|HACK` | `sleep` in test | `assert!\(true\)` |
| Kotlin/Java | `println\|System\.out` | `System\.getenv` | `TODO\|FIXME\|HACK` | `Thread\.sleep` in test | `assertTrue\(true\)` |

Additional grep patterns per language:
- `{mock_not_called}`: `verify.*never\|\.notCalled\|mock.*not.*called`
- `{missing_assert_in_test}`: language-specific (e.g. for pytest: function with `def test_` containing no `assert`)
- `{test_specific_impl}`: `\._\w+\(` (private method call in test)
- `{env_read_in_test}`: same as `env_read_pattern` but scoped to test files

### Language → install/verify/start commands

| Language | install_command | verify_command | start_command |
|----------|----------------|----------------|---------------|
| Python | `python -m venv venv && source venv/bin/activate && pip install -e ".[dev]"` | `python -c "import {project_dir}"` | `python -m {project_dir}` |
| TypeScript/Node | `npm install` | `npm run build 2>/dev/null || echo "ok"` | `npm run dev` |
| Go | `go mod download` | `go build ./...` | `go run ./cmd/server` |
| Rust | `cargo build` | `cargo check` | `cargo run` |

### Language → additional defaults

| Language | config_file | package_manager | typical_modules |
|----------|-------------|-----------------|-----------------|
| Python | `pyproject.toml` | pip/poetry/uv | `src/{name}/core`, `src/{name}/api`, `src/{name}/models` |
| TypeScript | `tsconfig.json` | npm/yarn/pnpm | `src/components`, `src/lib`, `src/hooks` |
| Go | `go.mod` | go modules | `cmd/`, `internal/`, `pkg/` |
| Rust | `Cargo.toml` | cargo | `src/bin`, `src/lib`, `src/core` |

### Coverage thresholds

Default: `{threshold}` = 85 (overall). New code = 90. Integration = 80. Can be overridden in Phase 4.

### E2E / Benchmark commands

Default: `{e2e_cmd}` = (none), `{benchmark_cmd}` = (none) unless the project already has them.

---

## Setup protocol

### Step 0 — Read the templates

Read every file in `docs_template/`. Understand the full placeholder surface.

### Step 1 — Ask Phase 1 (Project Identity)

Ask these 4 questions. From the answers, derive all Phase 2–4 defaults internally.

```
Phase 1 — Project identity
- Project name?
- Repo URL (or local path)?
- Primary language/framework? (e.g. Python/Django, TypeScript/Next.js, Go, Rust)
- Package manager? (auto-detect from project files if possible)
```

If the project directory already has code, inspect `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`, `.env.example` to auto-answer as much as possible.

### Step 2 — Derive & present Phase 2 (Tooling Confirmation)

Based on Phase 1 answers, derive all defaults using the lookup tables above. Present them as a single confirmation block:

```
Phase 2 — Tooling (press Enter to accept all defaults, or type overrides)

  lint:          {lint_cmd}
  typecheck:     {typecheck_cmd or "(none)"}
  test:          {test_cmd}
  test (single): {test_cmd_single}
  build:         {build_cmd or "(none)"}
  format:        {format_cmd or "(none)"}
  e2e:           {e2e_cmd or "(none)"}
  benchmark:     {benchmark_cmd or "(none)"}
  install:       {install_command}
  verify:        {verify_command}
  start:         {start_command}
  deploy:        {deploy_command or "(none)"}
```

### Step 3 — Present Phase 3 (Stack, Structure, Conventions)

Derive defaults and present:

```
Phase 3 — Structure & conventions (press Enter to accept each, or override)

  Config file:      {config_file}
  Branch prefix:    pr<N>-
  Commit convention: conventional commits (feat, fix, docs, test, refactor, ci, chore, perf)

  Directory structure:
    {derived from language}

  Tech stack:
    Backend:     {backend_framework or "(none)"}
    Frontend:    {frontend_framework or "(none)"}
    Database:    {database or "(none)"}
    Cache:       {cache or "(none)"}
    Storage:     {storage or "(none)"}
    Queue:       {queue or "(none)"}
    Monitoring:  {monitoring or "(none)"}
    CI/CD:       {cicd or "GitHub Actions"}
    Hosting:     {hosting or "(none)"}

  ENV variables (from .env.example or manual):
    VAR_NAME | Required | Default | Description

  Additional prerequisites (for quickstart): {additional_tools or "(none)"}
```

If `.env.example` exists, parse it to auto-fill the ENV table. Otherwise ask the user to list required env vars.

### Step 4 — Present Phase 4 (Quality Gates)

```
Phase 4 — Quality customization (press Enter to accept defaults)

  Coverage threshold (overall):  85%
  New code coverage target:       90%
  Integration coverage target:    80%

  Grep guards (derived, confirm):
    env_read_pattern:    {env_read_pattern}
    debug_print_pattern: {debug_print_pattern}
    todo_pattern:        {todo_pattern}
    sleep_pattern:       {sleep_pattern}
    mock_not_called:     {mock_not_called}
    bare_assert_true:    {bare_assert_true}
    missing_assert:      {missing_assert_in_test}
    test_specific_impl:  {test_specific_impl}
    env_read_in_test:    {env_read_in_test}

  Project-specific rejection triggers (add to code-review.md)?
    (none by default)
```

### Step 5 — Generate

Create `docs/` and populate it:

```
mkdir -p docs/decisions docs/plans docs/specs docs/archive docs/commands
```

For **setup-time templates** (those containing setup-time placeholders), copy the file and replace every placeholder with the collected values. Use exact string substitution.

For **runtime-only templates**, copy them as-is (their placeholders are filled by developers during daily use).

**Files copied as-is** (runtime only — no setup-time placeholders):
```
decisions/YYYY-MM-DD-decision-template.md
archive/learnings.md
specs/spec-template.md
```

**Files needing partial substitution** (commands/patterns/thresholds substituted; content sections left as runtime placeholders):
```
plans/phase-plan-template.md   → substitute {test_cmd}, {lint_cmd}, {e2e_cmd}, {threshold}; leave goal, PRs, validation items as runtime
plans/PR-prompt-template.md    → substitute {lint_cmd}, {typecheck_cmd}, {test_cmd}; leave summary, implementation, test names as runtime
plans/progress.md              → substitute {PROJECT_NAME}; leave PR status, sessions, notes as runtime
PR-template.md                 → substitute {lint_cmd}, {typecheck_cmd}, {test_cmd}, {build_cmd}, {debug_print_pattern}, {todo_pattern}; leave phase_plan_link, adr_links, implementation checkboxes as runtime
commands/pr.md                 → substitute {lint_cmd}, {typecheck_cmd}, {test_cmd}, {build_cmd}, {debug_print_pattern}, {todo_pattern}; leave workflow instructions as runtime
architecture.md                → substitute {PROJECT_NAME} + tech stack table; leave system_overview, data_flow_diagram, module boundaries, design decisions as runtime
navigation.md                  → substitute initial Current focus to "docs setup"; scout corrections, task map left as hints
```

**Files needing full substitution** (all placeholders are setup-time):
```
index.md           → substitute {PROJECT_NAME}
quickstart.md      → substitute all 20+ placeholders
contributing.md    → substitute all 15+ placeholders
code-review.md     → substitute all commands, grep patterns, {threshold}, {project_rejections}
testing.md         → substitute {PROJECT_NAME} + all grep patterns
```

**Special: Harness command installation** — After generating `docs/commands/pr.md`, detect which AI coding harness the project uses and copy the command file to the harness's native commands directory. This makes `/pr` work as a native slash command:

| Harness | Command directory | Condition |
|---------|-------------------|-----------|
| Claude Code | `.claude/commands/pr.md` | `.claude/` directory exists |
| OpenCode | `.opencode/commands/pr.md` | `.opencode/` directory exists |
| Codex | `.codex/commands/pr.md` | `.codex/` directory exists |
| Generic | `docs/commands/pr.md` | Always created (canonical copy) |

If no harness directory exists and the project is new, create `docs/commands/pr.md` only. The canonical copy in `docs/commands/` works as a reference all harnesses can read.

**Special: CLAUDE-template.md** — copy `docs_template/CLAUDE-template.md` → `./CLAUDE.md` (project root, not docs/). Substitute `{PROJECT_NAME}`, `{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}`. This file enforces the **plan-first rule**: before any code change, create a PR plan doc and update progress/architecture/README first.

**Special: AGENTS-template.md** — copy `docs_template/AGENTS-template.md` → `./AGENTS.md` (project root, not docs/). Substitute `{PROJECT_NAME}`, `{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}`. This file is the **harness-agnostic agent rules** for OpenCode, Cursor, Aider, Codex, and any AI coding agent that reads `AGENTS.md`. Same enforcement logic as `CLAUDE.md` but zero harness-specific assumptions.

For placeholders that the user didn't provide (e.g., deploy_command when no deploy exists), write `(none)` or `<!-- TODO -->`.

### Step 6 — Verify

After generation, run these checks and report results:

1. Run `{lint_cmd}` (if it exists) — confirm it runs without crashing
2. Run `{typecheck_cmd}` (if it exists) — confirm it runs
3. Run `{test_cmd}` (if it exists) — confirm it runs
4. Grep for remaining `{PLACEHOLDER}` tokens in `docs/` — should only find runtime placeholders (the ones intentionally left for developers)
5. Print a summary: files created, placeholders substituted, verification results.

---

## Example: minimal interaction

**User says**: "Set up docs for my Python FastAPI project"

**AI detects** (from `pyproject.toml`, `.env.example`, existing `src/`):
- Language: Python, Framework: FastAPI
- lint: `ruff check .`, test: `pytest --cov`, typecheck: `mypy src/`
- DB: PostgreSQL, Cache: Redis
- 3 env vars from `.env.example`

**AI asks** (1 question block):
```
Phase 1 — Project name? [my-fastapi-app] 
Repo URL? [github.com/user/my-fastapi-app]
Confirm Python/FastAPI? [Y]
Database: PostgreSQL? [Y]

All defaults accepted. Generating docs/ ...

Created 14 files in docs/. Verified: ruff clean, mypy clean, pytest 42 passed.
```

---

## Guardrails for the AI

- **Never skip a phase**. Even if defaults are accepted, present them explicitly.
- **Never invent project details**. If detection fails, ask — don't guess.
- **Never overwrite `docs/` if it already exists**. Warn and ask.
- **Generate root `CLAUDE.md`** from `CLAUDE-template.md` and root `AGENTS.md` from `AGENTS-template.md` — these are the agent instruction files that enforce the plan-first rule.
- **Verify after generation**. If a command fails, flag it but don't block — the project may not have code yet.
- **Leave runtime placeholders intact**. Only substitute the setup-time catalog listed above. Don't touch ADR fields, spec fields, PR implementation sections, navigation current-focus, architecture design decisions, or phase plan goals.
- **Preserve exact formatting**. Only change placeholder tokens. Don't re-wrap paragraphs, don't adjust markdown syntax, don't "improve" the templates.
