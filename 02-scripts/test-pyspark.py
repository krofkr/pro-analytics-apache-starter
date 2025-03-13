# 02-scripts/test-pyspark.py

from pyspark.sql import SparkSession
from typing import List, Tuple
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def main() -> None:
    logging.info("Starting PySpark session...")

    try:
        # Create Spark session with local configuration
        spark = SparkSession.builder \
            .appName("TestPySpark") \
            .master("local[*]") \
            .config("spark.driver.memory", "2g") \
            .config("spark.executor.memory", "2g") \
            .getOrCreate()

        logging.info("SparkSession created successfully.")

        # Sample data
        data: List[Tuple[int, str]] = [
            (1, "Alice"),
            (2, "Bob"),
            (3, "Charlie")
        ]

        # Create DataFrame
        df = spark.createDataFrame(data, ["ID", "Name"])

        logging.info("Displaying DataFrame:")
        df.show()

        logging.info("DataFrame created and displayed successfully.")

    except Exception as e:
        logging.error(f"An error occurred: {e}")
    
    finally:
        if "spark" in locals():
            logging.info("Stopping SparkSession...")
            spark.stop()
            logging.info("SparkSession stopped.")

if __name__ == "__main__":
    main()
