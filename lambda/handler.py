import json
import logging
import boto3
import os

from utils import scan_file_with_virustotal

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client("s3")

def lambda_handler(event, context):
    logger.info("Received S3 event: %s", json.dumps(event))

    try:
        # 1. Extract bucket and object key from the event
        record = event["Records"][0]
        bucket_name = record["s3"]["bucket"]["name"]
        object_key = record["s3"]["object"]["key"]

        logger.info(f"New file uploaded: s3://{bucket_name}/{object_key}")

        # 2. Download the file to /tmp (Lambda has limited 512MB space)
        local_path = f"/tmp/{object_key.split('/')[-1]}"
        s3_client.download_file(bucket_name, object_key, local_path)

        logger.info(f"⬇File downloaded locally to {local_path}")

        # 3. Placeholder for VirusTotal scan
        logger.info("🧪 Placeholder: Send file to VirusTotal and evaluate response...")

        # TEMP: Auto-tag it as clean just to simulate success
        clean_bucket = os.environ.get("CLEAN_BUCKET_NAME")
        s3_client.upload_file(local_path, clean_bucket, object_key)
        logger.info(f"File moved to clean bucket: s3://{clean_bucket}/{object_key}")

        return {
            "statusCode": 200,
            "body": json.dumps("File processed successfully.")
        }

    except Exception as e:
        logger.error("Error processing file: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error processing file: {str(e)}")
        }
