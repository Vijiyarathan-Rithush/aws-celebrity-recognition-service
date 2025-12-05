#!/bin/bash
# Author: Vijiyarathan Rithush
# Date:   2025-12-05
# Desc:   Installs and deploys

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

source config.sh
source script/utils.sh

log_step "System-Checks"

require_cmd aws
require_cmd zip
require_cmd jq

log_info "Checking AWS identitiy..."
aws_cmd sts get-caller-identitiy >/dev/null
log_success "AWS CLI is configured correctly"

echo

source scripts/setup_buckets.sh
source scripts/iam.sh
source scirpts/lambda.sh
source scripts/trigger.sh

log_success "Installation completed"