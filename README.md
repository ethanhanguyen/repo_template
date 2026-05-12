# repo_template

AI-assisted software development workflow in a box. Point an AI at this repo, and it sets up your project's entire docs infrastructure — templates, quality gates, tracking dashboards, and agent rules — customized to your stack.

## What you get

```
your-project/
├── CLAUDE.md              # Agent rules: plan-first, TDD, quality gates
├── docs/
│   ├── index.md            # Docs entrypoint
│   ├── quickstart.md       # 5-minute setup guide
│   ├── architecture.md     # System design + tech stack + scaling model
│   ├── contributing.md     # Setup, conventions, PR workflow
│   ├── code-review.md      # 4-phase review checklist with auto-reject triggers
│   ├── testing.md          # Testing guide, anti-pattern catalog, coverage targets
│   ├── PR-template.md      # Canonical PR workflow with enforcement gates
│   ├── navigation.md       # Session protocol, task map, scout corrections
│   ├── archive/
│   │   └── learnings.md    # Accumulated project knowledge
│   ├── decisions/
│   │   └── YYYY-MM-DD-decision-template.md   # Architecture Decision Record template
│   ├── plans/
│   │   ├── progress.md     # Master tracking: PRs, pipeline, quality, sessions
│   │   ├── phase-plan-template.md            # Phase plan template
│   │   └── PR-prompt-template.md             # Single-PR implementation prompt
│   └── specs/
│       └── spec-template.md                  # Feature specification template
└── .gitignore
```

## Usage

### New projects

1. **Clone this repo** as your project starter
2. **Open it with an AI coding agent** (Claude Code, OpenCode, Cursor, etc.)
3. **Say**: *"Read INSTALL.md and set up the workflow"*
4. **Answer ~5-8 questions** about your stack — the AI derives everything else
5. **Done** — `docs/`, `CLAUDE.md`, and `.gitignore` are generated and verified

### Existing projects

1. **Copy the essentials into your project**:
   ```
   cp -r docs_template/ your-project/
   cp INSTALL.md your-project/
   ```
   (The `docs_template/` directory is temporary — it gets removed after generation.)

2. **Open the project with an AI agent** and say: *"Read INSTALL.md and set up the workflow"*

3. **The AI auto-detects** your existing stack from `package.json`, `pyproject.toml`, etc. — fewer questions than a fresh project.

4. **After generation**, remove the scaffolding:
   ```
   rm -rf docs_template/ INSTALL.md
   ```
   Keep `CLAUDE.md`, `docs/`, and `.gitignore` — they're now yours.

Or run it manually: read `INSTALL.md` and follow the 6-step protocol.

### What the AI asks

| Phase | Questions | Example answer |
|-------|-----------|----------------|
| Identity | Project name, repo URL, language/framework | `my-api`, `github.com/org/my-api`, Python/FastAPI |
| Tooling | Confirm auto-derived commands | `ruff check .`, `pytest --cov`, `mypy src/` |
| Structure | Tech stack, dir layout, env vars, conventions | PostgreSQL, Redis, pnpm, pr<N>- branches |
| Quality | Coverage thresholds, grep guards, custom rejections | 85% overall, no `print()` in prod |

The AI detects your stack from existing config files (`package.json`, `pyproject.toml`, etc.) and asks for confirmation — you rarely need to type more than "yes."

## Philosophy

**Plan first, code second.** Every feature or bug fix starts with a PR plan doc in `docs/plans/`, updates to `progress.md` and `architecture.md`, and only then touches code. This is enforced by `CLAUDE.md`.

**Surgical changes only.** No speculative features, no unrelated refactoring, no "improvements" outside scope. The 4-phase code review checklist catches these at review time.

**Docs as living infrastructure.** `progress.md` tracks every PR and session. `learnings.md` accumulates gotchas across sessions. ADRs record why decisions were made. The docs are the project's memory.

**Language-agnostic.** The template system supports 13 languages (Python, TypeScript, Go, Rust, Java, Kotlin, C++, Ruby, Swift, Elixir, Zig, and more). Tooling commands and grep guards are auto-derived per stack.

## Files

| File | Purpose |
|------|---------|
| `docs_template/` | Template files with `{PLACEHOLDER}` tokens |
| `INSTALL.md` | AI protocol: 6-step guided setup with 4-phase questionnaire |
| `CLAUDE.md` | Agent rules for this repo (plan-first, quality gates) |
| `.gitignore` | Ignores generated `docs/`, secrets, OS/editor junk |
