##########################
# IAM Role for Lambda
##########################

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.lambda_function_name}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

##############################
# IAM Policy for Lambda Access
##############################

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.lambda_function_name}-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Allow writing logs
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },

      # Read from upload bucket
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${var.upload_bucket_name}/*"
      },

      # Write to clean/quarantine buckets
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.clean_bucket_name}/*",
          "arn:aws:s3:::${var.quarantine_bucket_name}/*"
        ]
      },

      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = aws_sns_topic.threat_alerts.arn
      }

    ]
  })
}

#################################
# Attach Policy to Lambda Role
#################################

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
