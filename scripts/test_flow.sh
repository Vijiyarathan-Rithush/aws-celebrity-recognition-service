#!/bin/bash
# Author: Memeti Rejan
# Date:   2025-12-05
# Desc:   DESCRIPTION


set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

source config.sh
source scripts/utils.sh

TEST_FILE="examples/test.jpg"
RESULT_PREFIX="results"

log_step "End-to-End Test – S3 → Lambda → S3"

require_cmd aws

if [[ ! -f "$TEST_FILE" ]]; then
  error_exit "Testdatei fehlt: $TEST_FILE"
fi

OBJECT_KEY="test.jpg"c
RESULT_KEY="${RESULT_PREFIX}/${OBJECT_KEY}.json"

log_info "Lade Testbild nach s3://${IN_BUCKET_NAME}/${OBJECT_KEY} hoch..."
aws_cmd s3 cp "$TEST_FILE" "s3://${IN_BUCKET_NAME}/${OBJECT_KEY}"
log_success "Upload abgeschlossen."

log_info "Warte auf Resultat in s3://${OUT_BUCKET_NAME}/${RESULT_KEY}..."

MAX_TRIES=20
SLEEP_SECONDS=3
FOUND=0

for ((i=1; i<=MAX_TRIES; i++)); do
  if aws_cmd s3api head-object \
      --bucket "$OUT_BUCKET_NAME" \
      --key "$RESULT_KEY" >/dev/null 2>&1; then
    FOUND=1
    break
  fi
  log_info "Noch kein Ergebnis, Versuch $i/${MAX_TRIES}..."
  sleep "$SLEEP_SECONDS"
done

if [[ "$FOUND" -ne 1 ]]; then
  error_exit "Kein Resultat gefunden nach $((MAX_TRIES * SLEEP_SECONDS)) Sekunden."
fi

log_success "Resultat gefunden. JSON Inhalt:"

aws_cmd s3 cp "s3://${OUT_BUCKET_NAME}/${RESULT_KEY}" - 
echo

log_success "Testlauf abgeschlossen."
