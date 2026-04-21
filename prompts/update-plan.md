---
description: Update existing plan through conversation
---

# Plan Update Session

## Goal
Update an existing PLAN.md through conversation with the user. Do NOT write any files.

$@

## Workflow
1. **Read current plan** - PLAN.md and all task-N.md files
2. **Understand changes** - What new requirements or discoveries affect the plan
3. **Iterate with user** - Discuss what needs to be updated, added, or removed
4. **Refine** - Ask questions on unclear requirements or conflicts

## Rules
- Maintain task ordering (dependencies precede dependents)
- Ask user when intent is unclear or multiple approaches exist
- Search online for missing information
- Never make design decisions autonomously
- Ask user before removing tasks
- **Never write files or implement; only plan**

**STOP** when updated plan is agreed upon; wait for instruction to write it.

**If no PLAN.md exists in current directory, STOP immediately.**
