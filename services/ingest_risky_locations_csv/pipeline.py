import os
import csv
import dlt
import duckdb
from pathlib import Path


def build_risky_locations_source(csv_path: str):
    """
    Creates a DLT source for reading risky locations data from CSV.
    """
    if not Path(csv_path).exists():
        raise FileNotFoundError(
            f"Risky Locations CSV file not found at: {csv_path}")

    @dlt.resource(
        name="risky_locations",
        write_disposition="replace",
        primary_key=["city", "country"]
    )
    def risky_locations_resource():
        with open(csv_path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            expected_columns = {"city", "country", "risk_level"}

            if not expected_columns.issubset(set(reader.fieldnames or [])):
                missing_cols = expected_columns - set(reader.fieldnames or [])
                raise ValueError(f"Missing required columns: {missing_cols}")

            for row in reader:
                cleaned_row = {
                    "city": row["city"].strip(),
                    "country": row["country"].strip(),
                    "risk_level": row["risk_level"].strip()
                }
                if all(cleaned_row.values()):
                    yield cleaned_row

    @dlt.source
    def source():
        yield risky_locations_resource

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
    Main function to execute the risky locations data pipeline.
    """
    try:
        csv_path = os.getenv("CSV_FILE_PATH_RISKY_LOCATIONS",
                             "/app/data/synthetic/risky_locations/risky_locations.csv")
        output_path = os.getenv("PARQUET_EXPORT_DIR_RISKY_LOCATIONS",
                                "/app/data/ingestion/risky_locations/parquet_tables")
        duckdb_path = "/app/data/ingestion/risky_locations/risky_locations.duckdb"

        Path(output_path).mkdir(parents=True, exist_ok=True)
        Path(duckdb_path).parent.mkdir(parents=True, exist_ok=True)

        pipeline = dlt.pipeline(
            pipeline_name="risky_locations_ingestion",
            destination=dlt.destinations.duckdb(duckdb_path),
            dataset_name="risky_locations_data"
        )

        source = build_risky_locations_source(csv_path)
        load_info = pipeline.run(source())
        print("Data loaded to DuckDB successfully")
        print(f"Load info: {load_info}")

        if verify_duckdb_table(duckdb_path, "risky_locations_data", "risky_locations"):
            export_all_tables_to_parquet(
                duckdb_path=duckdb_path,
                dataset_name="risky_locations_data",
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
