---
description: Write agreed-upon plan to files
---

# Write Plan Session

## Goal

Write the agreed-upon plan to PLAN.md in $@

## Output Format

**PLAN.md** (at directory root):

```markdown
# [Descriptive Title]

[One sentence: what this plan achieves]

## TODO

- [ ] task-1.md
- [ ] task-2.md
- [ ] task-3.md

## General Context

[Links, data sources, project notes relevant to all tasks]
```

**task-N.md** (individual task files):

```markdown
# Task: [Task Name]

## What
[Clear description of the work]

## How
[Key implementation details or approaches]

## Verify
[How to confirm completion, e.g., "compiles", "test passes"]

## Artifacts
[Expected files/outputs produced]

## Risk
[Low/Medium/High] - flag particularly risky or complex tasks

## Context
[Any specific context for this task]
```

## Rules

**MUST:**

- Write the PLAN.md file in $@
- Include all tasks discussed during planning
- Include all context and verification criteria agreed upon
- Order tasks so dependencies precede dependents

**NEVER:**

- Add new tasks not discussed with the user
- Make design decisions during this step
- Start implementing changes to the repository

**STOP** after writing PLAN.md and wait for user instruction.
