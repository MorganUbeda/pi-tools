#!/bin/bash
# Stata-Tmux Interaction Script
# Sends Stata code to a tmux session and captures output

set -e

# Default values
SESSION_NAME=""
CODE=""
FILE_INPUT=""
CAPTURE_ONLY=false
RESTART=false
KILL_SESSION=false
SHOW_HELP=false
COMMAND_TO_PARSE=""

# Function to display help message
show_help() {
    cat << EOF
Stata-Tmux Interaction Script

Usage: $(basename "$0") -s <session_name> [OPTIONS] [code...]
       $(basename "$0") -s <session_name> -e <code>
       $(basename "$0") -s <session_name> -f <file>
       $(basename "$0") -s <session_name> -c
       $(basename "$0") -s <session_name> -k

Options:
  -s <session>    Name of the tmux session for Stata (required)
  -e <code>       Execute Stata code inline
  -f <file>       Execute Stata code from a file
  -c              Dump full session buffer (no command execution)
  -r              Restart Stata if session exists
  -k              Kill and remove session
  -h, --help      Show this help message

Examples:
  $(basename "$0") -s mysession -e "display \"Hello\""
  $(basename "$0") -s mysession -f script.do
  $(basename "$0") -s mysession -c
  $(basename "$0") -s mysession -k
  $(basename "$0") -s mysession -r -e "sysuse auto"

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--session)
            SESSION_NAME="$2"
            shift 2
            ;;
        -e|--execute)
            CODE="$2"
            shift 2
            ;;
        -f)
            FILE_INPUT="$2"
            shift 2
            ;;
        -c)
            CAPTURE_ONLY=true
            shift
            ;;
        -r)
            RESTART=true
            shift
            ;;
        -k|--kill)
            KILL_SESSION=true
            shift
            ;;
        -h|--help)
            SHOW_HELP=true
            shift
            ;;
        -*)
            echo "Invalid option: $1" >&2
            show_help
            exit 1
            ;;
        *)
            echo "Error: Unexpected argument '$1'. Use -e for inline code or -f for file input." >&2
            show_help
            exit 1
            ;;
    esac
done

# Show help if requested
if [[ "$SHOW_HELP" == true ]]; then
    show_help
    exit 0
fi

# Show help if no arguments provided (and no flags that require session)
if [[ -z "$SESSION_NAME" && -z "$FILE_INPUT" && -z "$CODE" && "$KILL_SESSION" != true && "$CAPTURE_ONLY" != true ]]; then
    show_help
    exit 0
fi

# Validate session name (required for all operations except --help)
if [[ -z "$SESSION_NAME" ]]; then
    echo "Error: Session name (-s) is required" >&2
    exit 1
fi

# Validate file input if specified
if [[ -n "$FILE_INPUT" ]]; then
    if [[ ! -f "$FILE_INPUT" ]]; then
        echo "Error: File not found: $FILE_INPUT" >&2
        exit 1
    fi
fi

# Validate capture-only mode (no code or file allowed)
if [[ "$CAPTURE_ONLY" == true ]]; then
    if [[ -n "$CODE" || -n "$FILE_INPUT" ]]; then
        echo "Error: -c flag does not accept code or file arguments" >&2
        exit 1
    fi
fi

# Validate kill mode (no code or file allowed)
if [[ "$KILL_SESSION" == true ]]; then
    if [[ -n "$CODE" || -n "$FILE_INPUT" ]]; then
        echo "Error: -k flag does not accept code or file arguments" >&2
        exit 1
    fi
fi

# Function to check if Stata is running in session
stata_running() {
    tmux has-session -t "$SESSION_NAME" 2>/dev/null && \
    tmux list-panes -t "$SESSION_NAME" -F "#P #{pane_current_command}" 2>/dev/null | grep -q "stata"
}

# Function to create new Stata session
create_session() {
    echo "Creating new Stata session: $SESSION_NAME"
    tmux new-session -d -s "$SESSION_NAME" -n stata
    # Set history limit to 1 million lines
    tmux set-option -t "$SESSION_NAME" history-limit 1000000
    tmux send-keys -t "$SESSION_NAME" "stata-mp" Enter
    sleep 2
}

# Function to restart Stata in existing session
restart_stata() {
    echo "Restarting Stata in session: $SESSION_NAME"
    # Try graceful exit first
    tmux send-keys -t "$SESSION_NAME" "exit, clear" Enter
    sleep 1
    # Wait for Stata to exit
    sleep 1
    # Start Stata again
    tmux send-keys -t "$SESSION_NAME" "stata-mp" Enter
    sleep 2
}

# Function to forcefully kill and recreate session
force_restart() {
    echo "Force restarting Stata session: $SESSION_NAME"
    tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
    sleep 1
    create_session
}

# Function to kill and remove Stata session
kill_session() {
    local session="$1"
    
    # Check if session exists
    if ! tmux has-session -t "$session" 2>/dev/null; then
        echo "Session '$session' does not exist. Nothing to clean up."
        return 0
    fi
    
    echo "Killing Stata session: $session"
    
    # Try graceful exit first
    if stata_running; then
        echo "Sending graceful exit command to Stata..."
        tmux send-keys -t "$session" "exit, clear" Enter
        sleep 2
    fi
    
    # Kill the tmux session
    tmux kill-session -t "$session" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        echo "Session '$session' has been cleaned up successfully."
    else
        echo "Warning: Failed to kill session '$session'. Please check manually."
        return 1
    fi
    
    return 0
}

# Function to remove Stata comments from code
# Handles: * line comments, // comments, /* */ block comments, /// line continuation
remove_comments() {
    local code="$1"

    # First, handle /// line continuations by joining lines
    local processed_code=""
    local buffer=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check if line contains /// (could be followed by // comment)
        if [[ "$line" =~ /// ]]; then
            # Remove everything from /// onwards (including any // comments after it)
            line="${line%%///*}"
            # Don't trim trailing whitespace - preserve spacing for concatenation
            buffer="$buffer$line"
            # Continue to next line (don't add newline yet)
            continue
        else
            # Line doesn't contain ///, add it to buffer with previous content
            # Don't trim leading whitespace - preserve spacing for concatenation
            processed_code="$processed_code$buffer$line"$'\n'
            buffer=""
        fi
    done <<< "$code"

    # If buffer still has content (last line ended with ///), add it
    if [[ -n "$buffer" ]]; then
        processed_code="$processed_code$buffer"$'\n'
    fi

    # Now process other comments on the joined lines
    local in_block_comment=false
    local result=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$in_block_comment" == true ]]; then
            # Check if block comment ends on this line
            if [[ "$line" =~ \*/ ]]; then
                in_block_comment=false
                # Keep content after */ if any
                line="${line#*\*/}"
                # Trim leading whitespace
                line=$(echo "$line" | sed 's/^[[:space:]]*//')
            else
                # Still in block comment, skip this line
                continue
            fi
        fi

        # Remove single-line /* ... */ comments
        while [[ "$line" =~ /\*.*\*/ ]]; do
            # Use sed for more reliable removal that handles spaces correctly
            line=$(echo "$line" | sed 's|/\*[^*]*\*/||g')
        done

        # Check for start of multi-line block comment
        if [[ "$line" =~ /\* ]]; then
            in_block_comment=true
            # Remove everything from /* to end of line
            line="${line%%/\**}"
            # Trim trailing whitespace
            line="${line%"${line##*[![:space:]]}"}"
            # If line is now empty, skip to next line
            [[ -z "$line" ]] && continue
        fi

        # Remove lines that start with * (but not */ which we already handled)
        if [[ "$line" =~ ^[[:space:]]*\* ]]; then
            continue
        fi

        # Remove lines that start with //
        if [[ "$line" =~ ^[[:space:]]*// ]]; then
            continue
        fi

        # Remove // comments at end of lines
        if [[ "$line" =~ // ]]; then
            line="${line%%//*}"
            # Trim trailing whitespace
            line="${line%"${line##*[![:space:]]}"}"
        fi

        # Trim leading whitespace (indentation doesn't matter in Stata)
        line=$(echo "$line" | sed 's/^[[:space:]]*//')

        # Add non-empty line to result
        if [[ -n "$line" ]]; then
            result+="$line"$'\n'
        fi
    done <<< "$processed_code"

    # Remove trailing newline
    echo -n "$result"
}

# Function to wait for Stata command completion
# Polls the tmux buffer until Stata returns to idle prompt
wait_for_completion() {
    local max_polls=1200
    local poll_interval=0.5
    local polls=0
    local prompt_stable=false
    
    while [[ $polls -lt $max_polls ]]; do
        # Capture current buffer
        local current_buffer
        current_buffer=$(tmux capture-pane -p -t "$SESSION_NAME" 2>/dev/null)
        
        # Get last line
        local last_line
        last_line=$(echo "$current_buffer" | tail -1)
        
        # Check if last line is Stata's idle prompt (. followed by space or just .)
        if [[ "$last_line" =~ ^\.\ *$ ]] || [[ "$last_line" == "." ]]; then
            if [[ "$prompt_stable" == true ]]; then
                # Prompt is stable (appeared in two consecutive polls)
                return 0
            fi
            prompt_stable=true
        else
            prompt_stable=false
        fi
        
        # Wait before next poll
        sleep $poll_interval
        ((polls++))
    done
    
    # Timeout reached - command may still be running
    return 1
}

# Function to send code to Stata session
send_code() {
    local code="$1"  # Already processed

    if [[ -n "$code" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            tmux send-keys -t "$SESSION_NAME" -- "$line" Enter
            sleep 0.1
        done <<< "$code"
        wait_for_completion
    fi
}

# Function to capture output from Stata session
capture_output() {
    # Always capture entire pane history from beginning
    tmux capture-pane -p -S - -t "$SESSION_NAME"
}

# Function to parse output and extract only the last command's results
parse_last_result() {
    local full_output="$1"
    local command="$2"

    # Get first line of command
    local first_line
    first_line=$(echo "$command" | head -1)

    # Empty command? Return full output
    if [[ -z "$first_line" ]]; then
        echo "$full_output"
        return
    fi

    # Find last occurrence of ". first_line"
    local last_line_num
    last_line_num=$(echo "$full_output" | grep -Fn ". $first_line" | tail -1 | cut -d: -f1)

    # Not found? Return full output
    if [[ -z "$last_line_num" ]]; then
        echo "$full_output"
        return
    fi

    # Return everything from that line to end
    echo "$full_output" | sed -n "${last_line_num},\$p"
}

# Handle kill session mode (check first, before any session creation)
if [[ "$KILL_SESSION" == true ]]; then
    kill_session "$SESSION_NAME"
    exit 0
fi

# Main logic - create/restart session if needed
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # Session doesn't exist, create it
    create_session
elif ! stata_running; then
    # Session exists but Stata not running - force restart
    force_restart
elif [[ "$RESTART" == true ]]; then
    # Session exists and Stata is running, but restart requested
    restart_stata
fi

# Prepare command to send and parse
if [[ -n "$CODE" ]]; then
    COMMAND_TO_PARSE=$(remove_comments "$CODE")
elif [[ -n "$FILE_INPUT" ]]; then
    abs_path=$(realpath "$FILE_INPUT" 2>/dev/null || readlink -f "$FILE_INPUT" 2>/dev/null || echo "$FILE_INPUT")
    COMMAND_TO_PARSE="do \"$abs_path\""
fi

# Send if we have a command
if [[ -n "$COMMAND_TO_PARSE" ]]; then
    send_code "$COMMAND_TO_PARSE"
fi

# Capture output
full_output=$(capture_output)

# Handle capture-only mode (dump buffer and exit)
if [[ "$CAPTURE_ONLY" == true ]]; then
    echo "$full_output"
    exit 0
fi

# Parse if we sent something
if [[ -n "$COMMAND_TO_PARSE" ]]; then
    parse_last_result "$full_output" "$COMMAND_TO_PARSE"
else
    echo "$full_output"
fi
