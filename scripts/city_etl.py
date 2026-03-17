import sys
import logging

from awsglue.utils import getResolvedOptions
from awsglue.job import Job
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from pyspark.sql.functions import col, when

logger = logging.getLogger()
logger.setLevel(logging.INFO)

handler = logging.StreamHandler(sys.stdout)
logger.addHandler(handler)

logger.info("*** Transformation start")

args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "BUCKET_NAME",
        "DATA_FILE_LOCATION",
        "DATA_FILE_NAME",
        "PROCESSED_DATA_LOCATION",
        "PARQUET_PATH"
    ]
)
logger.info(f"*** Args: {args}")

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args['JOB_NAME'], args)

bucket_name = args["BUCKET_NAME"]
data_file_location = args["DATA_FILE_LOCATION"]
data_file_name = args["DATA_FILE_NAME"]
processed_data_location = args["PROCESSED_DATA_LOCATION"]
parquet_path = args["PARQUET_PATH"]

df = spark.read.option("header","true").csv(
    f"{bucket_name}/{data_file_location}/{data_file_name}"
)

df = df.withColumn(
    "State",
    when((col("State").isNull()) | (col("State") == ""), "n/a")
    .otherwise(col("State"))
)
logger.info(f"*** Transformed Record count: {df.count()}")
logger.info("*** Preview transformed data:")
for row in df.take(5):
    logger.info(row)

df.write.mode("overwrite").parquet(
    f"{bucket_name}/{processed_data_location}/{parquet_path}"
)

job.commit()
logger.info("*** Transformation complete")
