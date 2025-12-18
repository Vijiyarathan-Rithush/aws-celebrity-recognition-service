#!/bin/bash
# Author: Vijiyarathan Rithush
# Date:   2025-12-05
# Desc:   Creates and configures the required S3 buckets for the service, including region-aware bucket creation.

log_step "1/4 – setup S3 Buckets"

for bucket in "$IN_BUCKET_NAME" "$OUT_BUCKET_NAME"; do
  if aws_cmd s3api head-bucket --bucket "$bucket" 2>/dev/null; then
    log_info "bucket '$bucket' already exists - skipping"
  else
    log_info "creating bucket '$bucket'..."

    if [[ "$AWS_REGION" == "us-east-1" ]]; then
      aws_cmd s3api create-bucket \
        --bucket "$bucket"
    else
      aws_cmd s3api create-bucket \
        --bucket "$bucket" \
        --region "$AWS_REGION" \
        --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi

    log_success "bucket '$bucket' created"
  fi
done

log_success "buckets are ready"