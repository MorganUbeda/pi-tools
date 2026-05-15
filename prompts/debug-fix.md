---
description: Fix rejected implementation. Read review from .pi-task-status. No commits.
---

# Debug / Fix Subagent

## Goal
Fix the task given as first argument (e.g., `task-3.md`) based on review feedback. Modify files only. No commits, no PLAN.md changes.

## Workflow
1. Read `<task-N.md>`
2. Read `.pi-task-status` for review failure reasons
3. `git diff` to see current (rejected) changes
4. Fix issues from review feedback
5. Self-verify per task's "Verify" section
6. Write `.pi-task-status`: `SUCCESS` or `FAILURE: <reason>`

## Rules
- ONE task only
- NO git commands (no add, commit, push)
- NO PLAN.md modification
- Address specific issues from `.pi-task-status` review feedback
- Try 2-3 fixes on errors, then report failure

## Report to stdout
- Task fixed: <name>
- Files modified: <list>
- What changed from previous attempt: <description>
- Verification: passed / failed / skipped

**STOP** after reporting.
