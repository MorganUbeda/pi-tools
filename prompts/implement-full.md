---
description: Orchestrate full plan implementation via sequential subagent spawns
---

# Full Implementation Orchestrator

## Goal
Run all unchecked tasks from PLAN.md through subagents. Never implement or debug directly — delegate everything.

## Workflow
1. **Setup** — If on main, create an informative branch (e.g., `feature-auth`). Write name to `.pi-branch`.
2. **Read PLAN.md** — Find first unchecked `[ ]` task.
3. **Loop** for each task:
   a. `pi -p "/implement-sub <task-N.md>"` — read `.pi-task-status`
   b. If FAILURE: STOP and report
   c. `pi -p "/review-changes <task-N.md>"` — read `.pi-task-status`
   d. If FAIL: debug cycle (step e, up to 3 retries)
   e. `pi -p "/debug-fix <task-N.md>"` — read `.pi-task-status` → re-review
   f. On PASS: mark `[x]` in PLAN.md, commit both, continue to next task
4. **Done** — STOP with summary of changes and commits.

## Rules
- **Pure orchestrator** — never implement, edit code, or debug directly
- Sequential only, one subagent at a time
- All commits are done by this prompt (worktree + PLAN.md)
- Never work on main

## Report
- Branch name, tasks completed/failed, files changed, commits made

**STOP** after reporting.
