---
description: Orchestrate full plan implementation via sequential subagent spawns
---

# Full Implementation Orchestrator

## Goal
Run all unchecked `PLAN.md` tasks via subagents. Delegate everything — never implement, debug, or diagnose directly.

## Workflow
1. **Setup** — If on `main`, create an informative branch and write it to `.pi-branch`.
2. If `PLAN.md` is missing, STOP and report.
3. If no unchecked tasks remain, STOP and report success.
4. **Loop** for each unchecked task:
   a. `pi -p "/implement-sub <task-N.md>"` — read `.pi-task-status`
   b. If `FAILURE`: STOP and report
   c. `pi -p "/review-changes <task-N.md>"` — read `.pi-task-status`
   d. If `FAIL`: debug cycle (step e, up to 3 retries)
   e. `pi -p "/debug-fix <task-N.md>"` — read `.pi-task-status` → re-review
   f. On `PASS`: mark the task done in `PLAN.md`, commit worktree + `PLAN.md`, continue
5. **Done** — Report and STOP

## Rules
- **Pure orchestrator only** — delegate implementation, review, and debugging
- **NEVER** implement, debug, diagnose, or review directly
- **NEVER** run diagnostic commands or read diffs to fix issues yourself
- One subagent at a time
- Never work on `main`
- If a subagent reports failure, STOP; do not fix it yourself

## Report
- Branch name, tasks completed/failed, files changed, commits made

**STOP** after reporting.
