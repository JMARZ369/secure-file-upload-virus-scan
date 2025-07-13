###########################
# Secure File Upload Buckets
###########################

resource "aws_s3_bucket" "upload_bucket" {
  bucket = "${var.upload_bucket_name}"

  tags = {
    Name        = "${var.project_name}-upload"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "upload_versioning" {
  bucket = aws_s3_bucket.upload_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "upload_encryption" {
  bucket = aws_s3_bucket.upload_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "clean_bucket" {
  bucket = "${var.clean_bucket_name}"

  tags = {
    Name        = "${var.project_name}-clean"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "clean_versioning" {
  bucket = aws_s3_bucket.clean_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "clean_encryption" {
  bucket = aws_s3_bucket.clean_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "quarantine_bucket" {
  bucket = "${var.quarantine_bucket_name}"

  tags = {
    Name        = "${var.project_name}-quarantine"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "quarantine_versioning" {
  bucket = aws_s3_bucket.quarantine_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "quarantine_encryption" {
  bucket = aws_s3_bucket.quarantine_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "quarantine_lifecycle" {
  bucket = aws_s3_bucket.quarantine_bucket.id

  rule {
    id     = "ExpireQuarantinedFiles"
    status = "Enabled"

    expiration {
      days = 30
    }

    filter {
      prefix = "" # applies to all objects
    }
  }
}

############################
# Enable S3 Block Public Access
############################

resource "aws_s3_bucket_public_access_block" "upload_block" {
  bucket = aws_s3_bucket.upload_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "clean_block" {
  bucket = aws_s3_bucket.clean_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "quarantine_block" {
  bucket = aws_s3_bucket.quarantine_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
