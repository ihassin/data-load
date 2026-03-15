import sys
import logging

from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from pyspark.sql.functions import col, sum, when

logger = logging.getLogger()
logger.setLevel(logging.INFO)

handler = logging.StreamHandler(sys.stdout)
logger.addHandler(handler)

args = getResolvedOptions(sys.argv, [
    "JOB_NAME",
    "bucket_name",
    "file_path"
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

s3_path = f"s3://{args['bucket_name']}/{args['file_path']}"

logger.info(f"*** Reading parquet from {s3_path}")

df = spark.read.parquet(s3_path)

row_count = df.count()
logger.info(f"*** Loaded {row_count} rows")

# --------------------------------------------------
# Data Quality Check: NULL values
# --------------------------------------------------

null_counts = df.select([
    sum(when(col(c).isNull(), 1).otherwise(0)).alias(c)
    for c in df.columns
])

result = null_counts.collect()[0]

bad_columns = []

for column in df.columns:
    if result[column] > 0:
        bad_columns.append((column, result[column]))

# --------------------------------------------------
# Fail job if nulls exist
# --------------------------------------------------

if bad_columns:
    logger.error("*** Data quality failure: NULL values detected")

    for col_name, count in bad_columns:
        logger.error(f"{col_name}: {count} NULL values")

    raise Exception("*** Data quality checks failed")

logger.info("***Data quality checks passed")

# --------------------------------------------------
# Continue pipeline
# --------------------------------------------------

output_path = f"s3://{args['bucket_name']}/curated/output/"

df.write.mode("overwrite").parquet(output_path)

logger.info("*** Data written to curated layer")
