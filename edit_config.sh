#!/bin/bash
# Author: Vijiyarathan Rithush
# Date:   2025-12-05
# Desc:   Safely reconfigures config.env using existing values as defaults. Writes updates atomically using a temporary file.

set -euo pipefail

UTILS_FILE="scripts/utils.sh"
if [[ ! -f "$UTILS_FILE" ]]; then
  echo "ERROR: scripts/utils.sh not found"
  exit 1
fi
source "$UTILS_FILE"

require_cmd aws

CONFIG_FILE="config.env"
TEMP_FILE="config.env.tmp"

log_step "Reconfigure Project Settings"
log_info "Existing values will be used as defaults."

if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  log_success "Existing config.env loaded"
else
  log_warn "No existing config.env found. Starting fresh"
fi

read -p "Are you sure you want to continue? [y/N]: " confirm
if [[ "${confirm,,}" != "y" ]]; then
  log_warn "Operation aborted by user"
  exit 1
fi

prompt() {
  local var_name="$1"
  local prompt_text="$2"
  local default_value="${!var_name:-}"

  if [[ -n "$default_value" ]]; then
    read -p "$prompt_text [$default_value]: " input
    export "$var_name"="${input:-$default_value}"
  else
    read -p "$prompt_text: " input
    export "$var_name"="$input"
  fi
}

log_step "Collecting configuration values"

prompt AWS_REGION "Enter AWS Region (e.g. eu-central-1)"
prompt IN_BUCKET_NAME "Input S3 Bucket name"
prompt OUT_BUCKET_NAME "Output S3 Bucket name"
prompt LAMBDA_NAME "Lambda Function name"

log_step "Detecting AWS account ID"

if ! ACCOUNT_ID=$(aws_cmd sts get-caller-identity --query Account --output text 2>/dev/null); then
  error_exit "AWS credentials not configured or invalid"
fi

IAM_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/LabRole"
log_info "Using IAM Role ARN: $IAM_ROLE_ARN"

log_step "Writing configuration file"

cat > "$TEMP_FILE" <<EOF
AWS_REGION=$AWS_REGION
IN_BUCKET_NAME=$IN_BUCKET_NAME
OUT_BUCKET_NAME=$OUT_BUCKET_NAME
LAMBDA_NAME=$LAMBDA_NAME
IAM_ROLE_ARN=$IAM_ROLE_ARN
EOF

mv "$TEMP_FILE" "$CONFIG_FILE"

log_success "config.env updated safely"
