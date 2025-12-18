#!/bin/bash
# Author: Memeti Rejan
# Date:   2025-12-08
# Desc:   Deploys or updates the Lambda function using environment variables from install.sh

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

source scripts/utils.sh

log_step "3/4 – depolying lambda"

BUILD_DIR="build"
ZIP_FILE="$BUILD_DIR/lambda.zip"

log_info "creating lambda.zip"
mkdir -p "$BUILD_DIR"
(
  cd src || exit 1
  zip -q -r "../$ZIP_FILE" .
)
log_success "Zip created: $ZIP_FILE"

ENV_JSON="{\"Variables\":{\"IN_BUCKET_NAME\":\"$IN_BUCKET_NAME\",\"OUT_BUCKET_NAME\":\"$OUT_BUCKET_NAME\",\"LAMBDA_NAME\":\"$LAMBDA_NAME\"}}"
ROLE_ARN="$LAMBDA_ROLE_ARN"

# Deploy or update Lambda
if aws_cmd lambda get-function --function-name "$LAMBDA_NAME" >/dev/null 2>&1; then
    log_info "lambda '$LAMBDA_NAME' already exists - updating code..."
    aws_cmd lambda update-function-code \
        --function-name "$LAMBDA_NAME" \
        --zip-file "fileb://$ZIP_FILE" >/dev/null

    log_info "updating lambda enviroment settings"
    aws_cmd lambda update-function-configuration \
        --function-name "$LAMBDA_NAME" \
        --environment "$ENV_JSON" >/dev/null

    log_success "lambda code and enviroment settings updated"
else
    log_info "creating lambda '$LAMBDA_NAME'..."
    aws_cmd lambda create-function \
        --function-name "$LAMBDA_NAME" \
        --runtime python3.11 \
        --handler handler.lambda_handler \
        --role "$ROLE_ARN" \
        --timeout 30 \
        --memory-size 256 \
        --zip-file "fileb://$ZIP_FILE" \
        --environment "$ENV_JSON" >/dev/null

    log_success "lambda created with enviroment variables"
fi
