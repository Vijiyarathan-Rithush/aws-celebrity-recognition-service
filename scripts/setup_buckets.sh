#!/bin/bash
# Author: Vijiyarathan Rithush
# Date:   2025-12-05
# Desc:   Creates Buckets

log_step "1/4 – S3 Buckets einrichten"

for bucket in "$IN_BUCKET_NAME" "$OUT_BUCKET_NAME"; do
  if aws_cmd s3api head-bucket --bucket "$bucket" 2>/dev/null; then
    log_info "Bucket '$bucket' existiert bereits – überspringe."
  else
    log_info "Erstelle Bucket '$bucket'..."

    if [[ "$AWS_REGION" == "us-east-1" ]]; then
      aws_cmd s3api create-bucket \
        --bucket "$bucket"
    else
      aws_cmd s3api create-bucket \
        --bucket "$bucket" \
        --region "$AWS_REGION" \
        --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi

    log_success "Bucket '$bucket' erstellt."
  fi
done

log_success "Buckets sind bereit."