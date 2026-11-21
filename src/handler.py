# Author: Memeti Rejan
# Date:   2025-12-05
# Desc:   Detects celebrities in an uploaded S3 image using Amazon Rekognition and writes the analysis result back to S3.

import json
import logging
import os
from urllib.parse import unquote_plus

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")
rekognition = boto3.client("rekognition")

def lambda_handler(event, context):
    records = event.get("Records", [])
    if not records:
        logger.warning("No S3 records found in event.")
        return {"statusCode": 400, "body": "No S3 records found"}

    output_bucket = os.environ["OUT_BUCKET_NAME"]
    output_keys = [process_record(record, output_bucket) for record in records]
    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "Celebrity detection complete",
                "output_key": output_keys[0],
                "output_keys": output_keys,
            }
        ),
    }


def process_record(record, output_bucket):
    s3_info = record["s3"]
    bucket = s3_info["bucket"]["name"]
    key = unquote_plus(s3_info["object"]["key"])

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

    json_key = f"results/{key}.json"
    s3.put_object(
        Bucket=output_bucket,
        Key=json_key,
        Body=json.dumps(result, indent=2),
        ContentType="application/json",
    )

    return json_key
