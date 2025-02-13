import os
import dlt
from dlt.sources.sql_database import sql_database
import psycopg2
import duckdb
from dlt.sources.credentials import ConnectionStringCredentials


def load_selected_tables_from_database():
    """
    1) Creates a pipeline that ingests from PostgreSQL to DuckDB via dlt's sql_database.
    """
    print("Creating pipeline for database ingestion")
    pipeline = dlt.pipeline(
        pipeline_name="companies_registry",
        destination=dlt.destinations.duckdb(
            "/app/data/ingestion/companies_registry/companies_registry.duckdb"),
        dataset_name="companies_data",
        dev_mode="dev_mode"
    )

    # Fetch tables
    pg_connection_string = (
        f"postgresql://{os.environ['POSTGRES_USER']}:{os.environ['POSTGRES_PASSWORD']}@"
        f"{os.environ['POSTGRES_HOST']}:{os.environ['POSTGRES_PORT']}/"
        f"{os.environ['POSTGRES_DB']}"
    )

    source = sql_database(ConnectionStringCredentials(
        pg_connection_string), table_names=['companies', 'financials', 'directors'])

    """
    2) Returns the load info object for further actions.
    """
    info = pipeline.run(source)

    # Print load info
    print(info)

load_selected_tables_from_database()