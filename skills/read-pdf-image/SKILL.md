---
name: read-pdf-image
description: View a PDF that is actually an image (graph, chart, diagram) by converting it to PNG
---

# Read PDF Image

## Usage

**Steps:**

```bash
# 1. Convert PDF to PNG (1200px for readability)
sips -s format png -Z 1200 /path/to/file.pdf --out /tmp/pdf-image-preview.png

# 2. Read the image with the read tool (not bash)
read /tmp/pdf-image-preview.png

# 3. Clean up
rm /tmp/pdf-image-preview.png
```

## When to Use

- A graph, chart, or plot saved as PDF
- Any PDF that should be viewed visually, not read for text

## Notes

- `sips` renders only the first page
- Always clean up `/tmp/pdf-image-preview.png` after reading
