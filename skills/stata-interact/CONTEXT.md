# Context for Stata Interact Skill

## Task 1a: Minimal Working Script (Completed)

### Decisions Made
- **Stata command**: Use `stata-mp` (multi-processing)
- **Session naming**: Accept session name as first positional argument
- **Code input**: Accept code as remaining positional arguments
- **Output capture**: Default to last 1000 lines, `-c` flag for full history
- **Error handling**: Check session existence and Stata process status

## Task 1c: History Capture Mode (Completed - Updated)

### Original Implementation (Deprecated)
- **Flag**: `-c` for history capture mode
- **Implementation**: Use `-S -` in `tmux capture-pane` to capture entire pane history from beginning
- **Default behavior**: Without `-c`, capture only last 1000 lines

### Current Implementation (Simplified)
- **Flag**: `-c` dumps full session buffer (no command execution)
- **Default behavior**: Always capture entire buffer (1M line history limit)
- **Validation**: `-c` with code or file arguments returns error

### Implementation Pattern
- Parse flags before extracting positional arguments
- Set `CAPTURE_ONLY=true` when `-c` flag is present
- In `capture_output()`, always use `-S -` for full history
- Set tmux `history-limit` to 1000000 when creating sessions
- `-c` mode skips all command-sending logic and dumps buffer directly

### Constraints Discovered
- Flags must be parsed before positional arguments to avoid sending them to Stata
- `tmux capture-pane -S -` captures from the very beginning of pane history
- Full history includes Stata startup banner and all previous commands
- tmux `history-limit` setting controls how much history is retained
- Overhead of capturing full buffer is negligible compared to parsing benefits

### Files Modified
- `scripts/stata.sh` - Simplified to always capture full buffer, `-c` now dumps buffer only

---

## Task 1b: File Input Mode (Completed)

### Decisions Made
- **Flag**: `-f <file>` for file input mode
- **Command**: Send `do <file>` to Stata session
- **Path handling**: Use full path with quotes to handle spaces/special characters

### Implementation Pattern
- Check file exists before sending to Stata
- Use `"$file"` in do command to handle paths with spaces
- Exit with error if file not found

### Constraints Discovered
- File path must be accessible from Stata's working directory or use absolute path
- tmux send-keys requires proper quoting for paths with spaces

### Files Modified
- `scripts/stata.sh` - Added `-f` flag parsing and `send_do_file` function

---

## Task 1e: Comment Removal (Completed)

### Decisions Made
- **Implementation approach**: Line-by-line processing with state tracking for block comments
- **Comment types handled**:
  - `*` at start of line: Remove entire line
  - `//` at start of line: Remove entire line
  - `//` inline: Remove comment and everything after it
  - `/* ... */` single-line: Remove comment block
  - `/* ... */` multi-line: Remove entire comment block across lines
  - `///` at end of line: Remove just the `///`, preserve newline and indentation
- **Whitespace handling**: Trim leading whitespace only when a block comment is removed from line start

### Implementation Pattern
- Track `in_block_comment` state for multi-line `/* ... */` comments
- Track `line_modified` flag to determine when to trim leading whitespace
- Use `sed` for reliable `/* ... */` removal within a line
- Preserve indentation for continuation lines after `///`

### Constraints Discovered
- Need to handle content after `*/` on same line
- Must preserve indentation for `///` continuation lines
- `sed` pattern `s|/\*[^*]*\*/||g` works for single-line block comments
- Multi-line block comments require state tracking

### Files Modified
- `scripts/stata.sh` - Added `remove_comments()` function with comprehensive comment handling

---

### Implementation Pattern
- Parse flags first (`-f`, `-c`, `-r`), then positional args
- Session management: create if missing, restart if Stata not running
- Send code line-by-line with `tmux send-keys` and `Enter`
- Small delays (0.1s per line, 0.5s after all lines) for Stata processing

### Constraints Discovered
- Stata must be in PATH or use full path (`stata-mp` assumed available)
- tmux session names must be unique
- Stata requires Enter key after each command line
- Output capture uses `-S -1000` for last 1000 lines (configurable)

### Files Modified
- `scripts/stata.sh` - Created with basic session management, code sending, output capture

## Key Decisions

### Session Management

- **Decision**: Accept session name as parameter, create if not exists,
  auto-start Stata if not running
- **Reason**: Allows agent to work within a persistent session while
  maintaining flexibility

### Command Input Methods

- **Decision**: Support two methods:
  1. Command-line arguments: `./scripts/stata.sh "regress y x"`
  2. File input: `./scripts/stata.sh -f script.do`
- **Reason**: Maximum flexibility for different use cases; stdin mode deferred

### Output Handling

- **Decision**:
  - Default: Capture entire buffer (1M line history), output only the last result to stdout
  - Option: `-c` flag to dump entire session buffer (no command execution)
- **Reason**: Clean output for typical use, full history available when needed
- **Implementation**: Always capture full buffer, parse to extract last command's output

### Error Handling

- **Decision**: Detect crashed sessions and provide restart capability
- **Reason**: Stata can crash; agent needs to recover without manual intervention

### Implementation Strategy

- **Decision**: Incremental development with working script after each task
- **Reason**: Allows early testing and validation, reduces risk of large refactoring
- **Task 1a**: Minimal working script (session management, code sending, raw output capture)
- **Task 1b**: Add file input mode
- **Task 1c**: Add history capture mode
- **Task 1d**: Add restart functionality
- **Task 1e**: Add comment removal
- **Task 1f**: Add output parsing to extract only the last command's results

## Constraints Discovered

1. **Stata Path**: The script must know where Stata is installed.
   - Hardcoded path: `/Applications/StataNow/StataMP.app/Contents/MacOS/stata-mp`

2. **TMUX Session Naming**: Session names must be unique per user. Consider:
   - Using session name parameter directly
   - Prefixing with user identifier to avoid collisions

3. **Stata Input Method**: Stata may require specific key sequences:
   - Need to send Enter key after each line
   - Need to parse out comments:
     - Lines starting with `*` or `//` → remove whole line
     - `/* ... */` blocks → remove (potentially multi-line)
     - `///` at end of line → remove symbol and newline

4. **Output Parsing**: Stata output includes:
   - Command echoes
   - Results tables
   - Error messages
   - Need to identify "last result" reliably → Find last occurrence of `. <command>` in tmux buffer (where `. ` is Stata prompt), extract everything after that line until next `. ` prompt or end of buffer

5. **History Management**:
   - tmux `history-limit` defaults to 2000 lines
   - Set to 1000000 when creating sessions to preserve full history
   - Always capture full buffer (negligible overhead, avoids edge cases)

---

## Task 1f: Output Parsing (Completed)

### Decisions Made
- **Pattern matching**: Use exact string matching for `. command` pattern in tmux buffer
- **Natural delimiter**: Leverage Stata's `. ` prompt as built-in delimiter
- **First line matching**: Extract the first non-comment line from the command for pattern matching
- **Buffer line counting**: Count lines that will appear in the buffer (original command minus comment-only lines)

### How It Works
1. When sending command via `tmux send-keys`:
   - Stata is at prompt showing `. `
   - Our command gets appended to same line: `. command something`
   - For multi-line commands, each line is sent separately
2. This creates an exact string in tmux buffer
3. After command execution, output appears, followed by next `. ` prompt
4. Find last `. <first_line_of_command>` and extract everything after it

### Implementation Pattern
- After sending command and capturing output:
  - Extract the first non-comment line from the original command (before /// processing)
  - This is what appears after `. ` in the buffer
  - Find last occurrence of exact string `. <first_line>` using grep -F (fixed string)
  - Count buffer lines (original command minus comment-only lines)
  - Skip all command lines and extract from the first output line
  - Stop at next `. ` prompt or end of buffer
- Use exact string matching (not regex) to avoid special character issues
- Handle multi-line commands by counting buffer lines correctly

### Constraints Handled
- Exact string matching (escape special regex characters) - solved with grep -F
- Multi-line commands after `///` joining - count buffer lines, not processed lines
- Identical consecutive commands (we want last occurrence) - use tail -1
- Comment lines are removed before sending - extract first non-comment line for matching
- `///` line continuations - buffer has original multi-line format, not joined

### Files Modified
- `scripts/stata.sh` - Enhanced `parse_last_result()` function with:
  - First line extraction logic
  - Buffer line counting (excluding comment-only lines)
  - Proper multi-line command handling
- `test_parsing_final.sh` - Comprehensive test suite with 14 test cases

### Test Coverage
- Simple commands
- Multi-line output
- Output followed by prompt
- Command at end of buffer
- Special characters (parentheses, etc.)
- Finding the LAST occurrence of duplicate commands
- Substring commands
- Commands with comments
- Commands with /// line continuation
- Commands with no output
- Pattern not found (fallback to full output)

---

## Important Context for Downstream Tasks

### Files to Create

1. `SKILL.md` - Skill specification (required)
2. `scripts/stata.sh` - Main helper script (required)

### Testing Requirements

- Test with actual Stata installation
- Verify tmux session creation and management
- Test both input methods (args and file)
- Test error recovery scenarios
- Test comment removal (*, //, /* */, ///)

### Dependencies

- tmux (must be installed)
- Stata (must be installed and accessible)
- Bash (for shell script)

### Security Considerations

- Script executes arbitrary Stata code provided by agent
- No user authentication needed (agent is trusted)
- Session name should be validated to prevent tmux injection