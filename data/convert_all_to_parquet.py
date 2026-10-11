import os
import time
from pyspark.sql import SparkSession

# Initialize Spark Session
print("Starting Spark Session for batch conversion...")
spark = SparkSession.builder \
    .appName("BatchConvertCSVToParquet") \
    .config("spark.driver.memory", "4g") \
    .config("spark.executor.memory", "4g") \
    .getOrCreate()

# Base directories (dynamically resolved relative to repository root)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
source_dir = os.path.join(BASE_DIR, "data", "2023-24")
target_dir = os.path.join(BASE_DIR, "data", "2023-24_parquet")

# List of files to convert
files_to_convert = [
    {"name": "enroll1", "file": "enroll1.csv"},
    {"name": "enroll2", "file": "enroll2.csv"},
    {"name": "facility", "file": "facility.csv"},
    {"name": "profile1", "file": "profile1.csv"},
    {"name": "profile2", "file": "profile2.csv"},
    {"name": "teacher", "file": "teacher.csv"}
]

os.makedirs(target_dir, exist_ok=True)

print("\n=============================================")
print("Starting Batch CSV to Parquet Conversion")
print("=============================================\n")

for item in files_to_convert:
    name = item["name"]
    csv_file = item["file"]
    
    csv_path = os.path.join(source_dir, csv_file)
    output_path = os.path.join(target_dir, f"{name}_parquet")
    
    print(f"Processing '{name}'...")
    print(f"  - Source: {csv_path} ({os.path.getsize(csv_path) / (1024*1024):.1f} MB)")
    print(f"  - Target: {output_path}")
    
    start_time = time.time()
    
    try:
        # Load CSV
        print(f"  [1/2] Reading CSV...")
        df = spark.read.csv(
            csv_path,
            header=True,
            inferSchema=True,
            sep="." if csv_file.endswith(".csv.template") else "," # default sep
        )
        
        # Write Parquet
        print(f"  [2/2] Writing Parquet...")
        df.write.mode("overwrite").parquet(output_path)
        print(f"  Success: Wrote '{name}' parquet.")
        
    except Exception as e:
        # Handle the common Windows Hadoop permission finalization exception
        err_msg = str(e)
        if "Hadoop bin directory does not exist" in err_msg or "NativeIO$Windows.access0" in err_msg:
            # Verify if files were successfully written despite the permission error
            if os.path.exists(output_path) and any(f.endswith(".parquet") for f in os.listdir(output_path)):
                print(f"  Warning: A Windows Hadoop permissions warning occurred, but the parquet files for '{name}' were written successfully.")
            else:
                print(f"  Error: Failed to write '{name}' parquet. Error: {e}")
        else:
            print(f"  Error: Error processing '{name}': {e}")
            
    elapsed = time.time() - start_time
    print(f"  Time taken: {elapsed:.2f} seconds\n")

print("=============================================")
print("Batch Conversion Complete!")
print("=============================================")

spark.stop()
