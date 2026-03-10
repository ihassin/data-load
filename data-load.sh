#!/bin/zsh

LANDING_BUCKET_NAME="com-in-context-data-load-landing"
STAGING_BUCKET_NAME="com-in-context-data-load-staging"

#aws cloudformation deploy --template-file create-data-buckets.yaml --stack-name com-in-context-data-create-buckets \
#--profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"
#
#aws s3 sync ./data/ "s3://$LANDING_BUCKET_NAME" --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"
aws s3 sync ./data/ "s3://$STAGING_BUCKET_NAME/data" --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"
