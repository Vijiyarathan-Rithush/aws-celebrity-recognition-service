#!/bin/bash
# Author: Vijiyarathan Rithush
# Date:   2025-12-05
# Desc:   Trigger

log_step "4/4 – S3 Trigger setzen"

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

# S3 braucht eine explizite Berechtigung, um die Lambda aufzurufen
ACCOUNT_ID="$(
  aws_cmd sts get-caller-identity \
    --query Account \
    --output text
)"
BUCKET_ARN="arn:aws:s3:::${IN_BUCKET_NAME}"

log_info "Setze Lambda-Berechtigung für S3..."

aws_cmd lambda add-permission \
  --function-name "$LAMBDA_NAME" \
  --statement-id "s3invoke-$(date +%s)" \
  --action "lambda:InvokeFunction" \
  --principal s3.amazonaws.com \
  --source-arn "$BUCKET_ARN" \
  --source-account "$ACCOUNT_ID" \
  >/dev/null 2>&1 || log_warn "add-permission evtl. bereits gesetzt."

TMP_FILE="$(mktemp)"

# Platzhalter in Template ersetzen
sed "s#PLACEHOLDER_LAMBDA_ARN#$LAMBDA_ARN#g" "$TEMPLATE" > "$TMP_FILE"

log_info "Setze Notification-Konfiguration für Bucket '$IN_BUCKET_NAME'..."
aws_cmd s3api put-bucket-notification-configuration \
  --bucket "$IN_BUCKET_NAME" \
  --notification-configuration "file://$TMP_FILE"

rm -f "$TMP_FILE"
log_success "S3-Trigger gesetzt."