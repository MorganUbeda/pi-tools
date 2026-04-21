#!/usr/bin/env bash
exec pdf2md \
  --api-url "${PDF_READ_API_URL:-http://127.0.0.1:3101/v1}" \
  --model "${PDF_READ_MODEL:-chandra-ocr-2-8bit-mlx}" \
  "$@"
