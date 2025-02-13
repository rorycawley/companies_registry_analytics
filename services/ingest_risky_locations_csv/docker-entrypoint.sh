#!/bin/bash
set -e

echo "Starting to ingest PEPs in the ingestion pipeline..."
python /app/pipeline.py
