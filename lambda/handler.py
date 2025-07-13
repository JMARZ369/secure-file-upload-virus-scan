import json
import logging
import boto3
import os

from utils import scan_file_with_virustotal, get_virustotal_verdict

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client("s3")

def lambda_handler(event, context):
    logger.info("Received S3 event: %s", json.dumps(event))

    try:
        # 1. Extract bucket and object key from event
        record = event["Records"][0]
        bucket_name = record["s3"]["bucket"]["name"]
        object_key = record["s3"]["object"]["key"]

        logger.info(f"New file uploaded: s3://{bucket_name}/{object_key}")

        # 2. Download the file to /tmp
        filename = os.path.basename(object_key)
        local_path = f"/tmp/{filename}"

        s3_client.download_file(bucket_name, object_key, local_path)
        logger.info(f"File downloaded to {local_path}")

        # 3. Submit file to VirusTotal
        analysis_id = scan_file_with_virustotal(local_path)
        logger.info(f"VirusTotal analysis ID: {analysis_id}")

        # 4. Poll for result and get verdict
        verdict = get_virustotal_verdict(analysis_id)
        logger.info(f"Verdict from VirusTotal: {verdict}")

        # 5. Decide destination bucket
        if verdict == "clean":
            target_bucket = os.environ.get("CLEAN_BUCKET_NAME")
            logger.info("File marked as CLEAN.")
        else:
            target_bucket = os.environ.get("QUARANTINE_BUCKET_NAME")
            logger.warning("File marked as INFECTED or SUSPICIOUS.")

        # 6. Upload to appropriate bucket
        s3_client.upload_file(local_path, target_bucket, object_key)
        logger.info(f"File moved to: s3://{target_bucket}/{object_key}")

        return {
            "statusCode": 200,
            "body": json.dumps(f"File processed and moved to {verdict} bucket.")
        }

    except Exception as e:
        logger.error("Error processing file: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error: {str(e)}")
        }
