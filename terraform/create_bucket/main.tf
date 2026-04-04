provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_ssm_parameter" "region" {
  name  = "/${var.ssm_prefix}/region"
  type  = "String"
  value = var.region
}

resource "aws_ssm_parameter" "tf_bucket_name" {
  name  = "/${var.ssm_prefix}/tf_bucket_name"
  type  = "String"
  value = var.bucket_name
}
