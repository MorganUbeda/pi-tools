---
description: Write agreed-upon plan to files
---

# Write Plan Session

## Goal
Write the agreed plan to `$1`.

## Workflow
1. If `$1` is missing, STOP and ask for the target directory
2. Write `$1/PLAN.md`
3. Write every task file listed in `PLAN.md` under `$1/`
4. STOP

## Output Format

**`$1/PLAN.md`**

```markdown
# [Descriptive Title]

[One sentence summary]

## TODO

- [ ] task-a.md
- [ ] task-b.md

## General Context

[Notes relevant to all tasks]
```

**Each task file listed in `PLAN.md`**

```markdown
# Task: [Task Name]

## What
[Work to do]

## How
[Implementation approach]

## Verify
[How to confirm completion]

## Context
[Task-specific context]

## Dependencies
[Other task files, or "None"]
```

## Rules
- Write `$1/PLAN.md` and every task file listed in it
- Use the filenames listed in `PLAN.md`
- Include only agreed tasks, context, and verification criteria
- Order tasks so dependencies come first
- Do not add new tasks, make design decisions, or implement repository changes

**STOP** after writing all plan files and wait for user instruction.
