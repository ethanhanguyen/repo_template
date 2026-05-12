# /pr — Atomic PR workflow

When the user invokes `/pr <description>` or says "create a PR for <description>":

## Rules

- **Atomic**: run all 6 phases in order. Never skip.
- **Evidence before claims**: show fresh command output for every gate.
- **Fail fast**: if a gate fails, fix before continuing.

---

## Phase 1 — Plan

1. Read `docs/plans/PR-prompt-template.md` for structure
2. Determine next PR number from `docs/plans/`
3. Create `docs/plans/PR{N}-{slug}.md` — fill all sections

## Phase 2 — Document

4. Update `docs/plans/progress.md` — add PR row
5. **ADR**: if this is a significant architectural change, write `docs/decisions/YYYY-MM-DD-{title}.md`
6. Update `docs/architecture.md` — if module boundaries, data flow, or tech stack changes
7. Update `README.md` — if setup or usage changes

## Phase 3 — Implement

8. TDD per component: RED → GREEN → REFACTOR
9. Match existing conventions, handle errors at external boundaries
10. See plan doc (`docs/plans/PR{N}-{slug}.md`) for per-component constraints and error handling

## Phase 4 — Quality gates

11. Run automated gates per `docs/PR-template.md` Gate 3
12. All must pass with fresh evidence: lint, typecheck, test, build, grep guards, secrets
13. Fix any failures before proceeding

## Phase 5 — Code review

14. Run 4-phase review per `docs/code-review.md`
15. Zero rejection triggers must fire. Paste evidence per phase.

## Phase 6 — Open PR + auto merge to main

16. Commit (conventional commit), push, open PR — body from `docs/PR-template.md`
17. Auto merge: `gh pr merge --auto --squash` (fallback: `gh pr merge --squash`)
18. Delete feature branch, update `docs/plans/progress.md` — mark merged
19. Report: PR URL, files changed, tests added, gates passed, merged ✓
