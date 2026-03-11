import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, when

args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args['JOB_NAME'], args)

df = spark.read.option("header","true").csv(
    "s3://com-in-context-data-load-staging/city-data/CityData.csv"
)

df = df.withColumn(
    "State",
    when((col("State").isNull()) | (col("State") == ""), "n/a")
    .otherwise(col("State"))
)

df.write.mode("overwrite").parquet(
    "s3://com-in-context-data-load-staging/processed/"
)

job.commit()
