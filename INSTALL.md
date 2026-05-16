# INSTALL.md

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

## Decision flow (read this first)

```
Repo scan
  ├─ No config AND no src/ AND no docs/ → Empty repo protocol (§3)
  ├─ Config or src/ exists, no docs/    → Fresh install protocol (§4)
  └─ docs/ already exists               → Update/refresh protocol (§5)
```

---

# EXECUTION PROTOCOL

## §1 — Mode detection (run first)

Before any other work, scan the target project directory:

### 1a. Does `docs/` exist?

- **No** → fresh install or empty repo (check §1c below first)
- **Yes** → update/refresh mode. Jump to [§5 — Update/refresh protocol](#5--updaterefresh-protocol).

### 1b. Auto-detect from repo state

Inspect the project directory for:
- **Language/framework**: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, `build.gradle`, `mix.exs`, etc.
- **Package manager**: read from config files
- **Tooling commands**: detect existing lint/test/build scripts from config or `Makefile`
- **Env vars**: parse `.env.example` if present
- **Harness dirs**: scan for all directories listed in the [Harness Catalog (§G)](#g-harness-catalog)

### 1c. Empty repo check

If ALL these are true, the repo is **empty**:
- No `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, `build.gradle`, `mix.exs`, or similar project config
- No `src/`, `lib/`, `cmd/`, `app/`, or equivalent source directory
- No `.env.example`
- No existing `docs/`

→ **Empty repo protocol** ([§3](#3--empty-repo-protocol)).

If at least a config file OR source directory exists → **Fresh install protocol** ([§4](#4--fresh-install-protocol)).

---

## §2 — Clone source & inventory

Run this regardless of mode:

```bash
git clone {TEMPLATE_REPO_URL} /tmp/repo_template
```

Read every file in `docs_template/`. Build a map: file → each `{PLACEHOLDER}` found. Cross-reference against the Placeholder Catalog ([Reference §A](#a-placeholder-catalog)) to identify setup-time vs runtime placeholders.

---

## §3 — Empty repo protocol

Only 3 questions. Refuse to proceed without answers to Q1 and Q2.

### Q1 — Project name (required, no default)

```
What is the project name?
```

### Q2 — Language and framework (required, no default)

```
What language and framework will you use?
(e.g., "Go with Chi router", "Python with FastAPI", "TypeScript/Next.js")
```
All tooling commands, grep patterns, and module structure derive from this answer (see [Reference §B](#b-language-derivation-tables)).

### Q3 — Harness (required)

Present the harness options from the [Harness Catalog (§G)](#g-harness-catalog) as a numbered list (Type A first, then Type B):

```
Which AI coding harness do you plan to use?
  [Type A — slash commands native]
  1. Claude Code — .claude/commands/
  2. OpenCode   — .opencode/commands/
  3. Codex      — .codex/commands/

  [Type B — agent files only (CLAUDE.md/AGENTS.md)]
  4. GitHub Copilot
  5. Cursor
  6. Windsurf
```

No "None" option. Without a harness, `/plan`, `/pr`, and `/audit_pr` have no execution surface. Type B harnesses don't support native slash commands, but `docs/commands/` canonical copies still provide the workflow protocols, and the root agent files are read natively by the harness.

### Derive defaults

From Q2, look up the language in [Reference §B](#b-language-derivation-tables) to derive:

- **Tooling**: `{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}`, `{test_cmd_single}`, `{build_cmd}`, `{install_command}`
- **Grep patterns**: `{debug_print_pattern}`, `{env_read_pattern}`, `{todo_pattern}`, `{sleep_pattern}`, `{bare_assert_true}`, `{mock_not_called}`, `{test_specific_impl}`, `{env_read_in_test}`, `{source_include}`, `{config_dir}`
- **Structure**: `{config_file}`, `{package_manager}`, module names
- **Custom grep**: `{missing_assert_in_test}` — requires structural analysis (code reading), not grep

Unavailable until project exists: `{verify_command}`, `{start_command}`, `{expected_output}`, `{deploy_command}`, `{ENV_VAR_1}`, `{ENV_VAR_2}`, `{database}`, `{additional_tools}`, `{backend_framework}`, `{frontend_framework}`, `{cache}`, `{storage}`, `{queue}`, `{monitoring}`, `{cicd}`, `{hosting}`, `{repo_url}`, `{project_dir}`.

See [Reference §C](#c-empty-repo-defaults) for their default values.

### Approval gate

Present the plan:

```
Empty repo detected. Filling from 3 answers:
  Project: {name}
  Language: {lang}/{framework}
  Harness: {name from catalog §G} (Type {A|B})

Derived:
  Tooling: {lint_cmd}, {typecheck_cmd}, {test_cmd}, {build_cmd}
  Package manager: {pkg}

Unavailable (stubbed with <!-- TODO -->):
  {list of unavailable placeholders}

Proceed? (yes/no)
```

If user says no or hasn't answered Q1/Q2, stop. Do not generate.

If yes → proceed to [§6 — Generate files](#6--generate-files). Skip the Q&A rounds (empty repos have no codebase to confirm against).

---

## §4 — Fresh install protocol (normal repos)

Clone source and inventory per [§2](#2--clone-source--inventory) first, then ask these questions. If the project already has code, auto-detect from config files to pre-fill defaults.

### Round 1 — Identity

- **Project name**, **repo URL**, **language/framework**, **package manager**.
- Derive `{project_dir}` from the last segment of `{repo_url}` (without `.git`).

### Round 2 — Tooling (derive from [Reference §B](#b-language-derivation-tables), confirm)

Present derived values for: `{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}`, `{test_cmd_single}`, `{build_cmd}`, `{install_command}`, `{verify_command}`, `{start_command}`, `{deploy_command}`, `{e2e_cmd}`, `{benchmark_cmd}`.

Note: `{format_cmd}` is derived but not used in any generated template — informational only.

### Round 2a — Harness (REQUIRED — never skip)

Scan for all directories listed in the [Harness Catalog (§G)](#g-harness-catalog). Then:

- **If a harness dir exists**: look up the dir in the catalog, confirm with the user (e.g., "Detected `.claude/` — use Claude Code (Type A)?"). Update if they correct you.
- **If NO harness dir exists**: you MUST ask, presenting the catalog as a numbered list (Type A first, then Type B):

```
No AI harness directory detected.
Which AI coding harness do you plan to use?
  [Type A — slash commands: pr.md, plan.md, audit_pr.md]
  1. Claude Code — creates .claude/commands/
  2. OpenCode   — creates .opencode/commands/
  3. Codex      — creates .codex/commands/

  [Type B — agent files only (CLAUDE.md/AGENTS.md)]
  4. GitHub Copilot
  5. Cursor
  6. Windsurf
  7. None — only docs/commands/ (canonical copies)
```

If user selects 1–3 (Type A), create the commands directory during generation ([§6](#6--generate-files)). If 4–6 (Type B), generate only the root agent file(s) listed in the catalog — no commands directory. If 7, skip harness install entirely.

### Round 3 — Structure (derive, confirm)

- `{config_file}`, `{module_1}`/`{module_2}` from language table
- Tech stack: `{backend_framework}`, `{frontend_framework}`, `{database}`, `{cache}`, `{storage}`, `{queue}`, `{monitoring}`, `{cicd}`, `{hosting}`
- Env vars: parse `.env.example` if present for `{ENV_VAR_1}`, `{ENV_VAR_2}`, `{ENV_1}`, `{ENV_2}`
- `{additional_tools}`

### Round 4 — Quality (derive, confirm)

- Coverage: `{threshold}` (default 85). New code ≥90%, integration ≥80%.
- Grep patterns from language table (see [Reference §B](#b-language-derivation-tables))
- `{mock_not_called}`: `verify.*never|\.notCalled|mock.*not.*called` (scope to test files: use `--include` for test patterns)
- `{missing_assert_in_test}`: requires structural analysis (read test bodies), not grep
- `{project_rejections}`: any custom rejection triggers

### Approval gate

Present the full plan before writing any files:

```
Ready to generate:
  Mode: fresh install
  All template files from docs_template/ will be generated
  Placeholders to fill: {N}
  Tooling: {lint_cmd}, {typecheck_cmd}, {test_cmd}, {build_cmd}
  Harness: {name from catalog §G} (Type {A|B}){ if none: "None"}
  Output: docs/ (all), ./CLAUDE.md{ or ./AGENTS.md, or both — per catalog §G}, scripts/check.sh{ + {Dir}/commands/ if Type A}

Proceed? (yes/no)
```

**Do not proceed without explicit user confirmation.** If user says no, ask what to change and re-present.

If yes → proceed to [§6 — Generate files](#6--generate-files).

---

## §5 — Update/refresh protocol

When `docs/` already exists. **Zero questions.** Everything is auto-detected.

### 5a. Clone & scan

1. Clone source per [§2](#2--clone-source--inventory)
2. Read current `docs/` + new `docs_template/` — diff to find what changed
3. Read project config files to re-derive all defaults from current state
4. Read root `CLAUDE.md`, `AGENTS.md` — check if they exist and what tooling is configured
5. Check for new/modified templates: compare template files in `/tmp/repo_template/docs_template/` against existing generated files in `docs/`

### 5b. What to regenerate

Use content-based comparison (not timestamps). For each file:

| File | Action |
|------|--------|
| `index.md`, `quickstart.md`, `contributing.md`, `code-review.md`, `testing.md` | **Re-substitute** all setup-time placeholders from current repo state. Overwrite with fresh copy from template. |
| `architecture.md` | **Partial re-substitute**: update `{PROJECT_NAME}` + tech stack table. Preserve runtime content (system overview, data flow, module boundaries, design decisions). |
| `navigation.md` | **Update Current focus only**: set to "docs update — re-scanning". Preserve scout corrections, task map, always-verify list. |
| `PR-template.md`, `commands/pr.md`, `commands/plan.md`, `commands/audit_pr.md`, `plans/plan-state-template.md` | **Runtime only**. Copy from template if missing. Setup-time placeholders already removed from these files. |
| `plans/phase-plan-template.md`, `plans/PR-prompt-template.md`, `plans/progress.md` | **Re-substitute tooling placeholders only**: update `{lint_cmd}`, `{typecheck_cmd}`, `{test_cmd}`, `{build_cmd}`, `{threshold}`. Preserve all runtime sections. |
| `scripts/check.sh` | **Re-substitute**: regenerate with current tooling/grep values. |
| `decisions/*.md`, `specs/*.md`, `archive/learnings.md` | **Never touch**. Entirely runtime content. |
| Root `CLAUDE.md`, `AGENTS.md` | **Re-substitute**: regenerate with current `{PROJECT_NAME}`, `{threshold}`. Warn if custom task routing may conflict. |
| Harness command files (`{Dir}/commands/` for Type A harnesses — see catalog §G) | **Overwrite unconditionally** from template if the harness dir exists and is Type A. Template is always authoritative for commands. |
| `docs/commands/` (canonical copies) | **Create if missing**, regenerate if outdated. Not just fresh-install — update mode backfills these too. |

### 5c. Approval gate (with explicit harness prompt)

Present the diff summary before making changes:

```
Update summary:
  Templates with changes: {list}
  Runtime content preserved: {N} ADRs, {N} specs, {N} learnings, {N} phase plans
  Files being regenerated: {N}
  Files untouched: {N}

Harness: {.claude/ detected → Type A, command files will be overwritten | .cursor/ detected → Type B, agent files only | none detected}

Proceed? (yes/no)
```

**If no harness dirs exist**, add this explicit line at the end of the summary:

```
**No harness dirs detected.** Reply with a harness ID from the catalog (§G) — e.g. "claude", "opencode", "codex", "copilot", "cursor", "windsurf" — to add harness infrastructure.
```

**Do not proceed without explicit user confirmation.** If the user replies with a harness ID from the catalog, create the directory (Type A) or note it as supported (Type B), then proceed. If they say no, ask what to change.

### 5d. Apply → Verify → Cleanup

Apply changes per the table above, then verify per [§7](#7--verify), then cleanup per [§8](#8--cleanup).

### Update mode guardrails

- **Never overwrite runtime content** (ADRs, specs, learnings, progress entries, architecture design decisions, navigation current-focus/scout corrections/task map).
- **Never ask standalone questions**. Everything is auto-detected. The harness line in the approval summary is the only prompt.
- **Never delete user-created files** in `docs/` that don't correspond to a template.
- **Warn before overwriting** any file the user has modified from its template-original form. Harness command files are excluded — always overwrite from template.
- **Preserve custom grep patterns** the user may have added to `code-review.md` or `scripts/check.sh`.
- If detection fails on a required field, leave the placeholder with `<!-- TODO -->` and mention it in the summary.

---

## §6 — Generate files

### 6a. Create directory structure

```bash
mkdir -p docs/decisions docs/plans docs/specs docs/archive docs/commands
```

### 6b. Runtime-only files (copy as-is, no substitution)

```
decisions/YYYY-MM-DD-decision-template.md
archive/learnings.md
specs/spec-template.md
plans/plan-state-template.md
PR-template.md
commands/pr.md
commands/plan.md
commands/audit_pr.md
```

### 6c. Partial substitution files

Substitute only the listed placeholders. Leave all other `{...}` tokens as runtime (developers fill them later).

```
plans/phase-plan-template.md   → {test_cmd}, {lint_cmd}, {e2e_cmd}, {threshold}
plans/PR-prompt-template.md    → {lint_cmd}, {typecheck_cmd}, {test_cmd}
plans/progress.md              → {PROJECT_NAME}
architecture.md                → {PROJECT_NAME}, {module_1}, {module_2},
                                 {backend_framework}, {frontend_framework}, {database},
                                 {cache}, {storage}, {queue}, {monitoring}, {cicd}, {hosting}
navigation.md                  → {what are you working on?} → "docs setup"
                                 {files most relevant to current task} → "docs/, scripts/, ./"
                                 NOTE: literal `{PLACEHOLDER}` text in always-verify is a grep target — do NOT substitute
```

### 6d. Full substitution files

Substitute every setup-time placeholder. Runtime `{description}` and `{default}` tokens are left intact.

```
index.md           → {PROJECT_NAME}
quickstart.md      → all 20+ setup-time placeholders
contributing.md    → all 12+ setup-time placeholders
code-review.md     → {lint_cmd}, {typecheck_cmd}, {test_cmd}, {threshold}, {project_rejections}
testing.md         → {PROJECT_NAME} + all grep patterns
```

### 6e. Special: check.sh

Copy `docs_template/scripts/check.sh` → `scripts/check.sh` (project root). Substitute:

```
{lint_cmd}, {typecheck_cmd}, {test_cmd}, {build_cmd},
{debug_print_pattern}, {todo_pattern}, {env_read_pattern},
{source_include}, {config_dir}
```

If any command placeholder resolves to `(none)`, substitute with `true` (no-op that always passes). Make executable: `chmod +x scripts/check.sh`.

### 6f. Special: root agent files

Generate only the file(s) that the selected harness natively reads, per the [Harness Catalog (§G)](#g-harness-catalog):

- If the harness reads `CLAUDE.md`: copy `docs_template/CLAUDE-template.md` → `./CLAUDE.md`. Substitute `{PROJECT_NAME}`, `{threshold}`.
- If the harness reads `AGENTS.md`: copy `docs_template/AGENTS-template.md` → `./AGENTS.md`. Substitute `{PROJECT_NAME}`, `{threshold}`.
- If the harness reads both, generate both.
- If the user selects "None", generate both as reference.

### 6g. Special: harness command files

After generating `docs/commands/pr.md`, `docs/commands/plan.md`, `docs/commands/audit_pr.md` (canonical copies), copy them to the harness's native commands directory for Type A harnesses only:

| Harness | Dir | Condition |
|---------|-----|-----------|
| Claude Code | `.claude/commands/` | Type A, dir exists or user selected it |
| OpenCode | `.opencode/commands/` | Type A, dir exists or user selected it |
| Codex | `.codex/commands/` | Type A, dir exists or user selected it |

**Type B harnesses** (Copilot, Cursor, Windsurf): skip this step — no commands directory is created. These harnesses read `CLAUDE.md`/`AGENTS.md` directly and don't support custom slash commands.

Create the harness directory if needed (`mkdir -p {Dir}/commands`). If user selected "None" in Round 2a, skip harness install.

### 6h. For placeholders with no available value

Write `(none)` for tooling commands, `<!-- TODO -->` for identity/stack/start/verify/expected_output values.

---

## §7 — Verify

### For repos with code

1. Run `{lint_cmd}` — confirm it runs without crashing
2. Run `{typecheck_cmd}` — confirm it runs
3. Run `{test_cmd}` — confirm it runs
4. If any command fails and no source code exists, flag "no code yet — skip" (non-blocking)

### For empty repos

1. Confirm `scripts/check.sh` is executable
2. Confirm all files created at expected paths
3. **Note**: `scripts/check.sh` will fail lint/build/test gates because no code exists — expected and non-blocking

### Both modes — artifact scan (required)

Greps all generated files for leftover setup-time placeholders. **Must find zero hits.**

```bash
# Generated from Placeholder Catalog (Reference §A). Keep both in sync.
grep -rn '\{PROJECT_NAME\}\|\{what are you working on?\}\|\{files most relevant to current task\}\|\{language\}\|\{version\}\|\{package_manager\}\|\{repo_url\}\|\{project_dir\}\|\{install_command\}\|\{verify_command\}\|\{start_command\}\|\{expected_output\}\|\{lint_cmd\}\|\{lint_command\}\|\{typecheck_cmd\}\|\{typecheck_command\}\|\{test_cmd\}\|\{test_command\}\|\{test_cmd_single\}\|\{build_cmd\}\|\{build_command\}\|\{e2e_cmd\}\|\{deploy_command\}\|\{config_file\}\|\{module_1\}\|\{module_2\}\|\{ENV_VAR_1\}\|\{ENV_VAR_2\}\|\{ENV_1\}\|\{ENV_2\}\|\{database\}\|\{additional_tools\}\|\{backend_framework\}\|\{frontend_framework\}\|\{cache\}\|\{storage\}\|\{queue\}\|\{monitoring\}\|\{cicd\}\|\{hosting\}\|\{env_read_pattern\}\|\{debug_print_pattern\}\|\{todo_pattern\}\|\{source_include\}\|\{config_dir\}\|\{sleep_pattern\}\|\{mock_not_called\}\|\{bare_assert_true\}\|\{missing_assert_in_test\}\|\{test_specific_impl\}\|\{env_read_in_test\}\|\{threshold\}\|\{project_rejections\}' docs/ ./CLAUDE.md ./AGENTS.md scripts/check.sh 2>/dev/null
```

Report any hits as errors.

### Both modes — print summary

Files created, placeholders substituted, verification results.

---

## §8 — Cleanup

```bash
rm -rf /tmp/repo_template
```

---

# REFERENCE

## A. Placeholder catalog

### Setup-time (must be filled during initial instantiation)

| Placeholder | Appears in | Category |
|-------------|-----------|----------|
| `{PROJECT_NAME}` | index, quickstart, contributing, architecture, testing, progress, CLAUDE-template, AGENTS-template | Identity |
| `{what are you working on?}` / `{files most relevant to current task}` | navigation | Identity |
| `{repo_url}` | quickstart, contributing | Identity |
| `{project_dir}` | quickstart, contributing | Identity |
| `{language}` / `{version}` | quickstart | Platform |
| `{package_manager}` | quickstart | Platform |
| `{install_command}` | quickstart, contributing | Platform |
| `{verify_command}` | quickstart, contributing | Platform |
| `{start_command}` | quickstart | Platform |
| `{expected_output}` | quickstart | Identity |
| `{lint_cmd}` / `{lint_command}` | code-review, PR-prompt, phase-plan, quickstart | Tooling |
| `{typecheck_cmd}` / `{typecheck_command}` | code-review, PR-prompt, quickstart | Tooling |
| `{test_cmd}` / `{test_command}` | code-review, PR-prompt, contributing, phase-plan, quickstart | Tooling |
| `{test_cmd_single}` | contributing | Tooling |
| `{build_cmd}` / `{build_command}` | quickstart, check.sh | Tooling |
| `{e2e_cmd}` | phase-plan | Tooling |
| `{deploy_command}` | quickstart | Tooling |
| `{config_file}` | contributing | Structure |
| `{module_1}` / `{module_2}` | contributing, architecture | Structure |
| `{ENV_VAR_1}` / `{ENV_VAR_2}` | quickstart | Config |
| `{ENV_1}` / `{ENV_2}` (with required/default/description) | contributing | Config |
| `{database}` (prereq + tech stack) | quickstart, architecture | Stack |
| `{additional_tools}` | quickstart | Stack |
| `{backend_framework}` / `{frontend_framework}` | architecture | Stack |
| `{cache}` / `{storage}` / `{queue}` | architecture | Stack |
| `{monitoring}` / `{cicd}` / `{hosting}` | architecture | Stack |
| `{env_read_pattern}` | check.sh | Grep guard |
| `{debug_print_pattern}` | check.sh | Grep guard |
| `{todo_pattern}` | check.sh | Grep guard |
| `{source_include}` | check.sh | Grep guard |
| `{config_dir}` | check.sh | Grep guard |
| `{sleep_pattern}` | testing | Grep guard |
| `{mock_not_called}` (scope to test files) | testing | Grep guard |
| `{bare_assert_true}` | testing | Grep guard |
| `{missing_assert_in_test}` (requires code reading, not grep) | testing | Grep guard |
| `{test_specific_impl}` | testing | Grep guard |
| `{env_read_in_test}` | testing | Grep guard |
| `{threshold}` (coverage) | code-review, phase-plan, CLAUDE-template, AGENTS-template | Quality |
| `{project_rejections}` (custom rejection triggers) | code-review | Quality |

### Runtime (filled by developers during daily use — NEVER substituted at setup)

| Placeholder(s) | Where | Note |
|---------------|-------|------|
| `{description}` | quickstart, contributing, architecture | Pervasive — never substitute |
| `{default}` | contributing (env var table) | Never substitute |
| `{Step 1/2/3}`, `{description and command}` | quickstart walkthrough | Never substitute |
| `{system_overview}`, `{data_flow_diagram}`, `{scaling_description}` | architecture | Never substitute |
| `{inputs}`, `{outputs}`, `{deps}`, `{purpose}`, `{decision_*}`, `{why}`, `{alternatives}` | architecture | Never substitute |
| `{phase_goal}`, `{N}`, `{validation_item_*}`, `{criterion_*}` | phase-plan-template | Never substitute |
| `{summary}`, `{component name}`, `{file_path}`, `{code_block}`, `{constraint_*}`, `{error_case}`, `{test_name_*}` | PR-prompt-template | Never substitute |
| `{phase_diagram}` | progress.md | Never substitute |
| `{slug}`, `{date}`, `{status}`, `{context}`, `{decision}`, `{pros}`, `{cons}`, `{consequence}`, `{trade-off}`, `{mitigation}` | decisions template, specs template, plan-state-template | Never substitute |
| `{phase_plan_link}`, `{adr_links}`, `{Component A/B}` | PR-template | Never substitute |
| `{symptom-you-hit}`, `{grep-command-that-would-have-solved-it}`, `{est%}` | navigation | Never substitute |
| `{PLACEHOLDER}` (literal text) | navigation (always-verify section) | Grep target — never substitute |
| `{format_cmd}` | (none) | Derived from language table but not used in any template |

---

## B. Language derivation tables

### Language → tooling commands

| Language | lint_cmd | typecheck_cmd | test_cmd | test_cmd_single | build_cmd | format_cmd |
|----------|----------|---------------|----------|-----------------|-----------|------------|
| Python | `ruff check .` | `mypy src/` | `pytest --cov` | `pytest` | (none) | `ruff format .` |
| TypeScript | `eslint .` | `tsc --noEmit` | `vitest run --coverage` | `vitest run` | `tsc` | `prettier --write .` |
| TypeScript/Next.js | `next lint` | `tsc --noEmit` | `vitest run --coverage` | `vitest run` | `next build` | `prettier --write .` |
| JavaScript | `eslint .` | (none) | `vitest run --coverage` | `vitest run` | (none) | `prettier --write .` |
| Go | `golangci-lint run` | `go vet ./...` | `go test -cover ./...` | `go test` | `go build ./...` | `gofmt -w .` |
| Rust | `cargo clippy -- -D warnings` | `cargo check` | `cargo test` | `cargo test` | `cargo build` | `cargo fmt` |
| Kotlin/JVM | `detekt` | `gradle compileKotlin` | `gradle test` | `gradle test --tests "TestClass.testMethod"` | `gradle build` | `ktlint --format` |
| Java | `spotlessCheck` | `gradle compileJava` | `gradle test` | `gradle test --tests "TestClass.testMethod"` | `gradle build` | `spotlessApply` |
| C++ | `clang-tidy src/**/*.cpp` | (none) | `ctest --output-on-failure` | `ctest -R` | `cmake --build build` | `clang-format -i` |
| Ruby | `rubocop` | `sorbet tc` | `rspec --format documentation` | `rspec` | (none) | `rubocop -A` |
| Swift | `swiftlint` | `swift build` | `swift test` | `swift test --filter` | `swift build` | `swiftformat .` |
| Elixir | `mix credo` | `mix dialyzer` | `mix test --cover` | `mix test` | `mix compile` | `mix format` |
| Zig | (none) | `zig build` | `zig build test` | `zig build test` | `zig build` | `zig fmt .` |

`{format_cmd}` is informational only — not substituted into any template or script currently.

### Language → grep patterns

| Language | debug_print_pattern | env_read_pattern | todo_pattern | sleep_pattern | bare_assert_true | source_include | config_dir |
|----------|---------------------|------------------|--------------|---------------|------------------|----------------|
| Python | `print(` | `os\.environ\[` | `TODO\|FIXME\|HACK` | `sleep\(` | `assert True` | `--include="*.py"` | `config` |
| TypeScript/JS | `console\.log` | `process\.env\.` | `TODO\|FIXME\|HACK` | `setTimeout` in test | `expect\(true\)` | `--include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx"` | `config` |
| Go | `fmt\.Println` | `os\.Getenv` | `TODO\|FIXME\|HACK` | `time\.Sleep` in test | — | `--include="*.go"` | `config` |
| Rust | `println!` | `std::env::var` | `TODO\|FIXME\|HACK` | `sleep` in test | `assert!\(true\)` | `--include="*.rs"` | `config` |
| Kotlin/Java | `println\|System\.out` | `System\.getenv` | `TODO\|FIXME\|HACK` | `Thread\.sleep` in test | `assertTrue\(true\)` | `--include="*.kt" --include="*.java"` | `config` |

Additional grep patterns per language:
- `{mock_not_called}`: `verify.*never|\.notCalled|mock.*not.*called` — scope to test files only
- `{missing_assert_in_test}`: requires structural analysis (read test function bodies for missing assertions), not grep alone
- `{test_specific_impl}`: `\._\w+\(` (private method call in test)
- `{env_read_in_test}`: same as `env_read_pattern` but scoped to test files

### Language → install/verify/start

| Language | install_command | verify_command | start_command |
|----------|----------------|----------------|---------------|
| Python | `python -m venv venv && source venv/bin/activate && pip install -e ".[dev]"` | `python -c "import {project_dir}"` | `python -m {project_dir}` |
| TypeScript/Node | `npm install` | `npm run build` | `npm run dev` |
| Go | `go mod download` | `go build ./...` | `go run ./cmd/server` |
| Rust | `cargo build` | `cargo check` | `cargo run` |
| Kotlin/JVM | `gradle build` | `gradle test` | `gradle run` |
| Java | `gradle build` | `gradle test` | `gradle run` |
| Ruby | `bundle install` | `ruby -c lib/{project_dir}.rb` | `bundle exec ruby lib/{project_dir}.rb` |
| Swift | `swift build` | `swift build` | `swift run` |
| Elixir | `mix deps.get` | `mix compile --warnings-as-errors` | `mix phx.server` |
| Zig | `zig build` | `zig build test` | `zig build run` |
| C++ | `cmake -B build && cmake --build build` | `ctest --test-dir build` | `./build/{project_dir}` |

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

### Identity defaults

| Placeholder | Default |
|-------------|---------|
| `{project_dir}` | Last segment of `{repo_url}` without `.git` suffix |
| `{expected_output}` | If no code exists: `<!-- TODO: describe expected first-run output -->` |

---

## C. Empty-repo defaults

Placeholders unavailable during empty-repo setup and their default values:

| Placeholder | Empty-repo value |
|-------------|-----------------|
| `{repo_url}` | `<!-- TODO: add after pushing to remote -->` |
| `{project_dir}` | `<!-- TODO: add after pushing to remote -->` |
| `{verify_command}` | `echo "No code yet — verify after adding source"` |
| `{start_command}` | `<!-- TODO -->` |
| `{expected_output}` | `<!-- TODO -->` |
| `{deploy_command}` | (none) |
| `{ENV_VAR_1}`, `{ENV_VAR_2}` | `<!-- TODO -->` |
| `{ENV_1}`, `{ENV_2}` | `<!-- TODO -->` |
| `{module_1}`, `{module_2}` | Derived from language table |
| `{database}`, `{cache}`, `{storage}`, `{queue}` | `<!-- TODO -->` |
| `{monitoring}`, `{cicd}`, `{hosting}` | `<!-- TODO -->` |
| `{additional_tools}` | `<!-- TODO -->` |
| `{e2e_cmd}`, `{benchmark_cmd}` | (none) |
| `{threshold}` | `85` |

`{install_command}` uses the language-derived value (e.g., `go mod download`) — these work without existing code. All other tooling/grep patterns are also language-derived per the tables above.

---

## D. Examples

### Empty repo (3 questions)

**User says**: "Set up docs for a new Go project"

**AI scans**: No `go.mod`, no `src/`, no config files → empty repo.

**AI asks** (3 questions):
```
Empty repo detected.
Q1 — Project name? my-go-service
Q2 — Language/framework? [Go with Chi]
Q3 — Harness? [1 — Claude Code]

Empty repo — filling from 3 answers:
  Project: my-go-service
  Language: Go
  Harness: claude

Derived:
  Tooling: golangci-lint run, go vet ./..., go test -cover ./...
  Package manager: go modules
  install_command: go mod download

Unavailable (stubbed with <!-- TODO -->):
  verify_command, start_command, expected_output, database, cache, etc.

Proceed? [yes]
```

**AI generates**: docs/, .claude/commands/, ./CLAUDE.md, ./AGENTS.md, scripts/check.sh. All setup-time placeholders substituted per empty-repo defaults. `go mod download` used as install_command.

**AI verifies**: Artifact scan shows zero leftover setup-time placeholders. `scripts/check.sh` is executable. (Expected: check.sh will fail lint/build/test since no code exists — noted as non-blocking.)

**Cleanup**: removed /tmp/repo_template.

---

### Fresh install (minimal interaction)

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
Round 1 — Project name? [my-fastapi-app] 
Repo URL? [github.com/user/my-fastapi-app]
Confirm Python/FastAPI? [Y]
Database: PostgreSQL? [Y]

No harness dir detected — which harness? [4 — None]
  (1. Claude Code  2. OpenCode  3. Codex  4. None)

All defaults accepted. Generating docs/ ...
```

### Update mode (zero questions)

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

Proceed? [yes]

Applying changes...
  1 file updated. Verified: ruff clean, mypy clean, pytest 42 passed.
Cleanup: removed /tmp/repo_template.
```

When no harness dirs exist:
```
  Harness: none detected.

**No harness dirs detected.** Reply "claude", "opencode", or "codex" to add harness command files (pr.md, plan.md, audit_pr.md).

Proceed? (yes/no)
```

---

## E. Guardrails

### All modes

- **Clone source first**: before generating anything, `git clone {TEMPLATE_REPO_URL} /tmp/repo_template` to get the latest `docs_template/`.
- **Never invent project details**: if detection fails, ask — don't guess (fresh mode) or leave `<!-- TODO -->` (update mode).
- **Generate root `CLAUDE.md`** from `CLAUDE-template.md` and root `AGENTS.md` from `AGENTS-template.md`.
- **Install harness commands**: if a harness dir exists, confirm against the catalog (§G). If none exists, ask the user (Round 2a). Always create `docs/commands/` as the canonical copy. Type A harnesses get slash commands; Type B get agent files only.
- **Verify after generation**: if a command fails, flag it but don't block — the project may not have code yet. On empty repos, check.sh failures are expected.
- **Leave runtime placeholders intact**: only substitute the setup-time catalog listed in [Reference §A](#a-placeholder-catalog). Never touch ADR fields, spec fields, PR implementation sections, navigation current-focus/scout corrections/task map, architecture design decisions, or phase plan goals.
- **Preserve exact formatting**: only change placeholder tokens. Don't re-wrap paragraphs, don't adjust markdown syntax, don't "improve" the templates.
- **Clean up**: after generation and verification, `rm -rf /tmp/repo_template`.

### Fresh install mode

- **Never skip questions**: even if defaults seem obvious, present them for confirmation.
- **Ask about harness (Round 2a)**: if no harness directories from the catalog (§G) are detected, ask the user. Do not assume "None" silently.
- **Never overwrite `docs/` if it already exists**: warn and suggest switching to update mode.
- **Wait for approval**: after deriving all defaults, present the full plan and wait for explicit user confirmation before generating files.

### Update/refresh mode

- **Never ask questions**: everything is auto-detected from existing repo state. The harness note in the approval summary is the only prompt.
- **Never overwrite runtime content** (ADRs, specs, learnings, progress entries, architecture design decisions, navigation current-focus, scout corrections, task map, always-verify list).
- **Never delete user-created files** in `docs/` that don't correspond to a template.
- **Warn before overwriting** any file the user has modified from its template-original form.
- **Print a diff summary** before making changes so the user can review.
- **Preserve custom values**: grep patterns, coverage thresholds, project rejections the user already configured.

---

## F. Uninstall

To remove generated workflow files while preserving runtime content:

```bash
# Remove generated root files
rm -f CLAUDE.md AGENTS.md scripts/check.sh

# Remove template files from docs/ (preserves decisions/, specs/, archive/, plans/)
rm -f docs/index.md docs/quickstart.md docs/contributing.md \
      docs/code-review.md docs/testing.md docs/architecture.md \
      docs/navigation.md docs/PR-template.md docs/commands/pr.md docs/commands/plan.md docs/commands/audit_pr.md

# Remove harness command files (Type A harnesses)
rm -f .claude/commands/pr.md .claude/commands/plan.md .claude/commands/audit_pr.md \
      .opencode/commands/pr.md .opencode/commands/plan.md .opencode/commands/audit_pr.md \
      .codex/commands/pr.md .codex/commands/plan.md .codex/commands/audit_pr.md

# Remove harness directories (empty ones only)
rmdir .claude/commands 2>/dev/null
rmdir .claude/ 2>/dev/null
rmdir .opencode/commands 2>/dev/null
rmdir .opencode/ 2>/dev/null
rmdir .codex/commands 2>/dev/null
rmdir .codex/ 2>/dev/null

# Clean up empty directories
rmdir docs/commands 2>/dev/null
rmdir docs/ 2>/dev/null
```

**Preserved**: `docs/decisions/`, `docs/specs/`, `docs/archive/`, `docs/plans/` — all runtime content.

**Removed**: root agent files (`CLAUDE.md`, `AGENTS.md`), `scripts/check.sh`, generated template files, harness command files.

---

## G. Harness catalog

| ID | Name | Dir | Type | Root agent file(s) | Slash commands |
|----|------|-----|------|--------------------|----------------|
| claude | Claude Code | `.claude/` | A | `CLAUDE.md` | `.claude/commands/` |
| opencode | OpenCode | `.opencode/` | A | `AGENTS.md` | `.opencode/commands/` |
| codex | Codex | `.codex/` | A | `AGENTS.md` | `.codex/commands/` |
| copilot | GitHub Copilot | `.github/` | B | `CLAUDE.md`, `AGENTS.md` | — |
| cursor | Cursor | `.cursor/` | B | `CLAUDE.md`, `AGENTS.md` | — |
| windsurf | Windsurf | `.windsurf/` | B | `AGENTS.md` | — |

**Type A** — commands-capable: root agent file(s) + command files copied from `docs/commands/` into `{Dir}/commands/`. `/pr`, `/plan`, `/audit_pr` execute natively as slash commands.

**Type B** — agent-files-only: root agent file(s) generated. No commands directory created — these harnesses read `CLAUDE.md`/`AGENTS.md` directly. `docs/commands/` canonical copies remain as protocol reference.

### Protocol rules

- **Detection** (§1b, §4 R2a): scan for all `{Dir}` values from this catalog.
- **Enumeration**: generate numbered lists from catalog entries, Type A first, then Type B. Never hardcode harness names in protocol text.
- **Confirmation** (§4 R2a, §5c): if a `{Dir}` matches a catalog entry, confirm with user. If none match, present full catalog for selection.
- **Agent file generation** (§6f): only generate the file(s) listed in "Root agent file(s)" column for the selected harness.
- **Command generation** (§6g): only Type A harnesses get a `{Dir}/commands/` directory. Type B and "None" skip it.
- **Cleanup** (§F): iterate catalog entries to `rm -f {Dir}/commands/*.md`.
