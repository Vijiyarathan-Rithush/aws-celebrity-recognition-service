# Author: Memeti Rejan
# Date:   2025-12-05
# Desc:   Detects celebrities in an uploaded S3 image using Amazon Rekognition and writes the analysis result back to S3.

import json
import logging
import os
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")
rekognition = boto3.client("rekognition")

# From config.env
OUT_BUCKET_NAME = os.environ.get("OUT_BUCKET_NAME")


def lambda_handler(event, context):
    logger.info("Event received: %s", json.dumps(event))

    records = event.get("Records", [])
    if not records:
        logger.warning("No S3 records found in event.")
        return {"statusCode": 400, "body": "No S3 records found"}

    record = records[0]
    s3_info = record.get("s3", {})

    bucket = s3_info.get("bucket", {}).get("name")
    key = s3_info.get("object", {}).get("key")

    logger.info("Processing file: s3://%s/%s", bucket, key)

    # Rekognition celebrity detection
    response = rekognition.recognize_celebrities(
        Image={"S3Object": {"Bucket": bucket, "Name": key}}
    )

    celebrities = [
        {
            "name": celeb.get("Name"),
            "match_confidence": celeb.get("MatchConfidence"),
        }
        for celeb in response.get("CelebrityFaces", [])
    ]

    result = {
        "source_bucket": bucket,
        "source_key": key,
        "celebrities": celebrities,
    }

    # Write JSON to: results/<filename>.json
    base_name = key.split("/")[-1]
    json_key = f"results/{base_name}.json"

    logger.info("Writing result to s3://%s/%s", OUT_BUCKET_NAME, json_key)

    s3.put_object(
        Bucket=OUT_BUCKET_NAME,
        Key=json_key,
        Body=json.dumps(result, indent=2),
        ContentType="application/json",
    )

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "Celebrity detection complete",
                "output_key": json_key,
            }
        ),
    }