# Plan State — `{slug}`

<!-- 
  Tracks one planning session across turns. One file per plan (plan-state-{slug}.md).
  Written at Step I0. Read every turn for resume.
-->

## Session

| Field | Value |
|-------|-------|
| **Slug** | `{slug}` |
| **Original description** | {user's /plan description} |
| **Investigation report** | (set at I1) |
| **Complexity tier** | unset |
| **Current step** | I0 |

## Approvals

| Step | Deliverable | Status | Notes |
|------|-------------|--------|-------|
| I0 | Investigation dispatch | pending | — |
| I1 | Investigation report | pending | ← user-facing gate |
| A1 | Complexity tier | pending | — |
| A2 | Spec | pending | — |
| A3 | Phase plan | pending | — |
| A4 | PR docs | pending | — |
| A5 | ADRs | pending | — |
| A6 | Final approval | pending | ← user-facing gate |

Statuses: `pending` → `approved` | `skipped` | `pre_approved`

## Change log

| Turn | Step | What happened |
|------|------|---------------|
| 1 | I0 | Session initialized |
