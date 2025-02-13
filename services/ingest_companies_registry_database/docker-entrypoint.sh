#!/usr/bin/env bash
set -euo pipefail

echo "Starting ingest companies registry DLT ingestion pipeline..."
python /app/pipeline.py
