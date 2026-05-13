# Navigation

## Session start

1. Read `docs/index.md` → update `Current focus` section below
2. Run any project-warmup commands (e.g. `source venv/bin/activate`, `npm install`)
3. Check recent `docs/archive/learnings.md` for gotchas

## Current focus

<!-- Update this section at the start of every session -->
> **PR / Task**: {what are you working on?}
> **Phase**: {phase number/name}
> **Branch**: {branch name}

## Task map

| Goal | How |
|------|-----|
| Implement a PR | Follow `docs/PR-template.md` enforcement gates (quality gates → code review → commit → auto merge) |
| Run full atomic PR | Use `/pr <description>` command — plan → implement → gates → code review → PR → auto merge |
| Debug / fix a bug | Run tests first, grep root cause |
| Write tests | Follow `docs/testing.md` authoring guide |
| Architecture / design decision | Write an ADR in `docs/decisions/` |
| Code review | Run `bash scripts/check.sh` + behavioral self-review |

## Context protocol

- **Search first**: grep/glob before reading whole files
- **Never ls whole directories** — use glob patterns instead
- **Read neighboring files** before writing new code — match conventions
- **Check archive/learnings.md** before repeating past work

## Scout corrections

<!-- Add project-specific "gotchas" discovered during development -->
<!-- Format: "When doing X, grep for Y before Z" -->
<!-- Example: -->
<!-- |#|Rule|Why|
   |1|Run `{lint_cmd}` before committing|Catches type errors CI would reject|
   |2|Grep for `{pattern}` before adding new `{thing}`|Avoids duplication|

## Session close

1. Update **Current focus** above with next session's task
2. Add any new scout corrections to the table above
3. Log key learnings to `docs/archive/learnings.md`
   - Decisions made, risks flagged, anti-patterns hit, bugs found
