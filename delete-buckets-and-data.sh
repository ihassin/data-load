#!/bin/zsh

LANDING_BUCKET_NAME="com-in-context-data-load-landing"
STAGING_BUCKET_NAME="com-in-context-data-load-staging"

echo "Emptying landing bucket"
aws s3 rm --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" \
  s3://"$LANDING_BUCKET_NAME" --recursive

echo "Emptying staging bucket"
aws s3 rm --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" \
  s3://"$STAGING_BUCKET_NAME" --recursive

aws cloudformation delete-stack --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" \
  --stack-name com-in-context-data-create-buckets

