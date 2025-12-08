#!/bin/bash
# Author: Vijiyarathan Rithush
# Date:   2025-12-05
# Desc:   Central configuration file defining AWS region, bucket names, Lambda settings, and IAM role used by all scripts.

# REGION
AWS_REGION="us-east-1"

# CONSTANTS
IN_BUCKET_NAME="vijiyarathan-memeti-face-recognition-in"
OUT_BUCKET_NAME="vijiyarathan-memeti-face-recognition-out"
LAMBDA_NAME="face-recognition-lambda"
LAMBDA_ROLE_ARN="arn:aws:iam::654654279869:role/LabRole"
