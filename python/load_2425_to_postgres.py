"""
Load UDISE 2024-25 Parquet files into PostgreSQL using DuckDB
(Same method as UDISE_Data_Analysis.ipynb notebook)

Creates tables:
  enrollment1_2425, enrollment2_2425, facilities_2425,
  profile1_2425, profile2_2425, teachers_2425
"""

import duckdb, time

BASE = "data/2024-25_parquet"
PG   = "dbname=udise user=postgres password=1105 host=localhost"

TABLES = [
    ("enroll1_parquet",  "enrollment1_2425"),
    ("enroll2_parquet",  "enrollment2_2425"),
    ("facility_parquet", "facilities_2425"),
    ("profile1_parquet", "profile1_2425"),
    ("profile2_parquet", "profile2_2425"),
    ("teacher_parquet",  "teachers_2425"),
]

print("Connecting via DuckDB -> PostgreSQL...")
conn = duckdb.connect()
conn.execute(f"ATTACH '{PG}' AS pg (TYPE postgres)")
print("[OK] Connection established\n")

for parquet_dir, pg_table in TABLES:
    parquet_path = f"{BASE}/{parquet_dir}/*.parquet"
    print("=" * 55)
    print(f"Loading -> pg.public.{pg_table}")
    t0 = time.time()

    try:
        # Drop if exists
        conn.execute(f"DROP TABLE IF EXISTS pg.public.{pg_table}")

        # Create table from parquet files directly
        conn.execute(f"""
            CREATE TABLE pg.public.{pg_table} AS
            SELECT * FROM read_parquet('{parquet_path}')
        """)

        # Verify row count
        count = conn.execute(
            f"SELECT COUNT(*) FROM pg.public.{pg_table}"
        ).fetchone()[0]
        elapsed = time.time() - t0
        print(f"  [DONE] {count:,} rows loaded in {elapsed:.1f}s\n")

    except Exception as e:
        print(f"  [ERROR] {e}\n")

conn.close()
print("=" * 55)
print("[COMPLETE] All 2024-25 tables loaded into PostgreSQL!")
print("=" * 55)
