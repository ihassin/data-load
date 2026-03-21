#!/bin/zsh

STAGING_BUCKET_NAME="com-in-context-data-load-staging"
DATA_PATH=city-data
WORKFLOW_NAME=CityDataWorkflow

echo "Submitting stack"
aws cloudformation deploy --template-file glue-crawler.yaml --stack-name com-in-context-city-data-etl --capabilities CAPABILITY_NAMED_IAM \
--profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"

echo "Loading data and script"
aws s3 sync ./data/ "s3://$STAGING_BUCKET_NAME/$DATA_PATH" --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"
aws s3 sync ./scripts/ "s3://$STAGING_BUCKET_NAME/scripts" --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"

#echo "Starting crawler"
#aws glue start-crawler --name CityDataCrawler \
#--profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"
#
#while true; do
#  STATE=$(aws glue get-crawler --name CityDataCrawler --query 'Crawler.State' --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" --output text)
#  echo "Crawler state: $STATE"
#  [ "$STATE" = "READY" ] && break
#  sleep 10
#done
#
#echo "Crawler finished"

echo "Starting workflow"
RUN_ID=$(aws glue start-workflow-run --name "$WORKFLOW_NAME" --query 'RunId' --output text --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION")
aws glue get-workflow-run --name "$WORKFLOW_NAME" --run-id $RUN_ID --output text \
  --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"

echo "Follow along:"
echo "https://$AWS_PERSONAL_REGION.console.aws.amazon.com/glue/home?region=$AWS_PERSONAL_REGION#/v2/etl-configuration/workflows/run/$WORKFLOW_NAME?runId=$RUN_ID"
