import os
import requests
import logging

from typing import Optional

VIRUSTOTAL_API_KEY: Optional[str] = os.environ.get("VIRUSTOTAL_API_KEY")

logger = logging.getLogger()
logger.setLevel(logging.INFO)

VIRUSTOTAL_API_KEY = os.environ.get("VIRUSTOTAL_API_KEY")
if not VIRUSTOTAL_API_KEY:
    raise EnvironmentError("VIRUSTOTAL_API_KEY environment variable is not set.")
VIRUSTOTAL_SCAN_URL = "https://www.virustotal.com/api/v3/files"

def scan_file_with_virustotal(file_path):
    if not VIRUSTOTAL_API_KEY:
        raise ValueError("VIRUSTOTAL_API_KEY environment variable is not set.")

    try:
        logger.info(f"Scanning file with VirusTotal: {file_path}")

        with open(file_path, "rb") as file_to_scan:
            headers = {
                "x-apikey": VIRUSTOTAL_API_KEY
            }
            files = {
                "file": (os.path.basename(file_path), file_to_scan)
            }

            response = requests.post(VIRUSTOTAL_SCAN_URL, headers=headers, files=files)
            response.raise_for_status()

            json_data = response.json()
            analysis_id = json_data["data"]["id"]
            logger.info(f"🧪 VirusTotal scan submitted, analysis ID: {analysis_id}")
            return analysis_id

    except Exception as e:
        logger.error(f"Error scanning file with VirusTotal: {str(e)}")
        raise


