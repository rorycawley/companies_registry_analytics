import os
import dlt
from dlt.sources.sql_database import sql_database
from dlt.sources.credentials import ConnectionStringCredentials
import duckdb
from typing import List, Dict


def log_stage(message: str) -> None:
    """Print a visually distinct log message for important stages."""
    print("\n🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧")
    print(message)
    print("🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧\n")


def get_postgres_connection_string() -> str:
    user = os.environ.get('POSTGRES_USER')
    password = os.environ.get('POSTGRES_PASSWORD')
    host = os.environ.get('POSTGRES_HOST')
    port = os.environ.get('POSTGRES_PORT')
    db = os.environ.get('POSTGRES_DB')

    log_stage(f"Connecting to PostgreSQL database: {host}:{port}/{db}")
    return f"postgresql://{user}:{password}@{host}:{port}/{db}"


def create_pipeline() -> dlt.Pipeline:
    duckdb_path = os.environ.get(
        "DUCKDB_DB_PATH_COMPANIES",
        "/app/data/ingestion/companies_registry/companies_registry.duckdb"
    )
    dataset_name = os.environ.get("DATASET_NAME_COMPANIES", "companies_data")
    pipeline_name = os.environ.get(
        "PIPELINE_NAME_COMPANIES", "companies_registry")
    dev_mode = os.getenv("DEV_MODE_COMPANIES", "true").lower() == "true"

    log_stage(f"Creating DLT pipeline: {pipeline_name}")
    return dlt.pipeline(
        pipeline_name=pipeline_name,
        destination=dlt.destinations.duckdb(duckdb_path),
        dataset_name=dataset_name,
        dev_mode=dev_mode
    )


def get_latest_dataset(conn: duckdb.DuckDBPyConnection, base_dataset_name: str) -> str:
    """
    Retrieves the most recent dataset name from DuckDB schemas.

    Args:
        conn: DuckDB connection
        base_dataset_name: Base name of the dataset (e.g., 'companies_data')

    Returns:
        str: Full dataset name including timestamp
    """
    log_stage(
        f"Searching for latest dataset matching pattern: {base_dataset_name}_*")
    query = f"""
        SELECT schema_name 
        FROM information_schema.schemata 
        WHERE schema_name LIKE '{base_dataset_name}_%'
        ORDER BY schema_name DESC 
        LIMIT 1
    """
    result = conn.execute(query).fetchone()

    if not result:
        raise ValueError(
            f"No datasets found matching pattern: {base_dataset_name}_*")

    return result[0]


def export_to_parquet(
    duckdb_path: str,
    dataset_name: str,
    tables: List[str],
    parquet_dir: str
) -> None:
    log_stage(f"Starting Parquet export to directory: {parquet_dir}")
    os.makedirs(parquet_dir, exist_ok=True)

    try:
        with duckdb.connect(duckdb_path) as conn:
            full_dataset_name = get_latest_dataset(conn, dataset_name)
            log_stage(f"Exporting data from dataset: {full_dataset_name}")

            for table in tables:
                output_path = os.path.join(parquet_dir, f"{table}.parquet")
                query = (
                    f"COPY (SELECT * FROM {full_dataset_name}.{table}) "
                    f"TO '{output_path}' (FORMAT 'parquet')"
                )
                conn.execute(query)
                log_stage(
                    f"Successfully exported table '{table}' to '{output_path}'")
    except Exception as e:
        log_stage(f"❌ ERROR during Parquet export: {e}")
        raise


def run_ingestion(pipeline: dlt.Pipeline, table_names: List[str]) -> Dict:
    log_stage(f"Starting data ingestion for tables: {', '.join(table_names)}")
    connection_string = get_postgres_connection_string()
    source = sql_database(
        ConnectionStringCredentials(connection_string),
        table_names=table_names
    )
    info = pipeline.run(source)
    log_stage("Data ingestion completed successfully")
    return info


def main() -> None:
    """
    Main entry point for database ingestion.
    """
    log_stage("STARTING DATABASE INGESTION PROCESS")

    pipeline = create_pipeline()
    tables = ['companies', 'financials', 'directors']

    # Run the DLT pipeline
    load_info = run_ingestion(pipeline, table_names=tables)

    # Export to Parquet
    duckdb_path = os.environ.get(
        "DUCKDB_DB_PATH_COMPANIES",
        "/app/data/ingestion/companies_registry/companies_registry.duckdb"
    )
    dataset_name = os.environ.get("DATASET_NAME_COMPANIES", "companies_data")
    parquet_dir = os.environ.get(
        "PARQUET_EXPORT_DIR_COMPANIES",
        "/app/data/ingestion/companies_registry/parquet_tables"
    )
    export_to_parquet(duckdb_path, dataset_name, tables, parquet_dir)

    log_stage("DATABASE INGESTION PROCESS COMPLETED SUCCESSFULLY")


if __name__ == '__main__':
    main()
