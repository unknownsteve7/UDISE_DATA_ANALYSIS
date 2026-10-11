import os
import time
# pyrefly: ignore [missing-import]
from pyspark.sql import SparkSession

# Initialize Spark Session
print("Starting Spark Session for UDISE 2024-25 batch conversion...")
spark = SparkSession.builder \
    .appName("BatchConvertCSVToParquet202425") \
    .config("spark.driver.memory", "4g") \
    .config("spark.executor.memory", "4g") \
    .getOrCreate()

# Base directories (dynamically resolved relative to repository root)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
raw_dataset_dir = os.path.join(BASE_DIR, "UDISE Education Dataset", "UDISE 2024-25")
flat_data_dir = os.path.join(BASE_DIR, "data", "2024-25")
source_dir = raw_dataset_dir if os.path.exists(raw_dataset_dir) else flat_data_dir
target_dir = os.path.join(BASE_DIR, "data", "2024-25_parquet")

# List of files with nested directories for 2024-25 UDISE dataset
files_to_convert = [
    {
        "name": "enroll1",
        "relative_path": r"enrolment_data_1_All State_2024-25\100_enr1.csv"
    },
    {
        "name": "enroll2",
        "relative_path": r"enrolment_data_2_All State_2024-25\100_enr2.csv"
    },
    {
        "name": "facility",
        "relative_path": r"facility_data_All State_2024-25\100_fac.csv"
    },
    {
        "name": "profile1",
        "relative_path": r"profile_data_1_All State_2024-25\100_prof1.csv"
    },
    {
        "name": "profile2",
        "relative_path": r"profile_data_2_All State_2024-25\100_prof2.csv"
    },
    {
        "name": "teacher",
        "relative_path": r"teacher_data_All State_2024-25\100_tch.csv"
    }
]

os.makedirs(target_dir, exist_ok=True)

print("\n=============================================")
print("Starting Batch 2024-25 CSV to Parquet Conversion")
print("=============================================\n")

for item in files_to_convert:
    name = item["name"]
    rel_path = item["relative_path"]
    
    csv_path = os.path.join(source_dir, rel_path)
    output_path = os.path.join(target_dir, f"{name}_parquet")
    
    if not os.path.exists(csv_path):
        print(f"Error: Source file not found: {csv_path}")
        continue
        
    print(f"Processing '{name}' (2024-25)...")
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
            sep=","
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
print("Batch UDISE 2024-25 Conversion Complete!")
print("=============================================")

spark.stop()
