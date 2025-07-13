#######################
# Global Configuration
#######################

variable "project_name" {
  description = "Name of the project (used as a prefix for resources)"
  type        = string
  default     = "secure-file-upload"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}

##########################
# S3 Bucket Configuration
##########################

variable "upload_bucket_name" {
  description = "S3 bucket name for user uploads (triggers Lambda)"
  type        = string
  default     = "secure-upload-bucket-369"
}

variable "clean_bucket_name" {
  description = "S3 bucket name for files that pass virus scan"
  type        = string
  default     = "clean-files-bucket-369"
}

variable "quarantine_bucket_name" {
  description = "S3 bucket name for infected/suspicious files"
  type        = string
  default     = "quarantine-files-bucket-369"
}

#########################
# Lambda Configuration
#########################

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "virus-scan-lambda"
}

variable "lambda_runtime" {
  description = "Lambda runtime to use"
  type        = string
  default     = "python3.12"
}

variable "lambda_handler" {
  description = "Function entry point (filename.function_name)"
  type        = string
  default     = "handler.lambda_handler"
}

variable "lambda_memory_size" {
  description = "Memory allocated to the Lambda function (MB)"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 30
}

variable "lambda_zip_path" {
  description = "Local path to the Lambda deployment ZIP file"
  type        = string
  default     = "../lambda/lambda_function.zip"
}

variable "virustotal_api_key_value" {
  type        = string
  description = "API key for VirusTotal (used via GitHub Actions)"
  sensitive   = true
}
