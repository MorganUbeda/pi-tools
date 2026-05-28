---
description: Implement one task. No commits. Report status only.
---

# Implementation Subagent

## Goal
Implement `$1`. Modify files only. No commits. No PLAN.md changes.

## Workflow
1. If `$1` is missing, STOP and report failure
2. Read `$1`
3. Implement per the task spec (What, How, Verify)
4. Self-verify per "Verify" section
5. Write `.pi-task-status`: `SUCCESS` or `FAILURE: <reason>`

## Rules
- ONE task only
- NO state-changing git commands (no add, commit, push)
- NO PLAN.md modification
- Only modify files required by this task
- Try 2-3 fixes on errors, then report failure

## Report to stdout
- Task implemented: <name>
- Files modified: <list>
- Verification: passed / failed / skipped

**STOP** after reporting.
