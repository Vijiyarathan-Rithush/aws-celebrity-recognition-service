#!/bin/bash
# Author: Vijiyarathan Rithush
# Date:   2025-12-05
# Desc:   Central configuration file defining AWS region, bucket names, Lambda settings, and IAM role used by all scripts.
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

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
LAMBDA_ROLE_ARN_DEFAULT="arn:aws:iam::${ACCOUNT_ID}:role/LabRole"
LAMBDA_ROLE_ARN="${LAMBDA_ROLE_ARN:-$LAMBDA_ROLE_ARN_DEFAULT}"

echo "=== Face Recognition Installer ==="
echo ""

if [[ -f "$CONFIG_FILE" ]]; then
    echo "Using existing configuration from $CONFIG_FILE"
    source "$CONFIG_FILE"
else
    echo "No configuration found. Creating a new one."
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
fi

echo "Using configuration:"
echo "Region:        $AWS_REGION"
echo "Input Bucket:  $IN_BUCKET_NAME"
echo "Output Bucket: $OUT_BUCKET_NAME"
echo "Lambda Name:   $LAMBDA_NAME"
echo "Role ARN:      $LAMBDA_ROLE_ARN"
echo ""

echo "Starting deployment..."
echo ""

export AWS_REGION IN_BUCKET_NAME OUT_BUCKET_NAME LAMBDA_NAME LAMBDA_ROLE_ARN
