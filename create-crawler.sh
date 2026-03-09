#!/bin/zsh

STAGING_BUCKET_NAME="com-in-context-data-load-staging"

aws cloudformation deploy --template-file glue-crawler.yaml --stack-name com-in-context-data-create-crawler --capabilities CAPABILITY_NAMED_IAM \
--profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"

aws glue start-crawler --name CityDataCrawler \
--profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"

while true; do
  STATE=$(aws glue get-crawler --name CityDataCrawler --query 'Crawler.State' --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" --output text)
  echo "Crawler state: $STATE"
  [ "$STATE" = "READY" ] && break
  sleep 10
done
