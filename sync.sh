#!/usr/bin/env bash
set -exuo pipefail

: ${AWS_PROFILE_SOURCE:=source}
: ${AWS_PROFILE_TARGET:=target}

export SOURCE_BUCKET=$1 TARGET_BUCKET=$2
export TARGET_ACCOUNT_ID=$(aws --profile=$AWS_PROFILE_TARGET sts get-caller-identity | yq r - Account)

aws --profile=$AWS_PROFILE_SOURCE s3api get-bucket-policy --bucket $SOURCE_BUCKET --query Policy --output text > policy.json

cat policy.json

echo '{"Statement":[{"Sid":"S3Sync","Effect":"Allow","Principal":{"AWS":"arn:aws:iam::${TARGET_ACCOUNT_ID}:root"},"Action":["s3:List*","s3:Get*"],"Resource":["arn:aws:s3:::${SOURCE_BUCKET}/*","arn:aws:s3:::${SOURCE_BUCKET}"]}]}' | envsubst | yq m -ijPa policy.json -

cat policy.json

aws --profile=$AWS_PROFILE_SOURCE s3api put-bucket-policy --bucket $SOURCE_BUCKET --policy file://policy.json

aws configure set default.s3.max_queue_size 5000
aws configure set default.s3.max_concurrent_requests 200
aws --profile=$AWS_PROFILE_TARGET s3 sync s3://${SOURCE_BUCKET} s3://${TARGET_BUCKET} --sse
