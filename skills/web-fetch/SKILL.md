---
name: web-fetch
description: Fetch and retrieve content from webpages when you need to access specific URLs directly. Use this skill for reading documentation, articles, tutorials, API references, or any webpage content that requires direct URL access.
---

# Web fetch

## Usage

**Command format:**

```bash
# Basic fetch
{baseDir}/web-fetch/scripts/web-fetch.sh "https://example.com"

# Fetch a specific documentation page
{baseDir}/web-fetch/scripts/web-fetch.sh "https://docs.example.com/api"
```

**Requirements:**

- URL must be a valid, accessible webpage
- Script must have execute permissions
- Network connectivity required

## Output Format

Returns cleaned, Markdown-formatted content from the webpage including:

- Page title and headings
- Formatted text content
- Lists and code blocks
- Links and references

## When to Use

- Reading specific documentation pages
- Accessing API references or tutorials
- Fetching article or blog content
- Retrieving information from known URLs
- Reading web-based resources when URL is known
- Getting structured content from webpages

## Notes

- The script automatically cleans and formats content as Markdown
- If the tool fails with error 126, it indicates a network error or server refusal (not a tool bug)
- Do NOT try to debug the tool
- If the tool fails repeatedly, you can fall back to a simple curl command
- Consider using the web-search skill when you need to discover URLs first
