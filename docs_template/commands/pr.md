# /pr — Atomic PR workflow

When the user invokes `/pr <description>` or says "create a PR for <description>":

## Rules

- **Atomic**: run all 6 phases in order. Never skip.
- **Evidence before claims**: show fresh command output for every gate.
- **Fail fast**: if a gate fails, fix before continuing.

---

## Phase 1 — Plan

1. Read `docs/plans/PR-prompt-template.md` for structure
2. Check `docs/navigation.md` **Current focus** section for active PR/phase
3. Check `docs/plans/progress.md` **PR Status** table for existing PRs — avoid overlapping numbers or descriptions
4. Determine next PR number from `docs/plans/`
5. Create `docs/plans/PR{N}-{slug}.md` — fill all sections

## Phase 2 — Document

6. Update `docs/plans/progress.md` — add PR row
7. Update `docs/navigation.md` — set **Current focus** to this PR
8. **ADR**: if this is a significant architectural change, write `docs/decisions/YYYY-MM-DD-{title}.md`
9. Update `docs/architecture.md` — if module boundaries, data flow, or tech stack changes
10. Update `README.md` — if setup or usage changes
11. **Commit & push** all doc updates before implementation

## Phase 3 — Implement

12. TDD per component: RED → GREEN → REFACTOR
13. Match existing conventions, handle errors at external boundaries
14. See plan doc (`docs/plans/PR{N}-{slug}.md`) for per-component constraints and error handling

## Phase 4 — Quality gates

15. Run automated gates per `docs/PR-template.md` Gate 3
16. All must pass with fresh evidence: lint, typecheck, test, build, grep guards, secrets
17. Fix any failures before proceeding

## Phase 5 — Code review

18. Run 4-phase review per `docs/code-review.md`
19. Zero rejection triggers must fire. Paste evidence per phase.

## Phase 6 — Commit & push (do NOT open PR)

20. Commit (conventional commit) and push all code changes
21. **Do NOT open PR** — auto merge is handled by the next step in the pipeline
22. Update `docs/plans/progress.md` — mark PR row status
23. Update `docs/navigation.md` — clear **Current focus**
24. **Commit & push** all final doc updates
25. Report: branch name, files changed, tests added, gates passed, pushed ✓
