import os
import dlt
from dlt.sources.sql_database import sql_database
from dlt.sources.credentials import ConnectionStringCredentials
import duckdb
from typing import List, Dict


def get_postgres_connection_string() -> str:
    user = os.environ.get('POSTGRES_USER')
    password = os.environ.get('POSTGRES_PASSWORD')
    host = os.environ.get('POSTGRES_HOST')
    port = os.environ.get('POSTGRES_PORT')
    db = os.environ.get('POSTGRES_DB')

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
    os.makedirs(parquet_dir, exist_ok=True)

    try:
        with duckdb.connect(duckdb_path) as conn:
            # Get the actual dataset name with timestamp
            full_dataset_name = get_latest_dataset(conn, dataset_name)
            print(f"Using dataset: {full_dataset_name}")

            for table in tables:
                output_path = os.path.join(parquet_dir, f"{table}.parquet")
                query = (
                    f"COPY (SELECT * FROM {full_dataset_name}.{table}) "
                    f"TO '{output_path}' (FORMAT 'parquet')"
                )
                conn.execute(query)
                print(f"Exported '{table}' to '{output_path}'")
    except Exception as e:
        print(f"An error occurred during export: {e}")
        raise


def run_ingestion(pipeline: dlt.Pipeline, table_names: List[str]) -> Dict:
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
    # Run the DLT pipeline
    load_info = run_ingestion(pipeline, table_names=tables)
    print("DLT pipeline completed:", load_info)

    # Export to Parquet
    print("Exporting tables to Parquet")
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
    print("Parquet export completed")


if __name__ == '__main__':
    main()
