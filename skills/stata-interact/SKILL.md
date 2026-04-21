---
name: stata-interact
description: Execute Stata code and get results. Can be used to get help on Stata commands.
---

# Stata Interact

## Output Format

- **Default**: Returns only the output of the last executed command or script
- **`-c` flag**: Returns the full session buffer (all history)

## Usage

**Command format:**

```bash
# Run a command
{baseDir}/stata-interact/scripts/stata.sh -s <session> -e "sysuse auto"

# Run a followup command in the same session
{baseDir}/stata-interact/scripts/stata.sh -s <session> -e "describe"

# Run multiple commands in one go
{baseDir}/stata-interact/scripts/stata.sh -s <session> -e "
  sysuse auto
  describe
"

# Run from file
{baseDir}/stata-interact/scripts/stata.sh -s <session> -f analysis.do

# Get full session history
{baseDir}/stata-interact/scripts/stata.sh -s <session> -c

# Restart Stata and run a command in session
{baseDir}/stata-interact/scripts/stata.sh -s <session> -r -e "command"

# Cleanup session
{baseDir}/stata-interact/scripts/stata.sh -s <session> -k

# Get help on a Stata command
{baseDir}/stata-interact/scripts/stata.sh -s <session> -e 'help regress'

# Search for Stata commands
{baseDir}/stata-interact/scripts/stata.sh -s <session> -e 'search logistic regression'
```

## Notes

Please avoid spawning lots of sessions:

- Keep the session alive when you think that you will need to run followup commands
- Otherwise use `-k` to close the session if you don't plan on reusing it
- Use `-r` to get a fresh Stata instance if you need a clean state but already have a session running

