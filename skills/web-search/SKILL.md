---
name: web-search
description: Perform web searches using DuckDuckGo when you need to find information on the internet without knowing the exact URL. Use this skill for looking up documentation, error messages, tutorials, code examples, technologies, libraries, or any external information.
---

# Web search

## Overview

Use the `ddgr` tool to search DuckDuckGo when you need to find content on the internet.

## Usage

**Command format:**

```bash
# Basic search, 10 results
ddgr "your search query" --np --json; sleep 30

# More results (max 25) 
ddgr "your search query" --np --json -n 20; sleep 30

# Search on a specific website
ddgr "your search query" --np --json --site www.example.com; sleep 30

# Get help
ddgr --help
```

**Required flags:**

- `--np`: (noprompt) Execute search and exit immediately without interactive prompts
- `--json`: Return structured JSON output

**Important instruction**

ALWAYS wait AT LEAST 30 seconds between queries to avoid timeouts or getting blocked by the server.

Do NOT overuse this tool to not get blocked by DuckDuckGo.

## Output Format

Returns JSON array with objects containing:

- `title`: Result page title
- `url`: Direct URL to the result
- `abstract`: Page description/snippet

## When to Use

- Finding documentation, articles, or tutorials
- Looking up error messages or stack traces
- Searching for code examples or library documentation
- Researching technologies, tools, or packages
- Verifying facts or discovering resources
- Any question requiring external internet information

Remember to ALWAYS use sleep to avoid getting blocked.
