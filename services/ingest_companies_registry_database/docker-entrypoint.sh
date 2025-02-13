#!/bin/bash
set -e

echo "Starting to ingest the Companies Registry database in the ingestion pipeline..."
python /app/pipeline.py
