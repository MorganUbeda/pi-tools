#!/usr/bin/env bash

# Parse arguments, extracting --fast before passing the rest to pdf2md
FAST=0
ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--fast" ]]; then
    FAST=1
  else
    ARGS+=("$arg")
  fi
done

# Build the pdf2md command
CMD=(pdf2md \
  --api-url "${PDF_READ_API_URL:-http://127.0.0.1:3101/v1}" \
  --model "${PDF_READ_MODEL:-chandra-ocr-2-8bit-mlx}")

if [[ "$FAST" -eq 1 ]]; then
  CMD+=(--no-llm)
fi

CMD+=("${ARGS[@]}")

exec "${CMD[@]}"
