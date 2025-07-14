# Secure File Upload & Virus Scan (AWS + Lambda + VirusTotal)

This project is a serverless, secure file upload system that automatically scans uploaded files for malware using [VirusTotal](https://www.virustotal.com), routes them to the appropriate S3 bucket (clean or quarantine), and notifies stakeholders of infected files via Amazon SNS.

It is fully automated using Terraform and deployed through GitHub Actions.  
Ideal for organizations needing to safely accept file uploads and perform malware analysis with zero infrastructure management.

---

# Architecture Overview

![Architecture Diagram](./architecture.png)

---

# Features

- 📥 Upload files to a monitored S3 bucket
- 🔍 Automatically scan files using VirusTotal's public API
- ⚖️ Based on scan result, move files to a clean or quarantine bucket
- 📣 Trigger email alerts (SNS) when a threat is detected
- 🔐 Secured with S3 encryption, versioning, and lifecycle rules
- 🛠 Infrastructure-as-Code with Terraform
- 🌀 CI/CD via GitHub Actions

---

# Technologies Used

- AWS Lambda** (Python runtime)
- Amazon S3 (upload, clean, quarantine)
- Amazon SNS (email alerting)
- VirusTotal API v3
- Terraform
- GitHub Actions (CI/CD)

---

# Infrastructure as Code (IaC)

All infrastructure is defined in Terraform:

| Component | Description |
|----------|-------------|
| s3.tf | Upload, clean, and quarantine buckets (encrypted, versioned) |
| lambda.tf | Lambda function with VirusTotal integration |
| iam.tf | IAM roles and policies (least privilege) |
| sns.tf | SNS topic and email subscription |
| security-secrets.tf | VirusTotal API key (stored securely) |
| backend.tf | Remote state (S3 + DynamoDB locking) |
| outputs.tf | Exposes key infrastructure outputs |
| variables.tf | Centralized, reusable configuration |

---

# Continuous Deployment with GitHub Actions

GitHub Actions runs on push to `main`, automatically:

1. Installs Terraform
2. Injects secrets securely (VirusTotal API key, email address)
3. Runs terraform init, plan, and apply

Secrets like AWS_ACCESS_KEY_ID, VIRUSTOTAL_API_KEY, and ALERT_EMAIL are stored in GitHub Secrets.

---

## 🧪 How to Test It

1. Upload a test file (.zip) to your upload S3 bucket:
   
   aws s3 cp eicar.zip s3://secure-upload-bucket-name/

