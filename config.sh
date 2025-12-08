#!/bin/bash
# Author: Vijiyarathan Rithush
# Date:   2025-12-05
# Desc:   Central configuration file defining AWS region, bucket names, Lambda settings, and IAM role used by all scripts.

set -euo pipefail

CONFIG_FILE="config.env"

AWS_REGION="${AWS_REGION:-BUCKET-REGION}"
IN_BUCKET_NAME="${IN_BUCKET_NAME:-BUCKET-INPUT-NAME}"
OUT_BUCKET_NAME="${OUT_BUCKET_NAME:-BUCKET-OUTPUT-NAME}"
LAMBDA_NAME="${LAMBDA_NAME:-LAMBDA-NAME}"
LAMBDA_ROLE_ARN="${LAMBDA_ROLE_ARN:-LAMBDA_ROLE_ARN}"


echo "=== Face Recognition Installer ==="
echo ""

# 1. Load existing configuration if present
if [ -f "$CONFIG_FILE" ]; then
    echo "A configuration file already exists."
    source "$CONFIG_FILE"
    read -p "Use existing config (u or Enter) or create a new one (n)? [u/n]: " CHOICE
else
    echo "No configuration found. Creating a new one."
    CHOICE="n"
fi

# 2. Prompt for configuration values
if [[ "$CHOICE" = "n" ]]; then
    echo ""
    echo "Please enter the configuration values (press Enter to keep defaults):"

    read -p "AWS Region [$AWS_REGION]: " INPUT
    AWS_REGION="${INPUT:-$AWS_REGION}"

    read -p "Input Bucket Name [$IN_BUCKET_NAME]: " INPUT
    IN_BUCKET_NAME="${INPUT:-$IN_BUCKET_NAME}"

    read -p "Output Bucket Name [$OUT_BUCKET_NAME]: " INPUT
    OUT_BUCKET_NAME="${INPUT:-$OUT_BUCKET_NAME}"

    read -p "Lambda Name [$LAMBDA_NAME]: " INPUT
    LAMBDA_NAME="${INPUT:-$LAMBDA_NAME}"

    read -p "Lambda Role ARN [$LAMBDA_ROLE_ARN]: " INPUT
    LAMBDA_ROLE_ARN="${INPUT:-$LAMBDA_ROLE_ARN}"

    # Save to config file
    cat > "$CONFIG_FILE" <<EOF
AWS_REGION="$AWS_REGION"
IN_BUCKET_NAME="$IN_BUCKET_NAME"
OUT_BUCKET_NAME="$OUT_BUCKET_NAME"
LAMBDA_NAME="$LAMBDA_NAME"
LAMBDA_ROLE_ARN="$LAMBDA_ROLE_ARN"
EOF

    echo ""
    echo "Configuration saved to $CONFIG_FILE"
    echo ""
else
    # Use existing configuration
    echo ""
fi

# 3. Show values being used
echo "Using configuration:"
echo "Region:        $AWS_REGION"
echo "Input Bucket:  $IN_BUCKET_NAME"
echo "Output Bucket: $OUT_BUCKET_NAME"
echo "Lambda Name:   $LAMBDA_NAME"
echo "Role ARN:      $LAMBDA_ROLE_ARN"
echo ""

echo "Starting deployment..."
echo ""

