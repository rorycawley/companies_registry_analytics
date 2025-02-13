# docker build --no-cache -t ingest_companies_registry_db_image .  
# docker run --rm \
#   -e POSTGRES_HOST=my_postgres_host \
#   -e POSTGRES_DB=my_db \
#   -e POSTGRES_USER=my_user \
#   -e POSTGRES_PASSWORD=my_pass \
#   ingest_companies_registry_db_image

# Use an official lightweight Python image.
# Build the image:
#   docker build --no-cache -t companies-registry-dlt-ingestion-image .
#
# Run the container (example):
#   docker run -it \
#     -e POSTGRES_USER=your_user \
#     -e POSTGRES_PASSWORD=your_password \
#     -e POSTGRES_HOST=your_host \
#     -e POSTGRES_PORT=5432 \
#     -e POSTGRES_DB=your_db \
#     -v $(pwd)/data:/app/data:rw \
#     companies-registry-dlt-ingestion-image
#
# Build the image:
#   docker build --no-cache -t companies-registry-dlt-ingestion-image .
#
# Run the container (example):
#   docker run -it \
#     -e POSTGRES_USER=your_user \
#     -e POSTGRES_PASSWORD=your_password \
#     -e POSTGRES_HOST=your_host \
#     -e POSTGRES_PORT=5432 \
#     -e POSTGRES_DB=your_db \
#     -v "$(pwd)/data:/app/data:rw" \
#     companies-registry-dlt-ingestion-image
#
# Build the image:
#   docker build --no-cache -t companies-registry-dlt-ingestion-image .
#
# docker run --rm \
#   --env-file ../../.env \
#   -v /Users/rorycawley/Development/pydev/companies_registry_analytics/data:/app/data \
#   ingest_companies_registry_db_image

### Builder Stage
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .

RUN python -m venv /app/venv && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]