terraform {
  backend "s3" {
    bucket         = "secure-file-upload-tf-state"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "secure-file-upload-table"
    encrypt        = true
  }
}
