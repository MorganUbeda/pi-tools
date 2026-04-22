#!/usr/bin/env bash
# web-search.sh — Wrapper around ddgr for DuckDuckGo web search.
# Passes mandatory flags (--np --json) by default and exposes only
# the options documented in the web-search skill.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: web-search.sh [OPTIONS] "search query"

Perform a DuckDuckGo web search and return structured JSON output.

Arguments:
  "search query"          The query to search for (required)

Options:
  -n, --count NUM         Number of results to return (default: 10, max: 25)
  --site DOMAIN           Restrict search to a specific domain (e.g. www.example.com)
  --help                  Show this help message and exit

Mandatory flags (--np --json) are always passed by default.

Example:
  web-search.sh "your search query"
  web-search.sh -n 20 "your search query"
  web-search.sh --site github.com "your search query"
EOF
}

# Parse optional arguments
COUNT=""
SITE=""
QUERY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    -n|--count)
      if [[ -z "${2:-}" ]]; then
        echo "Error: $1 requires an argument" >&2
        exit 1
      fi
      COUNT="$2"
      shift 2
      ;;
    --site)
      if [[ -z "${2:-}" ]]; then
        echo "Error: $1 requires an argument" >&2
        exit 1
      fi
      SITE="$2"
      shift 2
      ;;
    -*)
      echo "Error: Unknown option '$1'. Use --help for usage." >&2
      exit 1
      ;;
    *)
      QUERY="$1"
      shift
      ;;
  esac
done

if [[ -z "$QUERY" ]]; then
  echo "Error: A search query is required." >&2
  echo "Use --help for usage." >&2
  exit 1
fi

# Build the ddgr command with mandatory + optional flags
CMD=(ddgr --np --json)

if [[ -n "$COUNT" ]]; then
  CMD+=(-n "$COUNT")
fi

if [[ -n "$SITE" ]]; then
  CMD+=(--site "$SITE")
fi

CMD+=("$QUERY")

"${CMD[@]}"
