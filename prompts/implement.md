---
description: Implement one task from plan, verify, and mark complete
---

# Implementation Session

## Goal
Implement the first unchecked task from PLAN.md, verify, mark complete, then STOP.

## Workflow
1. **Read** - Find first unchecked task `[ ]` in PLAN.md; read its task-N.md file
2. **Implement** - Modify only files required by this task
3. **Verify** - Confirm implementation works per specification
4. **Mark done** - Update PLAN.md: change `[ ]` to `[x]`
5. **Update CONTEXT.md** - Document important decisions/constraints (skip if nothing notable)
6. **STOP** - Report and wait for user

## Rules
- **One task per session only**; don't proceed to subsequent tasks
- Only read your task-N.md, not all task files
- Only modify files the task requires
- Obvious cases: assume and document; unclear: ask user
- Try 2-3 fixes on errors, then STOP and report
- **Never continue after failure; never jump to next task**

## Report
- Task completed: [name]
- Files modified
- Verification results
- Issues/resolutions
- PLAN.md/CONTEXT.md updated

**STOP** and await user instructions.
