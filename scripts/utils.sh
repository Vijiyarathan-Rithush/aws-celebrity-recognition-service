#!/bin/bash
# Author: Vijiyarathan Rithush
# Date:   2025-12-05
# Desc:   Provides reusable logging, error handling, command checks, and AWS wrapper utilities for all project scripts.

# ANSI color
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m"

timestamp() {
  date +"%H:%M:%S"
}

log_info() {
  echo -e "$(timestamp) ${BLUE}[INFO]${NC}    $*"
}

log_step() {
  echo -e "$(timestamp) ${BLUE}[STEP]${NC}    $*"
}

log_warn() {
  echo -e "$(timestamp) ${YELLOW}[WARN]${NC}    $*"
}

log_success() {
  echo -e "$(timestamp) ${GREEN}[SUCCESS]${NC} $*"
}

log_error() {
  echo -e "$(timestamp) ${RED}[ERROR]${NC}   $*" >&2
}

error_exit() {
  log_error "$*"
  exit 1
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error_exit "Command '$cmd' not found"
  fi
}

# Always use default profile
aws_cmd() {
  aws "$@"
}