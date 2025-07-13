import json
import logging
import boto3
import os
from datetime import datetime

from utils import scan_file_with_virustotal, get_virustotal_verdict

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client("s3")
sns_client = boto3.client("sns")

def lambda_handler(event, context):
    logger.info("Received S3 event: %s", json.dumps(event))

    try:
        # 1. Extract bucket and object key from event
        record = event["Records"][0]
        bucket_name = record["s3"]["bucket"]["name"]
        object_key = record["s3"]["object"]["key"]

        logger.info(f"New file uploaded: s3://{bucket_name}/{object_key}")

        # 2. Download file to /tmp
        filename = os.path.basename(object_key)
        local_path = f"/tmp/{filename}"
        s3_client.download_file(bucket_name, object_key, local_path)
        logger.info(f"File downloaded locally: {local_path}")

        # 3. Submit file to VirusTotal
        analysis_id = scan_file_with_virustotal(local_path)
        logger.info(f"VirusTotal analysis ID: {analysis_id}")

        # 4. Get verdict
        verdict = get_virustotal_verdict(analysis_id)
        logger.info(f"VirusTotal verdict: {verdict}")

        # 5. Route file based on verdict
        if verdict == "clean":
            target_bucket = os.environ.get("CLEAN_BUCKET_NAME")
            logger.info("File marked as CLEAN.")
        else:
            target_bucket = os.environ.get("QUARANTINE_BUCKET_NAME")
            logger.warning("File marked as INFECTED or SUSPICIOUS.")

            # 6. Send SNS alert
            timestamp = datetime.utcnow().isoformat() + "Z"
            sns_topic_arn = os.environ.get("VIRUS_ALERT_TOPIC_ARN")
            alert_message = (
                f"Threat detected!\n\n"
                f"File: {object_key}\n"
                f"Bucket: {bucket_name}\n"
                f"Verdict: {verdict}\n"
                f"Timestamp: {timestamp}"
            )

            sns_client.publish(
                TopicArn=sns_topic_arn,
                Subject="Virus Scan Alert",
                Message=alert_message
            )
            logger.info("SNS alert sent.")

        # 7. Upload to appropriate bucket
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
