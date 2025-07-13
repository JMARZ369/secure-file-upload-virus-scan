##########################
# S3 Bucket Outputs
##########################

output "upload_bucket_name" {
  description = "The name of the S3 bucket for file uploads"
  value       = aws_s3_bucket.upload_bucket.bucket
}

output "clean_bucket_name" {
  description = "The name of the S3 bucket for clean files"
  value       = aws_s3_bucket.clean_bucket.bucket
}

output "quarantine_bucket_name" {
  description = "The name of the S3 bucket for quarantined files"
  value       = aws_s3_bucket.quarantine_bucket.bucket
}

##########################
# Lambda Outputs
##########################

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.virus_scan_lambda.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.virus_scan_lambda.arn
}

output "lambda_execution_role_arn" {
  description = "The ARN of the IAM execution role attached to the Lambda"
  value       = aws_iam_role.lambda_exec_role.arn
}
