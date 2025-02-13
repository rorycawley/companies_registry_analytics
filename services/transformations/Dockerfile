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
