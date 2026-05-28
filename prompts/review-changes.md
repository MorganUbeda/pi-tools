---
description: Review uncommitted changes against a task spec. Write status file.
---

# Review Changes Session

## Goal
Review the uncommitted worktree against `$1`. Write result to `.pi-task-status`.

## Workflow
1. If `$1` is missing, STOP and report failure
2. Read `$1`
3. `git status` + `git diff` for uncommitted changes
4. `git log --oneline -5` for context
5. Evaluate against spec:

   **Scope** — Do changes match the task's "What" and "How"? Extra modifications?
   - Clearly necessary (omitted from spec): note as acceptable
   - Not necessary / implementer mistake: FAIL

   **Correctness** — Do changes satisfy "Verify"? Any bugs or regressions?

6. Write `.pi-task-status`:
   - `RESULT: PASS` or `RESULT: FAIL — <reason>`

## Rules
- Be strict about scope — unexplained extra modifications are suspicious
- Do NOT modify files or run state-changing git commands

## Decision
**PASS:** changes match spec, verification met, extras are justified
**FAIL:** spec mismatch, verification failed, suspicious extras, or bugs

**STOP** after writing status file.
