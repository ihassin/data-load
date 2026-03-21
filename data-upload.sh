#!/bin/zsh

STAGING_BUCKET_NAME="com-in-context-data-load-staging"
DATA_PATH=city-data

echo "Uploading data"
aws s3 sync ./data/ "s3://$STAGING_BUCKET_NAME/$DATA_PATH" --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION"
