---
name: read-pdf
description: Read PDF documents and extract text content using OCR
---

# Read PDF

## Usage

**Command format:**

```bash
# Convert a PDF file to Markdown
{baseDir}/read-pdf/scripts/read-pdf.sh --input /path/to/file.pdf
```

## Output Format

Returns Markdown-formatted text extracted from the PDF, including:

- Page text content
- Headings and structure
- Lists and tables where applicable
- Preserves document flow across pages

## When to Use

- Extracting text from PDF documents
- Converting scanned documents to editable Markdown (via OCR)
- Preparing PDF content for analysis or summarization
- When you need structured text from a PDF file

## Notes

- This skill takes a long time to run (around 120s per page) so set a high timeout
