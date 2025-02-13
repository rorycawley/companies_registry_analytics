import os
import dlt
from dlt.sources.sql_database import sql_database
from dlt.sources.credentials import ConnectionStringCredentials


def get_postgres_connection_string() -> str:
    """
    Constructs a PostgreSQL connection string using environment variables.
    """
    user = os.environ.get('POSTGRES_USER')
    password = os.environ.get('POSTGRES_PASSWORD')
    host = os.environ.get('POSTGRES_HOST')
    port = os.environ.get('POSTGRES_PORT')
    db = os.environ.get('POSTGRES_DB')

    return f"postgresql://{user}:{password}@{host}:{port}/{db}"


def create_pipeline() -> dlt.Pipeline:
    """
    Creates and returns a dlt pipeline using environment variables for configuration.
    Environment Variables:
        - DUCKDB_DB_PATH_COMPANIES: Path to the DuckDB database.
        - DATASET_NAME_COMPANIES: Name of the dataset.
        - PIPELINE_NAME_COMPANIES: Name of the pipeline.
    """
    duckdb_path = os.environ.get(
        "DUCKDB_DB_PATH_COMPANIES",
        "/app/data/ingestion/companies_registry/companies_registry.duckdb"
    )
    dataset_name = os.environ.get("DATASET_NAME_COMPANIES", "companies_data")
    pipeline_name = os.environ.get(
        "PIPELINE_NAME_COMPANIES", "companies_registry")

    return dlt.pipeline(
        pipeline_name=pipeline_name,
        destination=dlt.destinations.duckdb(duckdb_path),
        dataset_name=dataset_name,
        dev_mode="dev_mode"
    )


def run_ingestion(pipeline: dlt.Pipeline, table_names: list[str]) -> dict:
    """
    Runs the ingestion pipeline for the specified table names and returns the load info.
    """
    connection_string = get_postgres_connection_string()
    source = sql_database(
        ConnectionStringCredentials(connection_string),
        table_names=table_names
    )
    info = pipeline.run(source)
    print(info)
    return info


def main() -> None:
    """
    Main entry point for database ingestion.
    """
    print("Creating pipeline for database ingestion")
    pipeline = create_pipeline()
    tables = ['companies', 'financials', 'directors']
    load_info = run_ingestion(pipeline, table_names=tables)
    # Further processing with load_info if needed
    print(load_info)


if __name__ == '__main__':
    main()
