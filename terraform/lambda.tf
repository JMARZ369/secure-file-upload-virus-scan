##############################
# Lambda Function Definition
##############################

resource "aws_lambda_function" "virus_scan_lambda" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      CLEAN_BUCKET_NAME       = var.clean_bucket_name
      QUARANTINE_BUCKET_NAME  = var.quarantine_bucket_name
      VIRUSTOTAL_API_KEY      = var.virustotal_api_key_value
      VIRUS_ALERT_TOPIC_ARN   = aws_sns_topic.threat_alerts.arn
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attach]
}

########################################
# S3 Event Notification → Lambda Trigger
########################################

resource "aws_s3_bucket_notification" "s3_trigger_lambda" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.virus_scan_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".zip" # Optional: restrict trigger to certain file types
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke_lambda]
}

##########################################
# Allow S3 to Invoke the Lambda Function
##########################################

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.virus_scan_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}
