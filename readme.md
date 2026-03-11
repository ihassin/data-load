# Intro

Messing about with AWS Glue

# Running stuff

run `./crawler-create.sh` to create a data bucket, load it with data, create a crawler, run it, and use an Athena saved query to see the results.
run `./crawler-delete.sh` to remove everything.

# Technotes

Creating a table is not needed as the crawler will create one on its first run.
An example of creating a table in CF is:

```yaml
  CityDataGlueTable:
    Type: AWS::Glue::Table
    Properties:
      CatalogId: !Ref AWS::AccountId
      DatabaseName: !Ref CityDataGlueDatabase
      TableInput:
        Name: city-data-table
        TableType: EXTERNAL_TABLE
        Parameters:
          classification: csv
        StorageDescriptor:
          Location: !Sub "${CityDataS3BucketName}/data/"
          InputFormat: org.apache.hadoop.mapred.TextInputFormat
          OutputFormat: org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat
          Compressed: false
          SerdeInfo:
            SerializationLibrary: org.apache.hadoop.hive.serde2.OpenCSVSerde
            Parameters:
              separatorChar: ","
          Columns:
            - Name: id
              Type: string
            - Name: country
              Type: string
            - Name: state
              Type: string
            - Name: city
              Type: string
```

