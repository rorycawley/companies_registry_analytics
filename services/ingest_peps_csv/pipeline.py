import os
import csv
import dlt
import duckdb
from pathlib import Path


def build_peps_source(csv_path: str):
    """
    Creates a DLT source for reading PEPs data from CSV.
    """
    if not Path(csv_path).exists():
        raise FileNotFoundError(f"PEPs CSV file not found at: {csv_path}")

    @dlt.resource(
        name="peps",
        write_disposition="replace",
        primary_key=["first_name", "last_name", "position", "country"]
    )
    def peps_resource():
        with open(csv_path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            expected_columns = {"first_name",
                                "last_name", "position", "country"}

            if not expected_columns.issubset(set(reader.fieldnames or [])):
                missing_cols = expected_columns - set(reader.fieldnames or [])
                raise ValueError(f"Missing required columns: {missing_cols}")

            for row in reader:
                cleaned_row = {
                    "first_name": row["first_name"].strip(),
                    "last_name": row["last_name"].strip(),
                    "position": row["position"].strip(),
                    "country": row["country"].strip()
                }
                if all(cleaned_row.values()):
                    yield cleaned_row

    @dlt.source
    def source():
        yield peps_resource

    return source


def verify_duckdb_table(duckdb_path: str, dataset_name: str, table_name: str) -> bool:
    """
    Verifies if the table exists in DuckDB and contains data.
    """
    with duckdb.connect(duckdb_path) as con:
        res = con.execute(f"""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = '{dataset_name}'
              AND table_name = '{table_name}';
        """).fetchall()
        if not res:
            print(f"Table '{dataset_name}.{table_name}' does not exist!")
            return False

        row_count = con.execute(
            f'SELECT COUNT(*) FROM "{dataset_name}"."{table_name}"'
        ).fetchone()[0]
        print(
            f"Table '{dataset_name}.{table_name}' verified. Row count: {row_count}")
        return row_count > 0


def export_all_tables_to_parquet(duckdb_path: str, dataset_name: str, output_dir: str) -> None:
    """
    Exports all tables from DuckDB to Parquet format.
    """
    os.makedirs(output_dir, exist_ok=True)

    with duckdb.connect(duckdb_path) as con:
        table_rows = con.execute(f"""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = '{dataset_name}';
        """).fetchall()

        tables = [row[0] for row in table_rows]
        tables = [t for t in tables if not t.startswith("_dlt_")]

        for table_name in tables:
            parquet_file = os.path.join(output_dir, f"{table_name}.parquet")
            con.execute(f"""
                COPY "{dataset_name}"."{table_name}"
                TO '{parquet_file}' (FORMAT PARQUET)
            """)
            print(f"Exported '{dataset_name}.{table_name}' to {parquet_file}")


def main():
    """
    Main function to execute the PEPs data pipeline.
    """
    try:
        csv_path = os.getenv("CSV_FILE_PATH_PEPS",
                             "/app/data/synthetic/peps/peps.csv")
        output_path = os.getenv("PARQUET_EXPORT_DIR_PEPS",
                                "/app/data/ingestion/peps/parquet_tables")
        duckdb_path = "/app/data/ingestion/peps/peps.duckdb"

        Path(output_path).mkdir(parents=True, exist_ok=True)
        Path(duckdb_path).parent.mkdir(parents=True, exist_ok=True)

        pipeline = dlt.pipeline(
            pipeline_name="peps_ingestion",
            destination=dlt.destinations.duckdb(duckdb_path),
            dataset_name="peps_data"
        )

        source = build_peps_source(csv_path)
        load_info = pipeline.run(source())
        print(f"Data loaded to DuckDB successfully")
        print(f"Load info: {load_info}")

        if verify_duckdb_table(duckdb_path, "peps_data", "peps"):
            export_all_tables_to_parquet(
                duckdb_path=duckdb_path,
                dataset_name="peps_data",
                output_dir=output_path
            )
            print("Pipeline completed successfully")
        else:
            raise RuntimeError("Data verification failed")

    except Exception as e:
        print(f"Pipeline failed: {str(e)}")
        raise


if __name__ == "__main__":
    main()
