#!/bin/bash
# Author: Vijiyarathan Rithush
# Date:   2025-12-05
# Desc:   Trigger


og_step "4/4 – S3 Trigger setzen"

TEMPLATE="iam/s3-trigger.json"

if ! [[ -f "$TEMPLATE" ]]; then
  error_exit "Trigger-Template fehlt: $TEMPLATE"
fi

LAMBDA_ARN="$(
  aws_cmd lambda get-function \
    --function-name "$LAMBDA_NAME" \
    --query 'Configuration.FunctionArn' \
    --output text
)"

log_info "Verwende Lambda-ARN: $LAMBDA_ARN"

TMP_FILE="$(mktemp)"

# Platzhalter ersetzen
sed "s#PLACEHOLDER_LAMBDA_ARN#$LAMBDA_ARN#g" "$TEMPLATE" > "$TMP_FILE"

log_info "Setze Notification-Konfiguration für Bucket '$IN_BUCKET_NAME'..."
aws_cmd s3api put-bucket-notification-configuration \
  --bucket "$IN_BUCKET_NAME" \
  --notification-configuration "file://$TMP_FILE"

rm -f "$TMP_FILE"
log_success "S3-Trigger gesetzt."