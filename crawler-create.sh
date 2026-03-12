#!/bin/zsh

STAGING_BUCKET_NAME="com-in-context-data-load-staging"
DATA_PATH=city-data

echo "Running stack"
aws cloudformation deploy --template-file glue-crawler.yaml --stack-name com-in-context-city-data-etl --capabilities CAPABILITY_NAMED_IAM \
--profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"

echo "Loading data and script"
aws s3 sync ./data/ "s3://$STAGING_BUCKET_NAME/$DATA_PATH" --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"
aws s3 sync ./scripts/ "s3://$STAGING_BUCKET_NAME/scripts" --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"

echo "Starting crawler"
aws glue start-crawler --name CityDataCrawler \
--profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"

while true; do
  STATE=$(aws glue get-crawler --name CityDataCrawler --query 'Crawler.State' --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" --output text)
  echo "Crawler state: $STATE"
  [ "$STATE" = "READY" ] && break
  sleep 10
done

echo "Starting ETL"
aws glue start-job-run --job-name city-data-etl-job \
--profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"
#--arguments "{
#  \"--BUCKET_NAME\": \"s3://$STAGING_BUCKET_NAME\",
#  \"--DATA_FILE_LOCATION\": \"$DATA_PATH\",
#  \"--DATA_FILE_NAME\": \"CityData.csv\",
#  \"--PROCESSED_DATA_LOCATION\": \"processed\"
#  }"

