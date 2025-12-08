#!/bin/bash
# Author: Memeti Rejan
# Date:   2025-12-05
# Desc:   Deploys or updates an AWS Lambda function by packaging the source code and applying the latest changes.

log_step "3/4 – Lambda deployen"

BUILD_DIR="build"
ZIP_FILE="$BUILD_DIR/lambda.zip"

log_info "Erzeuge Lambda-Zip..."
mkdir -p "$BUILD_DIR"
(
  cd src || exit 1
  zip -q -r "../$ZIP_FILE" .
)
log_success "Zip erstellt: $ZIP_FILE"

ROLE_ARN="$LAMBDA_ROLE_ARN"

if aws_cmd lambda get-function --function-name "$LAMBDA_NAME" >/dev/null 2>&1; then
  log_info "Lambda '$LAMBDA_NAME' existiert – aktualisiere Code..."
  aws_cmd lambda update-function-code \
    --function-name "$LAMBDA_NAME" \
    --zip-file "fileb://$ZIP_FILE" >/dev/null
  log_success "Lambda-Code aktualisiert."
else
  log_info "Erstelle Lambda '$LAMBDA_NAME'..."
  aws_cmd lambda create-function \
    --function-name "$LAMBDA_NAME" \
    --runtime python3.11 \
    --handler handler.lambda_handler \
    --role "$ROLE_ARN" \
    --timeout 30 \
    --memory-size 256 \
    --zip-file "fileb://$ZIP_FILE" >/dev/null
  log_success "Lambda erstellt."
fi
 