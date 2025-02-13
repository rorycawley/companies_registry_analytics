# docker build --no-cache -t companies-registry-transformation-image .
#
# docker run -it \
# -e DBT_DATAWAREHOUSE_DB=/app/data/transformation/trans.db \
# -e DBT_SOURCE_COMPANIES_REGISTRY_PARQUET_EXPORT=/app/data/ingestion/companies_registry/parquet_tables \
# -e DBT_SOURCE_PEPS_PARQUET_EXPORT=/app/data/ingestion/peps/parquet_tables \
# -e DBT_SOURCE_RISKY_LOCATIONS_PARQUET_EXPORT=/app/data/ingestion/risky_locations/parquet_tables \
# companies-registry-transformation-image \
# dbt seed

# docker run -it \
# -e DBT_DATAWAREHOUSE_DB=/app/data/transformation/trans.db \
# -e DBT_SOURCE_COMPANIES_REGISTRY_PARQUET_EXPORT=/app/data/ingestion/companies_registry/parquet_tables \
# -e DBT_SOURCE_PEPS_PARQUET_EXPORT=/app/data/ingestion/peps/parquet_tables \
# -e DBT_SOURCE_RISKY_LOCATIONS_PARQUET_EXPORT=/app/data/ingestion/risky_locations/parquet_tables \
# -v $(pwd)/data/ingestion:/app/data/ingestion:ro \
# -v $(pwd)/data/transformation:/app/data/transformation:rw \
# --user dbtuser \
# --tmpfs /tmp \
# --entrypoint bash \
# companies-registry-transformation-image
FROM --platform=linux/amd64 python:3.11-slim

# Set environment variables for Python and virtual environment settings
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app \
    VIRTUAL_ENV=/app/venv \
    PATH="/app/venv/bin:$PATH" \
    DBT_HOME=/app

# Install git and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root system group and user
RUN groupadd --system --gid 1001 dbtgroup && \
    useradd --system --uid 1001 --gid dbtgroup --shell /bin/bash --create-home dbtuser

# Set working directory
WORKDIR /app

# Copy only requirements to leverage Docker cache
COPY --chown=dbtuser:dbtgroup requirements.txt .

# Create a virtual environment, upgrade pip, and install your requirements
# using uv. The uv line ensures that your system-level libraries are used
# within the container environment.
RUN python -m venv ${VIRTUAL_ENV} && \
    pip install --upgrade pip && \
    pip install uv==0.5.29 && \
    uv pip install --system --no-cache -r requirements.txt && \
    chown -R dbtuser:dbtgroup ${VIRTUAL_ENV}

# Copy the rest of the project files
COPY --chown=dbtuser:dbtgroup . .

# Create data directories
RUN mkdir -p /app/data/transformation && \
    chown -R dbtuser:dbtgroup /app/data

# Switch to non-root user
USER dbtuser

# Copy the entrypoint script
COPY --chown=dbtuser:dbtgroup docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# Default command (can be overridden)
CMD ["dbt", "run"]