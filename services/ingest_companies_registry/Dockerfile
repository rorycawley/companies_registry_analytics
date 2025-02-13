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

# Set environment variables for Python and virtual environment settings
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app \
    VIRTUAL_ENV=/app/venv \
    PATH="/app/venv/bin:$PATH" \
    DLT_HOME=/app

# Install git and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root system group and user
RUN groupadd --system --gid 1001 dltgroup && \
    useradd --system --uid 1001 --gid dltgroup --shell /bin/bash --create-home dltuser

# Set working directory
WORKDIR /app

# Copy only requirements to leverage Docker cache
COPY --chown=dltuser:dltgroup requirements.txt .

# Create a virtual environment, upgrade pip, and install your requirements
# using uv. The uv line ensures that your system-level libraries are used
# within the container environment.
RUN python -m venv ${VIRTUAL_ENV} && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    chown -R dltuser:dltgroup ${VIRTUAL_ENV}

# Copy the rest of the project files
COPY --chown=dltuser:dltgroup . .

# Create data directories
RUN mkdir -p /app/data/transformation && \
    chown -R dltuser:dltgroup /app/data

# Switch to non-root user
USER dltuser

# Copy the entrypoint script
COPY --chown=dltuser:dltgroup docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]

