---
name: read-pdf-image
description: View a PDF that is actually an image (graph, chart, diagram) by converting it to PNG
---

# Read PDF Image

## Usage

**Steps:**

```bash
# 1. Convert specific pages to PNG (use pdftoppm)
#    Syntax: pdftoppm -png -f <first_page> -l <last_page> input.pdf output_prefix
#    This creates files: output_prefix-1.png, output_prefix-2.png, etc.
pdftoppm -png -f 1 -l 1 /path/to/file.pdf ./preview

# 2. Read the image with the read tool (not bash)
read ./preview-1.png

# 3. Clean up
rm ./preview*.png
```

### Choosing Pages

- **Single page:** `-f 1 -l 1` (or any page number)
- **Multiple pages:** Convert one at a time — read each PNG, then clean up and move to the next
- **Unknown page count:** Start with `-f 1 -l 1`, read it, then increment as needed

## When to Use

- A graph, chart, or plot saved as PDF
- Any PDF that should be viewed visually, not read for text

## Notes

- If `pdftoppm` fails, stop immediately and report the error to the user — don't try to debug it or install alternative libraries
- Always clean up `./preview*.png` after reading
