#!/bin/bash
# Author: Vijiyarathan Rithush
# Date:   2025-12-05
# Desc:   Runs system checks and performs the full installation workflow, including bucket setup, Lambda deployment, and trigger configuration.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

source config.sh
export OUT_BUCKET_NAME
echo $OUT_BUCKET_NAME
source scripts/utils.sh

log_step "System-Checks"

require_cmd aws
require_cmd zip

log_info "Checking AWS identitiy..."
aws_cmd sts get-caller-identity >/dev/null
log_success "AWS CLI is configured correctly"

echo

source scripts/setup_buckets.sh
source scripts/deploy_lambda.sh
source scripts/setup_trigger.sh

log_success "Installation completed"