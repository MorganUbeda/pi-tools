---
description: Implement one task from plan, verify, and mark complete
---

# Implementation Session

## Goal
Implement the first unchecked task from PLAN.md, verify, mark complete, then STOP.

## Workflow
1. If `PLAN.md` is missing, STOP and report
2. Find the first unchecked task in `PLAN.md`; if none remain, STOP and report
3. Read the referenced task file
4. Implement only that task
5. Verify per the task spec
6. Mark the task done in `PLAN.md` (`[ ]` → `[x]`)
7. Update `CONTEXT.md` only if needed
8. Report and STOP

## Rules
- One task only
- Read only the selected task file
- Modify only files this task requires
- Obvious cases: assume and document; unclear: ask user
- Try 2-3 fixes on errors, then STOP
- Never continue to the next task

## Report
- Task completed: [name]
- Files modified
- Verification results
- Issues/resolutions
- PLAN.md/CONTEXT.md updated

**STOP** and await user instructions.
