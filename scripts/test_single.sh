#!/bin/bash
# Author: Vijiyarathan Rithush
# Desc:   Tests processing of a single image.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

source config.sh
source scripts/utils.sh

EXAMPLES_DIR="img"
RESULT_PREFIX="results"

require_cmd aws

# Optional argument: specific file, otherwise default to img/test1.jpg
TEST_FILE="${1:-$EXAMPLES_DIR/TC.jpeg}"

if [[ ! -f "$TEST_FILE" ]]; then
  error_exit "test image not found: $TEST_FILE"
fi

OBJECT_BASENAME="$(basename "$TEST_FILE")"
OBJECT_KEY="$OBJECT_BASENAME"
RESULT_KEY="${RESULT_PREFIX}/${OBJECT_KEY}.json"

log_info "Uploading test image: ${TEST_FILE} -> s3://${IN_BUCKET_NAME}/${OBJECT_KEY}"
aws_cmd s3 cp "$TEST_FILE" "s3://${IN_BUCKET_NAME}/${OBJECT_KEY}"
log_success "Upload finished: $OBJECT_BASENAME"

log_info "Waiting for result in s3://${OUT_BUCKET_NAME}/${RESULT_KEY}"

MAX_TRIES=20
SLEEP_SECONDS=1
FOUND=0

for ((i=1; i<=MAX_TRIES; i++)); do
  if aws_cmd s3api head-object \
      --bucket "$OUT_BUCKET_NAME" \
      --key "$RESULT_KEY" >/dev/null 2>&1; then
    FOUND=1
    break
  fi
  log_info "No result yet for $OBJECT_BASENAME, attempt $i/${MAX_TRIES}"
  sleep "$SLEEP_SECONDS"
done

if [[ "$FOUND" -ne 1 ]]; then
  error_exit "No result found for $OBJECT_BASENAME after $((MAX_TRIES * SLEEP_SECONDS)) seconds."
fi

log_success "Result found for $OBJECT_BASENAME, JSON content:"
aws_cmd s3 cp "s3://${OUT_BUCKET_NAME}/${RESULT_KEY}" -
echo
log_success "Single-image test for $OBJECT_BASENAME finished."
