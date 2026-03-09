#!/bin/zsh

aws cloudformation delete-stack --profile "$AWS_TW_PROFILE" --region "$AWS_PERSONAL_REGION" \
  --stack-name com-in-context-data-create-crawler
