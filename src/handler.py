# Author: Memeti Rejan
# Date:   2025-12-05
# Desc:   Detects celebrities in an uploaded S3 image using Amazon Rekognition and writes the analysis result back to S3.

import json
import logging

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")
rekognition = boto3.client("rekognition")

OUT_BUCKET_NAME = "vijiyarathan-memeti-face-recognition-out"


def lambda_handler(event, context):
    
    logger.info("Ereignis erhalten: %s", json.dumps(event))

    records = event.get("Records", [])
    if not records:
        logger.warning("Keine Records im Event.")
        return {"statusCode": 400, "body": "Keine Records im Event"}

    rec = records[0]
    s3_info = rec.get("s3", {})
    bucket = s3_info.get("bucket", {}).get("name")
    key = s3_info.get("object", {}).get("key")

    logger.info("Verarbeite Datei: s3://%s/%s", bucket, key)

    
    response = rekognition.recognize_celebrities(
        Image={"S3Object": {"Bucket": bucket, "Name": key}}
    )

    celebs = []
    for c in response.get("CelebrityFaces", []):
        celebs.append(
            {
                "name": c.get("Name"),
                "match_confidence": c.get("MatchConfidence"),
            }
        )

    result = {
        "source_bucket": bucket,
        "source_key": key,
        "celebrities": celebs,
    }

    # Ziel-Key: results/<filename>.json
    base_name = key.rsplit("/", 1)[-1]  
    json_key = f"results/{base_name}.json"

    logger.info(
        "Schreibe Resultat nach s3://%s/%s", OUT_BUCKET_NAME, json_key
    )

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
                "message": "Analyse abgeschlossen",
                "output_key": json_key,
            }
        ),
    }
 