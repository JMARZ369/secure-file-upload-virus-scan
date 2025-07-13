import os
import json
import time
import requests
import logging
from typing import Optional

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# API URLs
VIRUSTOTAL_SCAN_URL = "https://www.virustotal.com/api/v3/files"
VIRUSTOTAL_ANALYSIS_URL = "https://www.virustotal.com/api/v3/analyses"

def get_virustotal_api_key() -> str:
    api_key = os.environ.get("VIRUSTOTAL_API_KEY")
    if not api_key:
        raise EnvironmentError("VIRUSTOTAL_API_KEY environment variable is not set.")
    return api_key

def scan_file_with_virustotal(file_path: str) -> str:
    """
    Uploads the file to VirusTotal for scanning and returns an analysis ID.
    """
    api_key = get_virustotal_api_key()

    try:
        logger.info(f"Uploading file to VirusTotal: {file_path}")

        with open(file_path, "rb") as file_to_scan:
            headers = {
                "x-apikey": api_key
            }
            files = {
                "file": (os.path.basename(file_path), file_to_scan)
            }
            
            logger.info(f"VIRUSTOTAL_API_KEY present: {bool(VIRUSTOTAL_API_KEY)}, length: {len(VIRUSTOTAL_API_KEY) if VIRUSTOTAL_API_KEY else 0}")

            response = requests.post(VIRUSTOTAL_SCAN_URL, headers=headers, files=files)
            response.raise_for_status()

            json_data = response.json()
            analysis_id = json_data["data"]["id"]
            logger.info(f"Scan submitted. Analysis ID: {analysis_id}")
            return analysis_id

    except Exception as e:
        logger.error(f"Error submitting file to VirusTotal: {str(e)}", exc_info=True)
        raise

def get_virustotal_verdict(analysis_id: str, timeout: int = 30) -> str:
    """
    Polls VirusTotal for the scan result and returns 'clean' or 'infected'.
    """
    api_key = get_virustotal_api_key()
    headers = {
        "x-apikey": api_key
    }

    for attempt in range(timeout):
        try:
            response = requests.get(f"{VIRUSTOTAL_ANALYSIS_URL}/{analysis_id}", headers=headers)
            response.raise_for_status()

            analysis = response.json()
            status = analysis["data"]["attributes"]["status"]

            if status == "completed":
                stats = analysis["data"]["attributes"]["stats"]
                malicious = stats.get("malicious", 0)
                suspicious = stats.get("suspicious", 0)

                logger.info(f"🔎 VirusTotal stats: {stats}")

                if malicious > 0 or suspicious > 0:
                    return "infected"
                return "clean"

            logger.info(f"Waiting for VirusTotal result... attempt {attempt + 1}")
            time.sleep(1)

        except Exception as e:
            logger.warning(f"Error polling analysis {analysis_id}: {str(e)}", exc_info=True)
            time.sleep(1)

    raise TimeoutError("Timed out waiting for VirusTotal analysis to complete.")
