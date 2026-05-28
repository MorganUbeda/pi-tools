---
description: Orchestrate full plan implementation via sequential subagent spawns
---

# Full Implementation Orchestrator

## Goal
Run all unchecked `PLAN.md` tasks via subagents. Orchestrate only.

## Workflow
1. If on `main`, create an informative branch and write it to `.pi-branch`
2. If `PLAN.md` is missing, STOP and report
3. If no unchecked tasks remain, STOP and report success
4. For each unchecked task:
   a. Run `/implement-sub` with the task file; read `.pi-task-status`
   b. On `FAILURE`, STOP and report
   c. Run `/review-changes` with the task file; read `.pi-task-status`
   d. On `FAIL`, run `/debug-fix` with the same task file, then re-review; retry up to 3 times
   e. On `PASS`, mark the task done in `PLAN.md`, commit worktree + `PLAN.md`, continue
5. Report and STOP

## Rules
- Orchestrate only; delegate implementation, review, and debugging
- Never implement, debug, diagnose, or review directly
- Never run diagnostic commands or read diffs to fix issues yourself
- One subagent at a time
- Never work on `main`
- If a subagent reports failure, STOP; do not fix it yourself

## Report
- Branch name, tasks completed/failed, files changed, commits made

**STOP** after reporting.
