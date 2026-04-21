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

# Convert with a specific model
{baseDir}/read-pdf/scripts/read-pdf.sh --input /path/to/file.pdf --model chandra-ocr-2-8bit-mlx

# Override API URL
{baseDir}/read-pdf/scripts/read-pdf.sh --input /path/to/file.pdf --api-url http://127.0.0.1:3101/v1
```

**Requirements:**

- An API server running (default: `http://127.0.0.1:3101/v1`)
- A compatible model available (default: `chandra-ocr-2-8bit-mlx`)
- The input PDF file must exist and be readable

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

- The default model `chandra-ocr-2-8bit-mlx` is an MLX-based OCR model
- Set `PDF_READ_API_URL` or `PDF_READ_MODEL` environment variables to override defaults
- If the API server is not running, the tool will fail with a connection error
- For best OCR quality, ensure the PDF has sufficient resolution
