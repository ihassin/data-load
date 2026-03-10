#!/bin/zsh

STAGING_BUCKET_NAME="com-in-context-data-load-staging"

echo "Emptying staging bucket"
aws s3 rm --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" \
  s3://"$STAGING_BUCKET_NAME" --recursive

echo "Deleting stack"
aws cloudformation delete-stack --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" \
  --stack-name com-in-context-data-create-crawler
