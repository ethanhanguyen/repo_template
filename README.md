# repo_template
> AI-native project infrastructure. One file. One sentence. Generated for your stack.

## Here's what happens

```
$ cp INSTALL.md my-api/
$ # Open with any AI coding agent
$ # "Read INSTALL.md and set up the workflow"

  ▸ Detected:  Python 3.12 · FastAPI · PostgreSQL
  ▸ Questions: project name, repo URL, harness, tooling, quality
  ▸ Plan:      presented for approval
  ▸ Generated: docs/ + scripts/check.sh + CLAUDE.md + AGENTS.md

  ✓ ruff check .        clean
  ✓ mypy src/           clean
  ✓ pytest --cov        94% covered

  Ready. /plan "your first feature"
```

## The problem

AI agents are fast at writing code. After a few sessions, you can't answer: *what changed, why, and is it tested?* The agent rewrites things it shouldn't. Decisions evaporate. Tests are scattered or missing. You spend half the session explaining your own codebase.

## Without vs. With

| | Without | With |
|---|---------|------|
| **Day 1** "Add auth" | Code works. No plan. No ADR. No coverage tracked. | `/plan` → approved. `/pr` → TDD → check.sh → merge + ADR. `progress.md` ✅. |
| **Day 3** "Add reset" | Agent rewrites auth middleware. Creates duplicate session system. No context. | Reads `progress.md` (auth done, PR1) + ADR (chose JWT) + `learnings.md` (rate limit gotcha). Extends cleanly. |
| **Day 10** "Fix bug" | Reads 8 files. Asks you to explain YOUR codebase. Suggests rewrite. | Reads `architecture.md`. Knows module boundary. Fix is 3 lines. |
| **Month 3** "Why JWT?" | `git blame` → PR description: "add user auth" → nobody knows. | `decisions/2026-01-15-jwt-auth.md` — full rationale, alternatives, consequences. |

## What you get

```
project/
├── docs/
│   ├── plans/progress.md       Dashboard: every PR, every session
│   ├── decisions/              ADRs: why every choice was made
│   ├── archive/learnings.md    Session log: gotchas, insights
│   └── architecture.md         System design, kept current by every PR
├── scripts/check.sh            Gate: lint → typecheck → test → grep guards
├── CLAUDE.md                   Agent rules: plan-first, TDD, quality
└── .claude/commands/           /plan + /pr + /audit_pr slash commands
```

These aren't static docs. The agent reads them at the start of every session and writes to them at the end. They stay current because the workflow depends on them.

## Philosophy

**Plan first.** `/plan` before `/pr`. Think before coding. The agent can't skip it.

**Surgical.** No "while I'm here" refactoring. Behavioral self-review catches drift at review time.

**Automated quality.** `bash scripts/check.sh` is the only gate command. If it passes, ship.

13 languages. Python, TypeScript, Go, Rust, Java, Kotlin, C++, Ruby, Swift, Elixir, Zig, and more.
