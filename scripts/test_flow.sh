#!/bin/bash
# Author: Memeti Rejan
# Date:   2025-12-05
# Desc:   Runs an automated test by uploading a sample file to S3 and waiting for the processed result.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

source config.sh
source scripts/utils.sh

EXAMPLES_DIR="img"
RESULT_PREFIX="results"

require_cmd aws

# nullglob: wenn keine Dateien da sind, bleibt das Array leer
shopt -s nullglob
TEST_FILES=("$EXAMPLES_DIR"/*)

if [[ ${#TEST_FILES[@]} -eq 0 ]]; then
  error_exit "no testimages found in: $EXAMPLES_DIR"
fi

MAX_TRIES=20
SLEEP_SECONDS=1

for TEST_FILE in "${TEST_FILES[@]}"; do
  if [[ ! -f "$TEST_FILE" ]]; then
    log_warn "skipping (not a file): $TEST_FILE"
    continue
  fi

  OBJECT_BASENAME="$(basename "$TEST_FILE")"
  OBJECT_KEY="$OBJECT_BASENAME"
  RESULT_KEY="${RESULT_PREFIX}/${OBJECT_KEY}.json"

  log_info "uploading testimage to s3://${IN_BUCKET_NAME}/${OBJECT_KEY}"
  aws_cmd s3 cp "$TEST_FILE" "s3://${IN_BUCKET_NAME}/${OBJECT_KEY}"
  log_success "upload finished: $OBJECT_BASENAME"

  log_info "waiting for result in s3://${OUT_BUCKET_NAME}/${RESULT_KEY}"

  FOUND=0
  for ((i=1; i<=MAX_TRIES; i++)); do
    if aws_cmd s3api head-object \
        --bucket "$OUT_BUCKET_NAME" \
        --key "$RESULT_KEY" >/dev/null 2>&1; then
      FOUND=1
      break
    fi
    log_info "no result yet for $OBJECT_BASENAME, attempt $i/${MAX_TRIES}"
    sleep "$SLEEP_SECONDS"
  done

  if [[ "$FOUND" -ne 1 ]]; then
    error_exit "no result found for $OBJECT_BASENAME after $((MAX_TRIES * SLEEP_SECONDS)) seconds."
  fi

  log_success "result found for $OBJECT_BASENAME, JSON content:"
  aws_cmd s3 cp "s3://${OUT_BUCKET_NAME}/${RESULT_KEY}" -
  echo
  log_success "test for $OBJECT_BASENAME finished."
  echo "----------------------------------------"
done

log_success "all tests finished (${#TEST_FILES[@]} files)."
