# INSTALL.md — AI-Driven Workflow Setup

## How this works

1. User copies **only this file** (`INSTALL.md`) into their project repo.
2. An AI coding agent reads this file.
3. The AI clones the template source repo (see `TEMPLATE_REPO_URL` below) to a temp directory to get `docs_template/`.
4. The AI scans the target project, fills all placeholders, and generates `docs/`, root `CLAUDE.md`, and root `AGENTS.md`.
5. The AI cleans up the temp clone. **Nothing else needs to be copied or left behind.**

## Template source

```
TEMPLATE_REPO_URL = https://github.com/ethanhanguyen/repo_template
TEMPLATE_DIR       = docs_template/
```

The AI clones `TEMPLATE_REPO_URL` into a temp directory (e.g. `/tmp/repo_template`), reads all files in `TEMPLATE_DIR`, and uses them to generate output. After generation, the temp clone is deleted.

---

## Protocol overview

### Mode detection (run first)

Before any other work, the AI scans the target project directory:

1. **Does `docs/` already exist?**
   - **No** → **Fresh install mode** (interactive, Phases 1–4)
   - **Yes** → **Update/refresh mode** (zero questions, auto-detect). See [Update/refresh mode](#updaterefresh-mode) section below.

2. **Auto-detect from repo state** (both modes):
   - Language/framework: inspect `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, `build.gradle`, `mix.exs`, etc.
   - Package manager: read from config files
   - Tooling commands: detect existing lint/test/build scripts from config or Makefile
   - Env vars: parse `.env.example` if present
    - Harness directory: note presence/absence of `.claude/`, `.opencode/`, `.codex/` (actual question asked later in Phase 2a)

### Fresh install protocol

1. **Clone source**: `git clone {TEMPLATE_REPO_URL} /tmp/repo_template`
2. **Inventory**: Read all files in `docs_template/` to understand each template
3. **Discover**: Ask Phase 1–4 questions (including Phase 2a harness question), derive all defaults (Steps 0–1)
4. **Approval gate**: Present the full plan (files to create, placeholders to fill, tooling commands) and **wait for user approval** before writing any files
5. **Generate**: Create `docs/`, copy templates, substitute every placeholder (Step 3)
6. **Verify**: Run commands to confirm they work, report results (Step 4)
7. **Cleanup**: `rm -rf /tmp/repo_template` (Step 5)

### Update/refresh protocol

1. **Clone source**: same as fresh install
2. **Inventory**: Read current `docs/` + new `docs_template/` — diff to find what changed
3. **Auto-detect**: Re-derive all defaults from current repo state (no questions). Also check harness dirs (`.claude/`, `.opencode/`, `.codex/`).
4. **Approval gate**: Present the diff summary (what changed, what gets regenerated, what's preserved, harness status) and **wait for user approval** before writing any files. Continue only after explicit confirmation.
   - If no harness dirs exist, the summary must include: `No harness dirs detected. Creating docs/commands/ (canonical only). To add harness support, reply with the harness name (claude/opencode/codex).`
5. **Generate**: Apply only changed/new templates, preserve all runtime content
6. **Verify**: Run commands, report results
7. **Cleanup**: same as fresh install

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
| `{lint_cmd}` / `{lint_command}` | code-review, PR-template, PR-prompt, phase-plan, quickstart | Tooling |
| `{typecheck_cmd}` / `{typecheck_command}` | code-review, PR-template, PR-prompt, quickstart | Tooling |
| `{test_cmd}` / `{test_command}` | code-review, PR-template, PR-prompt, contributing, phase-plan | Tooling |
| `{build_cmd}` / `{build_command}` | code-review, PR-template, quickstart | Tooling |
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
| `{env_read_pattern}` | code-review, check.sh | Grep guard |
| `{debug_print_pattern}` | code-review, PR-template, check.sh | Grep guard |
| `{todo_pattern}` | code-review, PR-template, check.sh | Grep guard |
| `{source_include}` | check.sh | Grep guard |
| `{config_dir}` | check.sh | Grep guard |
| `{sleep_pattern}` | testing | Grep guard |
| `{mock_not_called}` / `{bare_assert_true}` | testing | Grep guard |
| `{missing_assert_in_test}` / `{test_specific_impl}` | testing | Grep guard |
| `{env_read_in_test}` | testing | Grep guard |
| `{threshold}` (coverage) | code-review, phase-plan | Quality |
| `{project_rejections}` (custom rejection triggers) | code-review | Quality |

### Runtime (filled by developers during daily use — NOT by this script)

Files that are entirely runtime: `decisions/*.md`, `specs/*.md`, `plans/phase-plan-template.md`, `plans/PR-prompt-template.md`, `plans/progress.md`, `archive/learnings.md`, `commands/pr.md`, `commands/plan.md`. These are copied as-is. The PR-template's implementation sections, architecture's design-decision tables, navigation's task map, always-verify list, scout corrections, and commands' workflow instructions are also runtime — left with placeholder hints intact.

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

| Language | debug_print_pattern | env_read_pattern | todo_pattern | sleep_pattern | bare_assert_true | source_include | config_dir |
|----------|---------------------|------------------|--------------|---------------|------------------|
| Python | `print(` | `os\.environ\[` | `TODO\|FIXME\|HACK` | `sleep\(` | `assert True` | `--include="*.py"` | `config` |
| TypeScript/JS | `console\.log` | `process\.env\.` | `TODO\|FIXME\|HACK` | `setTimeout` in test | `expect\(true\)` | `--include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx"` | `config` |
| Go | `fmt\.Println` | `os\.Getenv` | `TODO\|FIXME\|HACK` | `time\.Sleep` in test | — | `--include="*.go"` | `config` |
| Rust | `println!` | `std::env::var` | `TODO\|FIXME\|HACK` | `sleep` in test | `assert!\(true\)` | `--include="*.rs"` | `config` |
| Kotlin/Java | `println\|System\.out` | `System\.getenv` | `TODO\|FIXME\|HACK` | `Thread\.sleep` in test | `assertTrue\(true\)` | `--include="*.kt" --include="*.java"` | `config` |

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

Default: `{threshold}` = 85 (overall). New code = 90. Integration = 80. Can be overridden during setup.

### E2E / Benchmark commands

Default: `{e2e_cmd}` = (none), `{benchmark_cmd}` = (none) unless the project already has them.

---

## Setup protocol (fresh install)

### Step 0 — Read templates

Read every file in `docs_template/`. Understand the full placeholder surface.

### Step 1 — Ask & derive (Phases 1–4)

Ask these questions in order, then derive all other defaults from the lookup tables above. If the project already has code, auto-detect from config files first (`package.json`, `pyproject.toml`, `Cargo.toml`, etc.).

**IMPORTANT**: Phase 2a (harness) is NOT optional. You must ask it even if no harness directory is detected. Do not silently skip it.

**Phase 1 — Identity**: project name, repo URL, language/framework, package manager.

**Phase 2 — Tooling** (derived, confirm): `{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}`, `{test_cmd_single}`, `{build_cmd}`, `{format_cmd}`, `{e2e_cmd}`, `{benchmark_cmd}`, `{install_command}`, `{verify_command}`, `{start_command}`, `{deploy_command}`.

**Phase 2a — Harness** (REQUIRED question — never skip): Before continuing, scan for `.claude/`, `.opencode/`, `.codex/` directories. Then:

- **If a harness directory exists**: confirm with the user (e.g. "Detected .claude/ — use Claude Code?"). Update if they correct you.
- **If NO harness directory exists**: you MUST ask this question. Do not silently proceed.

```
No AI harness directory detected (.claude/, .opencode/, .codex/).
Which AI coding harness do you plan to use?
  1. Claude Code — I'll create .claude/commands/pr.md and .claude/commands/plan.md
  2. OpenCode   — I'll create .opencode/commands/pr.md and .opencode/commands/plan.md
  3. Codex      — I'll create .codex/commands/pr.md and .codex/commands/plan.md
  4. None       — only docs/commands/pr.md and docs/commands/plan.md (canonical copies)
```

If the user selects 1–3, create the directory (e.g. `mkdir -p .claude/commands`) and copy both `commands/pr.md` and `commands/plan.md` there during Step 3. `docs/commands/pr.md` and `docs/commands/plan.md` are always created as the canonical copies. If the user selects 4 (None), skip harness-specific install.

**Phase 3 — Structure** (derived, confirm): `{config_file}`, `{module_1}`/`{module_2}`, tech stack (`{backend_framework}`, `{frontend_framework}`, `{database}`, `{cache}`, `{storage}`, `{queue}`, `{monitoring}`, `{cicd}`, `{hosting}`), env vars (parse `.env.example` if present), `{additional_tools}`.

**Phase 4 — Quality** (derived, confirm): coverage thresholds (85/90/80), grep patterns (`{env_read_pattern}`, `{debug_print_pattern}`, `{todo_pattern}`, `{sleep_pattern}`, `{mock_not_called}`, `{bare_assert_true}`, `{missing_assert_in_test}`, `{test_specific_impl}`, `{env_read_in_test}`), custom `{project_rejections}`.

### Step 2 — Approval gate

Present the full plan before writing any files. Summarize:

```
Ready to generate:
  Mode: fresh install
  Files to create: 14
  Placeholders to fill: {N}
  Tooling: {lint_cmd}, {typecheck_cmd}, {test_cmd}, {build_cmd}
  Harness: {claude|opencode|codex|none}
  Files will be created in: docs/ (all), ./CLAUDE.md, ./AGENTS.md, {harness}/commands/pr.md, {harness}/commands/plan.md

Proceed? (yes/no)
```

**Do not proceed without explicit user confirmation.** If the user says no, ask what to change and re-present.

### Step 3 — Generate

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
PR-template.md
commands/pr.md
commands/plan.md
```

**Files needing partial substitution** (commands/patterns/thresholds substituted; content sections left as runtime placeholders):
```
plans/phase-plan-template.md   → substitute {test_cmd}, {lint_cmd}, {e2e_cmd}, {threshold}; leave goal, PRs, validation items as runtime
plans/PR-prompt-template.md    → substitute {lint_cmd}, {typecheck_cmd}, {test_cmd}; leave summary, implementation, test names as runtime
plans/progress.md              → substitute {PROJECT_NAME}; leave PR status, sessions, notes as runtime
architecture.md                → substitute {PROJECT_NAME} + tech stack table; leave system_overview, data_flow_diagram, module boundaries, design decisions as runtime
navigation.md                  → substitute initial Current focus to "docs setup"; always-verify, scout corrections, task map left as hints
```

**Files needing full substitution** (all placeholders are setup-time):
```
index.md           → substitute {PROJECT_NAME}
quickstart.md      → substitute all 20+ placeholders
contributing.md    → substitute all 15+ placeholders
code-review.md     → substitute all commands, grep patterns, {threshold}, {project_rejections}
testing.md         → substitute {PROJECT_NAME} + all grep patterns
```

**Special: check.sh** — copy `docs_template/scripts/check.sh` → `scripts/check.sh` (project root, not docs/). Substitute `{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}`, `{build_cmd}`, `{debug_print_pattern}`, `{todo_pattern}`, `{env_read_pattern}`, `{source_include}`, `{config_dir}`. If any command placeholder resolves to `(none)`, substitute it with `true` (no-op that always passes). Make executable with `chmod +x scripts/check.sh`. This is the single automated gate command.

**Special: Harness command installation** — After generating `docs/commands/pr.md` and `docs/commands/plan.md`, copy the command files to the harness's native commands directory. This makes `/pr` and `/plan` work as native slash commands:

| Harness | Command directory | Condition |
|---------|-------------------|-----------|
| Claude Code | `.claude/commands/pr.md`, `.claude/commands/plan.md` | `.claude/` exists or user selected it |
| OpenCode | `.opencode/commands/pr.md`, `.opencode/commands/plan.md` | `.opencode/` exists or user selected it |
| Codex | `.codex/commands/pr.md`, `.codex/commands/plan.md` | `.codex/` exists or user selected it |
| Generic | `docs/commands/pr.md`, `docs/commands/plan.md` | Always created (canonical copies) |

If no harness directory exists, **ask the user** during Phase 2a which harness they plan to use (see above). Create the harness directory (e.g. `mkdir -p .claude/commands`) and copy both `commands/pr.md` and `commands/plan.md` there. If the user selects "None", create only `docs/commands/`. The canonical copies in `docs/commands/` work as a reference all harnesses can read.

**Special: CLAUDE-template.md** — copy `docs_template/CLAUDE-template.md` → `./CLAUDE.md` (project root, not docs/). Substitute `{PROJECT_NAME}`, `{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}`. This file enforces the **plan-first rule**: before any code change, create a PR plan doc and update progress/architecture/README first.

**Special: AGENTS-template.md** — copy `docs_template/AGENTS-template.md` → `./AGENTS.md` (project root, not docs/). Substitute `{PROJECT_NAME}`, `{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}`. This file is the **harness-agnostic agent rules** for OpenCode, Cursor, Aider, Codex, and any AI coding agent that reads `AGENTS.md`. Same enforcement logic as `CLAUDE.md` but zero harness-specific assumptions.

For placeholders that the user didn't provide (e.g., deploy_command when no deploy exists), write `(none)` or `<!-- TODO -->`.

### Step 4 — Verify

After generation, run these checks and report results:

1. Run `{lint_cmd}` (if it exists) — confirm it runs without crashing
2. Run `{typecheck_cmd}` (if it exists) — confirm it runs
3. Run `{test_cmd}` (if it exists) — confirm it runs
4. Grep for remaining `{PLACEHOLDER}` tokens in `docs/` — should only find runtime placeholders (the ones intentionally left for developers)
5. Print a summary: files created, placeholders substituted, verification results.

### Step 5 — Cleanup

After generation and verification, remove the temp clone:

```bash
rm -rf /tmp/repo_template
```

---

## Update/refresh mode

When `docs/` already exists (e.g. the project was set up with an older version of the templates), the AI runs a **zero-questions auto-detect** protocol. No Phases 1–4 questions are asked.

### Detection (Step 0.5)

Before cloning the source, scan the existing `docs/` to understand the current state:

1. **Read existing docs**: which templates are already generated, which placeholders are filled
2. **Read project config files**: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`, `.env.example` — re-derive all defaults from current state
3. **Read existing root files**: `CLAUDE.md`, `AGENTS.md` — check if they exist and what tooling is configured
4. **Check for new/modified templates**: compare the template files in the clone (`/tmp/repo_template/docs_template/`) against the existing generated files in `docs/`

### What to regenerate

Only regenerate files that differ from the template source. Use a content-based comparison (not timestamp). For each file in `docs/`:

| File | Action |
|------|--------|
| `index.md`, `quickstart.md`, `contributing.md`, `code-review.md`, `testing.md` | **Re-substitute**: re-derive all setup-time placeholders from current repo state. Apply to a fresh copy from the template. Overwrite the generated file. |
| `architecture.md` | **Partial re-substitute**: update `{PROJECT_NAME}` + tech stack table. Preserve `{system_overview}`, `{data_flow_diagram}`, module boundaries, and design decisions — these are runtime content filled by developers. |
| `navigation.md` | **Update Current focus only**: set to "docs update — re-scanning". Preserve all scout corrections, task map, and always-verify list. |
| `PR-template.md`, `commands/pr.md`, `commands/plan.md` | **Runtime only** (copied as-is from template if missing). These files no longer contain setup-time placeholders. |
| `plans/phase-plan-template.md`, `plans/PR-prompt-template.md`, `plans/progress.md` | **Re-substitute tooling placeholders only**: update `{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}`, `{build_cmd}`, `{threshold}` from current detection. Preserve all runtime sections (PR descriptions, plan goals, progress entries). |
| `scripts/check.sh` | **Re-substitute**: regenerate from `docs_template/scripts/check.sh` with current tooling values (`{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}`, `{build_cmd}`, `{debug_print_pattern}`, `{todo_pattern}`, `{env_read_pattern}`, `{source_include}`, `{config_dir}`). |
| `decisions/*.md`, `specs/*.md`, `archive/learnings.md` | **Never touch**. These are entirely runtime content. |
| Root `CLAUDE.md`, `AGENTS.md` | **Re-substitute**: regenerate from `CLAUDE-template.md` / `AGENTS-template.md` with current tooling values. Preserve any custom task routing the user may have added — warn if template changed and list conflicts. |
| Harness command files (`.claude/commands/pr.md`, `.claude/commands/plan.md`, `.opencode/commands/pr.md`, `.opencode/commands/plan.md`, `.codex/commands/pr.md`, `.codex/commands/plan.md`) | **Copy/override unconditionally if harness dir exists**. Template source is always authoritative for commands — no diff needed. Overwrite existing harness copies directly from `/tmp/repo_template/docs_template/commands/pr.md` and `plan.md`. **If no harness dir exists**: no action (skip; canonical copies in `docs/commands/` are not created in update mode — they are fresh-install only). Include a harness note in the approval summary so the user can request a specific harness if desired. |

### Update protocol steps

1. **Clone source**: `git clone {TEMPLATE_REPO_URL} /tmp/repo_template`
2. **Detect**: scan existing `docs/` + project config files. Auto-derive all placeholders.
3. **Diff**: compare each template file against its generated counterpart to find what changed.
4. **Report & wait for approval**: print a summary before making changes:
   ```
   Update summary:
     Templates with changes: quickstart.md (new placeholder added), code-review.md (threshold changed)
     Runtime content preserved: 3 ADRs, 2 specs, 14 learnings, 2 phase plans
     Files being regenerated: 5
     Files untouched: 8
      Harness: none detected. Reply with "claude", "opencode", or "codex" to add harness support.
    
    Proceed? (yes/no)
    ```
    **Do not proceed without explicit user confirmation.**
 5. **Apply**: regenerate only changed files per the table above.
 6. **Verify**: run `{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}` (if they exist). Confirm no leftover `{PLACEHOLDER}` tokens.
 7. **Cleanup**: `rm -rf /tmp/repo_template`
 
 ### Update mode guardrails
 
 - **Never overwrite runtime content** (ADRs, specs, learnings, progress entries, architecture design decisions).
 - **Never ask standalone questions**. Everything is auto-detected. If detection fails on a required field, leave the placeholder with `<!-- TODO -->` and mention it in the summary.
 - **Harness exception**: harness preference cannot be auto-detected. Always include a harness line in the approval summary: if dirs exist, confirm harness; note that command files (`pr.md`, `plan.md`) will be overwritten from template. If no harness dirs exist, note that the user can reply with a harness name to add support. This is a summary note, not a separate question — the user sees it during the approval gate and can act on it.
 - **Never delete user-created files** in `docs/` that don't correspond to a template.
 - **Warn before overwriting** any file the user has modified from its template-original form (if the diff is non-trivial). Harness command files (`.claude/commands/pr.md`, etc.) are excluded — always overwrite from template.
 - **Preserve custom grep patterns** the user may have added to `code-review.md` or `scripts/check.sh`.
 
 ---
 
 ## Example: minimal interaction
 
 **User says**: "Set up docs for my Python FastAPI project"
 
 **AI clones source**: `git clone https://github.com/ethanhanguyen/repo_template /tmp/repo_template`
 
 **AI detects** (from `pyproject.toml`, `.env.example`, existing `src/`):
 - Language: Python, Framework: FastAPI
 - lint: `ruff check .`, test: `pytest --cov`, typecheck: `mypy src/`
 - DB: PostgreSQL, Cache: Redis
 - 3 env vars from `.env.example`
 - No existing `docs/` → fresh install mode
 
 **AI asks** (1 question block):
 ```
 Phase 1 — Project name? [my-fastapi-app] 
 Repo URL? [github.com/user/my-fastapi-app]
 Confirm Python/FastAPI? [Y]
 Database: PostgreSQL? [Y]
 
 No harness dir detected — which harness? [4 — None]
   (1. Claude Code  2. OpenCode  3. Codex  4. None)
 
 All defaults accepted. Generating docs/ ...
 ...
 ```
 
 ### Example: update mode (zero questions)
 
 **User says**: "Update my docs"
 
 **AI clones source**: `git clone https://github.com/ethanhanguyen/repo_template /tmp/repo_template`
 
 **AI detects** (from existing `docs/` + project config files):
 ```
 docs/ found → update mode. Scanning...
   Current setup: Python, FastAPI, ruff, pytest, PostgreSQL
   Runtime content: 3 ADRs, 1 spec, 8 learnings, 2 phase plans
   Templates changed: quickstart.md (new deploy_command placeholder)
   Root files: CLAUDE.md — tooling commands unchanged, AGENTS.md — unchanged
 
 Update summary:
   Regenerating: 1 file (quickstart.md)
   Preserving: 13 files (all runtime content + unchanged templates)
     Harness: .claude/ → pr.md and plan.md will be overwritten from template
 
 Applying changes...
   1 file updated. Verified: ruff clean, mypy clean, pytest 42 passed.
 Cleanup: removed /tmp/repo_template.
 ```
 
 When no harness dirs exist, the summary includes:
 ```
    Harness: none detected. Reply with "claude", "opencode", or "codex" to add harness support.
 ```

---

## Uninstall

To remove the generated workflow files while preserving runtime content:

```bash
# Remove generated root files
rm -f CLAUDE.md AGENTS.md scripts/check.sh

# Remove template files from docs/ (preserves decisions/, specs/, archive/, plans/)
rm -f docs/index.md docs/quickstart.md docs/contributing.md \
      docs/code-review.md docs/testing.md docs/architecture.md \
      docs/navigation.md docs/PR-template.md docs/commands/pr.md docs/commands/plan.md

# Remove harness command files (if any)
rm -f .claude/commands/pr.md .claude/commands/plan.md .opencode/commands/pr.md .opencode/commands/plan.md .codex/commands/pr.md .codex/commands/plan.md

# Clean up empty directories
rmdir docs/commands 2>/dev/null
rmdir docs/ 2>/dev/null
```

**Preserved**: `docs/decisions/`, `docs/specs/`, `docs/archive/`, `docs/plans/` — all runtime content.

**Removed**: root agent files (`CLAUDE.md`, `AGENTS.md`), `scripts/check.sh`, generated template files, harness command files.

---


## Guardrails for the AI

### Both modes

- **Clone source first**. Before generating anything, `git clone {TEMPLATE_REPO_URL} /tmp/repo_template` to get the latest `docs_template/`.
- **Never invent project details**. If detection fails, ask — don't guess (fresh mode) or leave `<!-- TODO -->` (update mode).
- **Generate root `CLAUDE.md`** from `CLAUDE-template.md` and root `AGENTS.md` from `AGENTS-template.md` — these are the agent instruction files that enforce the plan-first rule.
- **Install harness commands**: if a harness dir exists, confirm it. If none exists, ask the user which harness they plan to use (Phase 2a). Copy `commands/pr.md` and `commands/plan.md` to the matching directory. Always create `docs/commands/` as the canonical copy.
- **Verify after generation**. If a command fails, flag it but don't block — the project may not have code yet.
- **Leave runtime placeholders intact**. Only substitute the setup-time catalog listed above. Don't touch ADR fields, spec fields, PR implementation sections, navigation current-focus/scout corrections/task map, architecture design decisions, or phase plan goals.
- **Preserve exact formatting**. Only change placeholder tokens. Don't re-wrap paragraphs, don't adjust markdown syntax, don't "improve" the templates.
- **Clean up**: after generation and verification, `rm -rf /tmp/repo_template`.

### Fresh install mode

- **Never skip questions**. Even if defaults seem obvious, present them for confirmation.
- **Ask about harness**: if no `.claude/`, `.opencode/`, or `.codex/` directories are detected, ask the user which harness they plan to use. Do not assume "None" silently.
- **Never overwrite `docs/` if it already exists**. Warn and suggest switching to update mode.
- **Wait for approval**. After deriving all defaults, present the full plan and wait for explicit user confirmation before generating files.

### Update/refresh mode

- **Never ask questions**. Everything is auto-detected from existing repo state.
- **Never overwrite runtime content** (ADRs, specs, learnings, progress entries, architecture design decisions, navigation current-focus, scout corrections, task map, always-verify list).
- **Never delete user-created files** in `docs/` that don't correspond to a template.
- **Warn before overwriting** any file the user has modified from its template-original form.
- **Print a diff summary** before making changes so the user can review.
- **Preserve custom values**: grep patterns, coverage thresholds, project rejections the user already configured.
