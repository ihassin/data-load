#!/bin/zsh

STAGING_BUCKET_NAME="com-in-context-data-load-staging"
DATA_PATH=city-data

echo "Submitting stack"
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

echo "Crawler finished"

#---

#--arguments "{
#  \"--BUCKET_NAME\": \"s3://$STAGING_BUCKET_NAME\",
#  \"--DATA_FILE_LOCATION\": \"$DATA_PATH\",
#  \"--DATA_FILE_NAME\": \"CityData.csv\",
#  \"--PROCESSED_DATA_LOCATION\": \"processed\"
#  }"
#echo "Starting ETL Job"
#RUN_ID=$(aws glue start-job-run --job-name city-data-etl-job --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" --output text)
#
#echo "Job Run ID: $RUN_ID"
#
#while true; do
#  STATE=$(aws glue get-job-run \
#    --job-name city-data-etl-job \
#    --run-id "$RUN_ID" \
#    --query 'JobRun.JobRunState' \
#    --output text \
#    --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION")
#
#  echo "State: $STATE"
#
#  if [[ "$STATE" == "SUCCEEDED" || "$STATE" == "FAILED" || "$STATE" == "STOPPED" ]]; then
#    break
#  fi
#
#  sleep 10
#done


#echo "Initializing triggers"
#aws glue start-trigger --name StartCityDataPipelineTrigger \
#  --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"
#
#aws glue start-trigger --name RunDataQualityTrigger \
#  --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"

echo "Workflow graph"
aws glue get-workflow --name city-data-workflow --include-graph --output text \
  --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"

echo "Starting workflow"
RUN_ID=$(aws glue start-workflow-run --name city-data-workflow --query 'RunId' --output text --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION")
aws glue get-workflow-run --name city-data-workflow --run-id $RUN_ID --output text \
  --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"
